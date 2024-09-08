--Netflix Movies & TV Shows Data Analysis:-
-- 15 Business Problems & Solutions


--> 1. Count the number of Movies vs TV Shows.

select count(*) as 
from netflix

select 
	  type,
	  count(*) as Total_Content
from netflix
group by 1;

--Movies 6131
-- TV Shows 2676 
-- total = 8807
--> 2. Find the most common rating for movies and TV shows.
with Ratingcounts as
(
	select   type,
			rating,
			count(*) as rating_count
	from netflix
	group by 1,2
	order by 3 desc
),
Rankedratings AS
(
	select 
		   type,
		   rating,
		   rating_count,
		   dense_rank()over(partition by type order by rating_count desc ) as dranks
	from Ratingcounts   
)
SELECT 
    type,
    rating AS most_frequent_rating,
	rating_count,
	dranks
FROM RankedRatings
WHERE dranks = 1;

--> 3. List all movies released in a specific year. (e.g., 2020)

SELECT * 
FROM netflix
WHERE type = 'Movie' 
      AND 
	  release_year = 2020;

--> 4. Find the top 5 countries with the most content on Netflix.
select 
		unnest(string_to_array(country,',')) as Country,
		count(*) as total_content
from netflix
group by 1
having count(*) is not null
order by total_content desc 
limit 5;

--> 5. Identify the longest movie.
select
    *
from netflix
where type = 'Movie'
order by SPLIT_PART(duration, ' ', 1)::int desc;	 

select
    *
from netflix
where type = 'Movie' and duration = (select max(duration) from netflix)

--> 6. Find content added in the last 5 years.
select 
   *
from netflix
where to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 year';

--> 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * 
from netflix
where director ilike '%Rajiv Chilaka%'

--OR-----------------------------------------------------------------------------------------------------------
select
  * 
from 
( select 
          *,
	      unnest(string_to_array(director, ',')) as director_name
		from netflix	 
) as a
where director_name = 'Rajiv Chilaka';

--> 8. List all TV shows with more than 5 seasons.
select 
	* 
from netflix
where type = 'TV Show'
       and 
	 split_part(duration, ' ', 1)::numeric > 5 ;

--> 9. Count the number of content items in each genre.
select
		unnest(string_to_array(listed_in, ' ')) as genre,
		count(show_id) as total_content
from netflix
group by 1
order by 2 desc;

--> 10. Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!
-- filter india,
--group by year,avg(content_release)


SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

--> 11. List all movies that are documentaries.
select * 
from netflix
where
	  listed_in like '%Documentaries%';

--> 12. Find all content without a director.

select * 
from netflix
where director is null;

--> 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select *
from netflix
where 
	 casts like '%Salman Khan%'
           and 
	release_year > extract(year from current_date) - 10;

--> 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select 
		unnest(string_to_array(casts, ',')) as actor_name,
		count(*) as total_apperance
from netflix
where country ='India'
group by 1
order by 2 desc
limit 10;

/* 15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
Label content containing these keywords as 'Bad' and all other content as 'Good'. 
Count how many items fall into each category.*/ 
select labels,
		count(labels) as lab_count
from 
(
 select 
		description,
		case
		    when description ilike '%Kill%' or description ilike '%violence%' then 'Bad'
		else 'Good'	
		end as labels
 from netflix
) as categorised_content
group by 1;



















	
	 








