# Netflix Movies and TV Shows Analysis using SQL
Netflix Content Analytics (Years 2015 - 2021)

![Netflix Logo](https://github.com/araghavan22/Netflix_SQL_Content_Analytics_Project/blob/main/Netflix%20Logo.jpg)

## Project Overview
This project explores Netflix's content library using SQL, providing insights into genre distribution, content trends, and regional availability. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.It includes data cleaning, exploratory data analysis (EDA), and query optimization to uncover meaningful patterns.

## 🚀 Objectives
Analyze the distribution of content types (movies vs TV shows).
Identify the most common ratings for movies and TV shows.
List and analyze content based on release years, countries, and durations.
Explore and categorize content based on specific criteria and keywords.

## 📌 Dataset 
The data for this project is sourced from the Kaggle dataset: https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download
## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
```
## 20 Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows
**Objective:** Determine the distribution of content types on Netflix.
```sql
SELECT type, COUNT(*)
FROM netflix
GROUP BY type;
```


### 2. Find the Most Common Rating for Movies and TV Shows
**Objective:** Identify the most frequently occurring rating for each type of content.
```sql
SELECT t1.type, t1.rating, count
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
```



### 3. List All Movies Released in a Specific Year (e.g., 2020)
**Objective:** Retrieve all movies released in a specific year.
```sql
SELECT title 
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;
```



### 4. Find the Top 5 Countries with the Most Content on Netflix
**Objective:** Identify the top 5 countries with the highest number of content items.

```sql
SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country, COUNT(*) 
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```



### 5. Identify the Longest Movie
**Objective:** Find the movie with the longest duration.
```sql
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
```



### 6. Find Content Added in the Last 5 Years
**Objective:** Retrieve content added to Netflix in the last 5 years.
```sql
SELECT title, DATE_PART('YEAR', date_added :: DATE) AS year_added
FROM netflix
WHERE date_added IS NOT NULL AND ( DATE_PART('YEAR', date_added :: DATE) IN (2021,2020,2019,2018,2017)  )
ORDER BY year_added DESC
```



### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
**Objective:** List all content directed by 'Rajiv Chilaka'.
```sql
SELECT *
FROM
(
SELECT title, UNNEST(STRING_TO_ARRAY(director, ',')) AS director_new
FROM netflix
)
WHERE director_new = 'Rajiv Chilaka';
```


### 8. List All TV Shows with More Than 5 Seasons
**Objective:** Identify TV shows with more than 5 seasons.
```sql
SELECT 
	title, 
	(SPLIT_PART(duration, ' ', 1)  :: NUMERIC) AS seasons
FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration, ' ', 1) :: NUMERIC > 5
ORDER BY seasons DESC;
```



### 9. Count the Number of Content Items in Each Genre
**Objective:** Count the number of content items in each genre.
```sql
SELECT  UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre, count(*)
FROM netflix
GROUP BY genre
ORDER BY genre;
```



### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!
**Objective:** Calculate and rank years by the average number of content releases by India.
```sql
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
```

### 11. List All Movies that are Documentaries
**Objective:** Retrieve all movies classified as documentaries.
```sql
SELECT title, listed_in
FROM netflix 
WHERE type = 'Movie' AND listed_in ILIKE '%documentaries%' 
```



### 12. Find All Content Without a Director
**Objective:** List content that does not have a director.
```sql
SELECT *
FROM netflix 
WHERE director IS NULL;
```


### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.
```sql
SELECT title, release_year
FROM netflix 
WHERE casts LIKE '%Salman Khan%' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE ) - 10
ORDER BY release_year DESC;
```



### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.
```sql
SELECT DISTINCT(UNNEST(STRING_TO_ARRAY(casts, ','))) as actor, count(*) AS number_of_hits
FROM netflix 
WHERE country ILIKE '%india%' and type = 'Movie'
GROUP BY actor
ORDER BY number_of_hits DESC
LIMIT 10;
```


### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.
```sql
SELECT
	CASE WHEN 
		description ILIKE '%kill%' OR 
		description ILIKE '%violence%' THEN 'Bad_Content'
		ELSE 'Good Content'
	END category,
	count(*)
FROM netflix
GROUP BY category;
```
### 16. List all movies released in the United States. 
**Objective:** Retrieve all movies that were released in the country United States.
```sql
SELECT * 
FROM netflix 
WHERE country ILIKE '%united states%' AND type = 'Movie';
```

### 17. List all TV Shows labeled as comedies in the United States with the rating of 'TV-MA'.
**Objective:** Retrieve all TV Shows that were released in the country United States for a mature audience.
```sql
SELECT * 
FROM netflix 
WHERE type = 'TV Show'
AND listed_in ILIKE '%comed%' 
AND country ILIKE '%united states%'
AND rating ILIKE '%MA%';
```

###  18. Find the top 10 actors who have appeared in the highest number of TV shows produced in the United States.
**Objective:** List the top 10 actos who have played the most roles for TV shows released in the United States.
```sql
SELECT DISTINCT(UNNEST(STRING_TO_ARRAY(casts, ','))) as actor, count(*) AS number_of_hits
FROM netflix 
WHERE country ILIKE '%united states%' and type = 'TV Show'
GROUP BY actor
ORDER BY number_of_hits DESC
LIMIT 10;
```

###  19. Count the number of TV shows in each genre in the United States.
**Objective:** Count the number of TV shows released in the United States under each genre.
```sql
SELECT  UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre, count(*)
FROM netflix
WHERE country ILIKE '%united states%' and type = 'TV Show'
GROUP BY genre
ORDER BY count desc;
```

###  20. List all content with the word ‘Love’ in the title coming under the category of Romance.
**Objective:** Show all TV Shows and Movies that have 'Love' in the title which come under the genre of Romance.
```sql
SELECT  *  
FROM netflix
WHERE title ILIKE '% love %' and listed_in ILIKE '%Rom%';
```

## 📊 Key Analyses
- Content Distribution: Analyzing content by genre, release year, and country.
- Movies vs. TV Shows Trends: Identifying patterns in Netflix’s content over time.
- Content Acquisition Strategy: Examining how Netflix expands its catalog.
- Popular Directors & Actors: Extracting insights on frequently featured artists

## 🛠 Tech Stack
- Database: PostgreSQL
- Tools: SQL queries, CTEs, Window Functions, Aggregations

## 📈 Results & Insights
- Content Distribution: The dataset contains a diverse range of movies and TV shows with       
  varying ratings and genres.
- Common Ratings: Insights into the most common ratings provide an understanding of the 
  content's target audience.
- Geographical Insights: The top countries and the average content releases highlight 
  regional content distribution.
- Content Categorization: Categorizing content based on specific keywords helps in 
  understanding the nature of content available on Netflix.

## 🤝 Contributing
Contributions are welcome! Feel free to submit issues or pull requests.

## 📜 License
This project is licensed under the MIT License.
