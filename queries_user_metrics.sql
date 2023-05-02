-- INVESTIGATING THE PERCENTAGE OF ACCOUNTS THAT ARE ARTISTS VS USERS
WITH temp1 AS
(
	SELECT COUNT(AccountID) AS num1
	FROM music.Accounts
	WHERE AccountID IN 
	( 
		SELECT AccountID
		FROM Artist
	)
),
temp2 AS
(
	SELECT COUNT(*) AS num2
    FROM music.Accounts
)
SELECT temp1.num1 AS `Number of users who are artists`,
	   temp2.num2 - temp1.num1 AS `Number of users who aren't artists`
FROM temp1, temp2
;

-- LET'S LOOK AT SOME METRICS AROUND USER ACTIVITY, WHERE WE JUDGE ACTIVITY
-- BY THE NUMBER OF ARTISTS FOLLOWED
WITH temp1 AS
(
	SELECT u.UserID,
		   COUNT(f.ArtistID) AS num
	FROM music.Users AS u
	LEFT JOIN music.Follow AS f
		ON u.UserID = f.UserID
	GROUP BY 1
	ORDER BY 2 DESC
),
temp2 AS
(
	SELECT num,
		   ROW_NUMBER() OVER 
				(ORDER BY num
		   ) AS RN,
		   COUNT(num) OVER () AS cnt
	FROM temp1
)
SELECT AVG(num) AS `Mean number of artists followed`,
       MAX(num) AS `Most number of artists followed`,
       SUM(CASE WHEN num = 0 THEN 1 ELSE 0 END) AS `Number of users who follow no artists`,
       (
			SELECT num 
            FROM temp1 
            GROUP BY num 
            ORDER BY COUNT(num) DESC 
            LIMIT 1
		) AS `Modal number of artists followed`,
        (
			SELECT AVG(num)
            FROM temp2
            WHERE 2 * RN IN (cnt, cnt + 1, cnt + 2)
		) AS `Median number of artists followed`
FROM temp1
;
-- NOTHING TOO REMARKABLE HERE

-- LET'S SEE IF THERE'S ANY RELATIONSHIP BETWEEN USERS CREATING PLAYLISTS AND USERS
-- FOLLOWING LOTS OF ARTISTS, COMPARING TO THE ABOVE GLOBAL FIGURES
SELECT p.UserID,
	   COUNT(f.ArtistID) AS `Number of artists followed`
FROM music.Playlist AS p
LEFT JOIN music.Follow AS f
	ON f.UserID = p.UserID
GROUP by 1
ORDER BY 2 DESC
;
-- NO DIFFERENT TO USERS WHO DIDN'T CREATE PLAYLISTS!
