-- INVESTIGATING MOST FOLLOWED ARTISTS
SELECT a.Name_,
	   f.ArtistID,
       COUNT(f.UserID) AS `Number of followers`
FROM music.Follow as f
INNER JOIN music.Artist as a
	ON a.ArtistID = f.ArtistID
GROUP BY f.ArtistID
ORDER BY 3 DESC
;
-- MOST FOLLOWED IS 'Jungle Okra'
-- (PLEASE NOTE THAT, AS THE DATABASE IS INITIALISED USING RAND(), THE MOST FOLLOWED
-- ARTIST MAY CHANGE WHEN YOU RUN THE CODE; HOWEVER, THE LOGIC HOLDS)

-- LET'S INVESTIGATE 
	-- THE AVERAGE DURATION OF THEIR SONGS COMPARED TO THE GLOBAL AVERAGE
    -- THE AMOUNT OF TIMES THEIR SONGS APPEAR IN PLAYLIST COMPARED TO THE GLOBAL AVERAGE

-- SONG DURATION
WITH temp1 AS 
(
	SELECT AVG(Duration) AS a
    FROM music.Song
),
temp2 AS
(
	SELECT AVG(s.Duration) AS b
	FROM music.PerformsOnSong AS pos
	INNER JOIN music.Song AS s
		ON pos.SongID = s.SongID
		AND pos.ArtistID = 40
)
SELECT temp1.a AS `Global Average`,
	   temp2.b AS `Jungle Okra's Average`
FROM temp1, temp2
;
-- THEIR AVERAGE SONG DURATION IS HIGHER THAN THE GLOBAL AVERAGE BY ~120s

-- PLAYLIST APPEARENCES
WITH temp1 AS 
(
	SELECT COUNT(pt.SongID) AS ct1
	FROM music.PlaylistTrack AS pt
	INNER JOIN music.Song AS s
		ON s.SongID = pt.SongID
	INNER JOIN music.PerformsOnSong AS pos
		ON s.SongID = pos.SongID
		AND pos.ArtistID = 40
),
temp2 AS
(                                               
	SELECT pos.ArtistID,
		   COUNT(pos.ArtistID) AS ct2
	FROM music.PlaylistTrack AS pt
	INNER JOIN music.Song AS s
		ON s.SongID = pt.SongID
	INNER JOIN music.PerformsOnSong AS pos
		ON s.SongID = pos.SongID
	GROUP BY pos.ArtistID
)
SELECT AVG(temp1.ct1) AS `Number of playlist appearences for Jungle Okra`,
	   AVG(temp2.ct2) AS `Average number of playlist appearences per artist`
FROM temp1, temp2
;
-- THEY APPEAR IN PLAYLISTS LESS THAN THE AVERAGE ARTIST!

-- GIVEN THIS, LET'S INVESTIGATE SONG DURATION, AND ITS EFFECT ON ARTIST FOLLOWERS, 
-- BY SPLITTING IT INTO QUARTILES USING NTILE() AND COUNTING THE AMOUNT OF 
-- FOLLOWERS ARTISTS WHO PERFORMED ON THESE SONGS HAVE

WITH temp1 AS
(
	SELECT SongID,
		   NTILE(4) OVER (
				ORDER BY Duration
		   ) AS quartile
	FROM music.Song
)
SELECT temp1.quartile,
       COUNT(f.UserID) AS `Number of artist followers`
FROM temp1
INNER JOIN music.PerformsOnSong AS pos
	ON temp1.SongID = pos.SongID
INNER JOIN music.Follow AS f
	ON f.ArtistID = pos.ArtistID
GROUP BY temp1.quartile
;

-- NOT MUCH CORRELATION. LET'S DO THE SAME, BUT WITH PLAYLIST APPEARENCES
WITH temp1 AS
(
	SELECT SongID,
		   NTILE(4) OVER (
				ORDER BY Duration
		   ) AS quartile
	FROM music.Song
)
SELECT COUNT(pt.TrackNo) AS `Number of playlist appearences`,
	   temp1.quartile
FROM temp1
INNER JOIN music.PlaylistTrack AS pt
	ON pt.SongID = temp1.SongID
GROUP BY temp1.quartile
;
-- NOT MUCH CORRELATION. (THIS MAKES SENSE, AS THE DATABASE WAS INITIALISED RANDOMLY).

-- LET'S MOVE ON AND SEE IF THERE IS A RELATIONSHIP BETWEEN ALBUM LENGTH 
-- AND ARTIST FOLLOW COUNT. FIRST, LET'S TAKE A LOOK AT ALBUM LENGTHS
SELECT a.AlbumID,
	   SUM(s.Duration) AS album_length
FROM music.AlbumTrack AS a
INNER JOIN music.Song As s
	ON a.SongID = s.SongID
GROUP BY 1
ORDER BY 2 DESC
;
-- WE NOTICE SOME ALBUMS ARE VERY LONG - THESE ARE THE COMPILATION ALBUMS WITH NO SET ARTIST.

-- WE REMOVE THESE, AND JOIN IT WITH FOLLOW TO EXAMINE IF ALBUM LENGTH HAS ANY EFFECT
WITH temp1 AS
(
	SELECT a.AlbumID,
		   SUM(s.Duration) AS album_length
	FROM music.AlbumTrack AS a
	INNER JOIN music.Song As s
		ON a.SongID = s.SongID
		AND a.AlbumID NOT IN (51, 52, 53)
	GROUP BY 1
	ORDER BY 2 DESC
)
SELECT al.AlbumID,
	   temp1.album_length,
       COUNT(f.UserID) AS `Number of main artist's followers`
FROM temp1
INNER JOIN music.Album AS al
	ON al.AlbumID = temp1.AlbumID
LEFT JOIN music.Follow AS f
	ON al.MainArtist = f.ArtistID
GROUP BY temp1.AlbumID
ORDER BY 2 DESC
;

-- TO VISUALISE THIS BETTER, WE'LL SPLIT INTO QUARTILES AGAIN
WITH temp1 AS
(
	SELECT a.AlbumID,
		   SUM(s.Duration) AS album_length
	FROM music.AlbumTrack AS a
	INNER JOIN music.Song As s
		ON a.SongID = s.SongID
		AND a.AlbumID NOT IN (51, 52, 53)
	GROUP BY 1
	ORDER BY 2 DESC
),
temp2 AS
(
	SELECT *,
           NTILE(4) OVER (
				ORDER BY album_length
		   ) AS quartile
	FROM temp1
)
SELECT quartile,
       COUNT(f.UserID) / 12 AS `Average number of main artist's followers`
FROM temp2
INNER JOIN music.Album AS al
	ON al.AlbumID = temp2.AlbumID
LEFT JOIN music.Follow AS f
	ON al.MainArtist = f.ArtistID
GROUP BY 1
;
-- AS EXPECTED, NO TRENDS OF NOTE.
