-- NETFLIX DATA ANALYTICS USING SQL

DROP TABLE IF EXISTS Netflix;
CREATE TABLE netflix
(
show_id	VARCHAR(6),
type	VARCHAR(10),
title	VARCHAR(150),
director	VARCHAR(208),
casts	VARCHAR(1000),
country	VARCHAR(150),
date_added	VARCHAR(50),
release_year	INT,
rating	VARCHAR(10),
duration	VARCHAR(15),
listed_in	VARCHAR(100),
description VARCHAR(250)
)

SELECT * FROM netflix;

SELECT COUNT(*) AS total_content 
FROM netflix;

SELECT distinct(type) 
FROM netflix;

-- 20 Business Problems & Solutions
SELECT * FROM netflix;

--1. Count the number of Movies vs TV Shows

SELECT type, COUNT(*)
FROM netflix
GROUP BY type;


--2. Find the most common rating for movies and TV shows

-- create table t1 with Ranking of the ratings of Movies and TV shows as a subquery. 
--Then, select from the subquery to find the most common rating

SELECT type, rating, count
FROM
(
	SELECT 
		type, 
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix
	GROUP BY 1,2
) AS t1
WHERE 
	ranking = 1


--3. List all movies released in a specific year - 2020

SELECT title 
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;


--4. Find the top 5 countries with the most content on Netflix

SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country, COUNT(*) 
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


--5. Identify the longest movie

SELECT title, new_duration :: DECIMAL
FROM 
(
SELECT title, UNNEST(STRING_TO_ARRAY(duration, ' ')) AS new_duration
FROM netflix
WHERE type = 'Movie' 
ORDER BY duration DESC
)
WHERE new_duration != 'min'
ORDER BY new_duration DESC
LIMIT 1;


--7. Find content added in the last 5 years

SELECT title, DATE_PART('YEAR', date_added :: DATE) AS year_added
FROM netflix
WHERE date_added IS NOT NULL AND ( DATE_PART('YEAR', date_added :: DATE) IN (2021,2020,2019,2018,2017)  )
ORDER BY year_added DESC


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM
(
SELECT title, UNNEST(STRING_TO_ARRAY(director, ',')) AS director_new
FROM netflix
)
WHERE director_new = 'Rajiv Chilaka'

--8. List all TV shows with more than 5 seasons


SELECT 
	title, 
	(SPLIT_PART(duration, ' ', 1)  :: NUMERIC) AS seasons
FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration, ' ', 1) :: NUMERIC > 5
ORDER BY seasons DESC


--9. Count the number of content items in each genre

SELECT  UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre, count(*)
FROM netflix
GROUP BY genre
ORDER BY genre;

--10.Find each year and the average numbers of content release in India on netflix.
--return top 5 year with highest avg content release!


DROP VIEW IF EXISTS TABLE1;
create view TABLE1 AS 
SELECT *
FROM 
(SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS country_new, *
FROM netflix)
WHERE country_new = 'India' 


SELECT 
	EXTRACT (YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year, 
	COUNT(*),
	ROUND(
	COUNT(*) :: numeric /(SELECT COUNT(*) FROM TABLE1 ) :: numeric * 100 
	, 2)  AS avg_content_per_year
FROM 
(SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS country_new, *
FROM netflix)
WHERE country_new = 'India' 
GROUP BY year
ORDER BY count(*) DESC


--11. List all movies that are documentaries

SELECT title, listed_in
FROM netflix 
WHERE type = 'Movie' AND listed_in ILIKE '%documentaries%' 

--12. Find all content without a director

SELECT *
FROM netflix 
WHERE director IS NULL


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!


SELECT title, release_year
FROM netflix 
WHERE casts LIKE '%Salman Khan%' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE ) - 10
ORDER BY release_year DESC


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT DISTINCT(UNNEST(STRING_TO_ARRAY(casts, ','))) as actor, count(*) AS number_of_hits
FROM netflix 
WHERE country ILIKE '%india%' and type = 'Movie'
GROUP BY actor
ORDER BY number_of_hits DESC
LIMIT 10


--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.


SELECT
	CASE WHEN 
		description ILIKE '%kill%' OR 
		description ILIKE '%violence%' THEN 'Bad_Content'
		ELSE 'Good Content'
	END category,
	count(*)
FROM netflix
GROUP BY category


--16. List all movies released in the United States. 

SELECT * 
FROM netflix 
WHERE country ILIKE '%united states%' AND type = 'Movie'

-- 17. List all TV Shows labeled as comedies in the United States with the rating of 'TV-MA'

SELECT * 
FROM netflix 
WHERE type = 'TV Show'
AND listed_in ILIKE '%comed%' 
AND country ILIKE '%united states%'
AND rating ILIKE '%MA%'

-- 18. Find the top 10 actors who have appeared in the highest number of TV shows produced in the United States.

SELECT DISTINCT(UNNEST(STRING_TO_ARRAY(casts, ','))) as actor, count(*) AS number_of_hits
FROM netflix 
WHERE country ILIKE '%united states%' and type = 'TV Show'
GROUP BY actor
ORDER BY number_of_hits DESC
LIMIT 10

-- 19. Count the number of TV shows in each genre in the United States

SELECT  UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre, count(*)
FROM netflix
WHERE country ILIKE '%united states%' and type = 'TV Show'
GROUP BY genre
ORDER BY count desc;

--20.  List all content with the word ‘Love’ in the title coming under the category of Romance. 


SELECT  *  
FROM netflix
WHERE title ILIKE '% love %' and listed_in ILIKE '%Rom%';