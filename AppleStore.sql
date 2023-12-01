CREATE TABLE AppleStore_Description_Combined AS

SELECT * FROM appleStore_description1
UNION ALL
SELECT * FROM appleStore_description2
UNION ALL
SELECT * FROM appleStore_description3
UNION ALL
SELECT * FROM appleStore_description4

/* In this project, we will pretend that we aim to assist an app developer in understanding
which app category is most prevalent, at what price to sell it, 
and how to maximize user ratings */

--> EXPLORATORY DATA ANALYSIS

-- Check the number of unique apps in both Tables

SELECT COUNT (DISTINCT id) AS UniqueAppIds
FROM AppleStore
--7197
SELECT COUNT (DISTINCT id) AS UniqueAppIds
FROM AppleStore_Description_Combined
--7197 = no missing

-- Check for any missing values in key fields 
SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name is NULL or user_rating is NULL or prime_genre is NULL
--0
SELECT COUNT(*) AS MissingValues
FROM AppleStore_Description_Combined
WHERE app_desc is NULL 
--0

-- Find the App Number for genre

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
group by prime_genre
ORDER BY NumApps DESC
-- Games 3862
-- Entertaiment 535
-- Education 453
-- ...

-- Get an Overview of the Apps Ratings
SELECT min(user_rating) as MinRating, max(user_rating) as MaxRating, avg(user_rating) as AvgRating
FROM AppleStore
-- min 0 - max 5 - avg 3.5

--> FINDING THE INSIGHTS **DATA ANALYSIS**
--Determine if paid apps have highter rating than free apps

SELECT CASE
			WHEN price > 0 then 'Paid'
            ELSE 'Free'
		end as App_type,
        avg(user_rating) as Avg_Rating
FROM AppleStore
GROUP BY App_type
-- Free 3.3 - Paid 3.7

-- Check if apps that support multiple languages have higher ratings
SELECT CASE
			WHEN lang_num < 10 THEN '<10 Languages'
            WHEN lang_num BETWEEN 10 and 30 then '10-30 Languages'
            ELSE '>30 Languages'
		end as Language_bucket,
        avg(user_rating) as Avg_Rating
FROM AppleStore
GROUP BY Language_bucket
ORDER by Avg_Rating DESC
-- 10-30= 4.1 - >30= 3.7 - <10 3.3 


-- Check Genre with lower ratings
SELECT prime_genre, avg(user_rating) as Avg_Rating
from AppleStore
GROUP BY prime_genre
ORDER by Avg_Rating ASC
LIMIT 10
-- Catalogs = 2.1 - Finance = 2.4 - Book = 2.4


-- Check if there a correlation between lenght description and user rating
SELECT CASE
			WHEN length(b.app_desc) <500 THEN 'short'
            WHEN length(b.app_desc) BETWEEN 500 and 1000 THEN 'medium'
            else 'long'
		End as description_length_bucket,
        avg(a.user_rating) AS average_rating
FROM
	AppleStore as A
join 
	AppleStore_Description_Combined as b
ON
	a.id = b.id
GROUP by description_length_bucket
ORDER BY average_rating DESC
-- long = 3.8 - medium = 3.2 - short = 2.5


-- Check top-rated apps for genre
SELECT prime_genre, track_name, user_rating
FROM (
  	SELECT prime_genre, track_name,user_rating,
    RANK() OVER (PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) as Rank
    from AppleStore
    ) as a
WHERE a.rank = 1
-- 1. Color Therapy Adult.. 2. TurboScan Pro 3. CPlus for Craiglist app...

/* FINAL RACCOMANDATION:
1-> Paid apps have better ratings (more engagement or perceived value?)
2-> Supporting languages between 10 and 30 have better ratings (more is not always better)
3-> Book and Finance have lower ratings (is good opportunity for quality app?)
4-> Positive Correlation between app length description and user rating (longer is better)
5-> A new app should target an average rating above 3.5
6-> Games and Entertaiment have high competition (saturated?)



