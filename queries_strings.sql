-- BEFORE WE START, FIRST CHECK FOR ANY SPACES IN EMAILS
SELECT *
FROM music.Accounts
WHERE RTRIM(Email) LIKE '% %'
;

-- THERE IS ONLY ONE; WE CAN EASILY UPDATE THAT RECORD 
UPDATE music.Accounts
SET Email = REPLACE(Email, ' ', '')
WHERE AccountID = 13
;

-- GIVEN THE FACT THAT THE FIRST CHARACTER IN EACH EMAIL IS THE FIRST INITIAL OF THE USER,
-- LET'S EXAMINE THE DISTRIBUTION OF FIRST INITIALS OF ACCOUNT HOLDERS. TO DO THIS. 
-- WE FIRST CREATE A TABLE INVOLVING ALL LETTERS OF THE ALPHABET, SO IF THERE ARE NO EMAILS
-- THAT BEGIN WITH A CERTAIN LETTER, WE CAN RECORD THE RESULT AS ZERO

CREATE TEMPORARY TABLE music.alphabet (
	ltr CHAR(1),
    val REAL DEFAULT 0
);

SET @row_number = 0;

INSERT INTO music.alphabet(ltr)
	SELECT CHAR((@row_number:=@row_number + 1) + 64) -- 'A' is the 65th character on the ASCII table
	FROM music.Accounts -- As accounts has > 26 rows
    WHERE @row_number < 26
;

-- NOW CHECKING DISTRIBUTION OF FIRST NAMES
WITH temp1 AS 
(
	SELECT UPPER(SUBSTRING(Email, 1, 1)) AS init,
		   COUNT(AccountID) AS num
	FROM music.Accounts
	GROUP BY 1
	ORDER BY 2 DESC
)
SELECT music.alphabet.ltr AS `First initial`,
	   IFNULL(temp1.num + music.alphabet.val, 0) AS `Number of accounts`
FROM temp1
RIGHT JOIN alphabet
	ON temp1.init = music.alphabet.ltr
ORDER BY 2 DESC
;
-- J POPS UP A LOT!

-- REPEATING THE ABOVE BUT WITH LAST NAMES
WITH temp1 AS 
(
	SELECT UPPER(SUBSTRING(Email, 2, 1)) AS init,
		   COUNT(AccountID) AS num
	FROM music.Accounts
	GROUP BY 1
	ORDER BY 2 DESC
)
SELECT alphabet.ltr AS `Second initial`,
	   IFNULL(temp1.num + alphabet.val, 0) AS `Number of accounts`
FROM temp1
RIGHT JOIN alphabet
	ON temp1.init = alphabet.ltr
ORDER BY 2 DESC
;
-- THIS ONE BEHAVES MORE LIKE EXPECTED

-- LET'S NOW SEE WHAT LETTERS APPEAR MOST IN SONGS
WITH temp1 AS
(
	SELECT al.ltr, 
		   LENGTH(UPPER(s.Name_)) - LENGTH(REPLACE(UPPER(s.Name_), al.ltr, '')) AS ctr1 
	FROM music.Song AS s, music.alphabet AS al
)
SELECT ltr AS `Letter`,
	   SUM(ctr1) AS `Number of appearences in song names`
FROM temp1
GROUP BY 1
ORDER BY 2 DESC
;
-- LOTS OF E, T, O - BUT WHY? 

-- LET'S INVESTIGATE WHAT WORDS APPEAR MOST IN SONGS. TO DO THIS, WE MAKE USE OF 
-- ANOTHER TEMPORARY TABLE, WHICH IS JUST COMPRISED OF THE INTEGERS 0, 1, ..., 9
CREATE TEMPORARY TABLE music.ints (
	i int
);

INSERT INTO music.ints
	VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)
;

SELECT Word,
       COUNT(*) AS `Number of songs`
FROM 
(
	SELECT DISTINCT s.SongID,
		   SUBSTRING_INDEX(SUBSTRING_INDEX(s.Name_, ' ', ints.i + 1), ' ', -1) AS Word
	FROM music.Song AS s, music.ints AS ints
) AS temp1
GROUP BY Word
HAVING COUNT(*) > 2 -- KEEP RESULT SHORT
ORDER BY 2 DESC
;
        
-- FINALLY, LET'S INVESTIGATE IF THERE IS A LINK BETWEEN THE NUMBER OF WORDS IN A SONG TITLE 
-- AND IT'S DURATION, OR AMOUNT OF APPEARENCES IN A PLAYLIST
SELECT LENGTH(s.Name_) - LENGTH(REPLACE(s.Name_, ' ', '')) + 1 AS `Title length`,
	   COUNT(s.SongID) AS `Number of songs`,
	   AVG(s.Duration) AS `Average song length`,
       COUNT(pt.TrackNo) / COUNT(s.SongID) AS `Average number of playlist appearences`
FROM music.Song AS s
LEFT JOIN music.PlaylistTrack AS pt
	ON s.SongID = pt.SongID
GROUP BY 1
;