--DATA CLEANING
SELECT * FROM zomato_dataset
WHERE restaurantid IS NULL 
OR restaurantname IS NULL
OR countrycode IS NULL
OR city IS NULL
OR address IS NULL
OR locality IS NULL
OR localityverbose IS NULL
OR cuisines IS NULL
OR currency IS NULL
OR has_table_booking IS NULL
OR has_online_delivery IS NULL
OR is_delivering_now IS NULL
OR switch_to_order_menu IS NULL
OR price_range IS NULL
OR votes IS NULL
OR average_cost_for_two IS NULL
OR rating IS NULL;

DELETE FROM zomato_dataset
WHERE restaurantid IS NULL 
OR restaurantname IS NULL
OR countrycode IS NULL
OR city IS NULL
OR address IS NULL
OR locality IS NULL
OR localityverbose IS NULL
OR cuisines IS NULL
OR currency IS NULL
OR has_table_booking IS NULL
OR has_online_delivery IS NULL
OR is_delivering_now IS NULL
OR switch_to_order_menu IS NULL
OR price_range IS NULL
OR votes IS NULL
OR average_cost_for_two IS NULL
OR rating IS NULL;

--DATA ANALYSIS AND FINDINGS

--BEGINNER LEVEL

--1.List all unique cities where restaurants are located.
--2.Find all restaurants that offer online delivery.
--3.Get names of restaurants in ‘Augusta’ with a rating greater than 4.5
--4.Count how many restaurants have table booking available.
--5.List all distinct cuisines available in the dataset.
-----------------------------------------------------------------------------

--1.List all unique cities where restaurants are located.

SELECT DISTINCT city FROM zomato_dataset;

--2.Find all restaurants that offer online delivery.

SELECT restaurantname FROM zomato_dataset
WHERE has_online_delivery = 'Yes';

--3.Get names of restaurants in ‘Augusta’ with a rating greater than 4.5

SELECT * FROM zomato_dataset
WHERE city = 'Augusta' AND rating > 4.5;

--4.Count how many restaurants have table booking available.

SELECT COUNT(*) AS TablebookingRestaurants FROM zomato_dataset
WHERE has_table_booking = 'Yes';

--5.List all distinct cuisines available in the dataset.

SELECT DISTINCT cuisines, COUNT(cuisines) AS Number_of_Restaurants FROM zomato_dataset
GROUP BY cuisines
ORDER BY COUNT(cuisines) DESC;

--INTERMEDIATE LEVEL

--1.Which cuisine has the highest average rating?
--2.Find the number of restaurants in each country.
--3.Get the total votes received by restaurants in each city, sorted descending.
--4.Compare the average cost for two between restaurants with and without online delivery.
--5.Which locality has the most restaurants
-----------------------------------------------------------------------------------------------

--1.Which cuisine has the highest average rating?
SELECT cuisines, AVG(rating)FROM zomato_dataset
GROUP BY cuisines
ORDER BY 2 DESC
LIMIT 1;

--2.Find the number of restaurants in each country.
SELECT countrycode, COUNT(*)
FROM zomato_dataset
GROUP BY countrycode
ORDER BY 2 DESC;

--3.Get the total votes received by restaurants in each city, sorted descending.
SELECT city, SUM(votes) AS total_votes FROM zomato_dataset
GROUP BY city
ORDER BY 2 DESC;

--4.Compare the average cost for two between restaurants with and without online delivery.
SELECT has_online_delivery, ROUND(AVG(average_cost_for_two)) AS avg_cost_for_two
FROM zomato_dataset
GROUP BY has_online_delivery;

--5.Which locality has the most restaurants

SELECT locality, COUNT(*) AS restaurantcount FROM zomato_dataset
GROUP BY locality
ORDER BY 2 DESC
LIMIT 1;

--ADVANCE LEVEL

--1.Get the top 3 cuisines by average rating in each city.
--2.Find the city with the highest average restaurant rating, considering only cities with more than 10 restaurants.
--3.Get restaurants with rating above city average rating.
--4.Find the most popular cuisine (highest votes) per city.
--5.Identify restaurants with above-average votes and below-average cost in their respective city.
--6.Generate a ranking of restaurants in each city based on rating and votes using window functions.
---------------------------------------------------------------------------------------------------------------------

--1.Get the top 3 cuisines by average rating in each city.

SELECT city, cuisines, rank FROM(
SELECT city, cuisines, AVG(rating),
RANK () OVER(PARTITION BY city ORDER BY AVG(rating) DESC) AS rank
FROM zomato_dataset
GROUP BY city, cuisines
)
WHERE rank <= 3;


--2.Find the city with the highest average restaurant rating, considering only cities with more than 10 restaurants.

SELECT city, ROUND(AVG(rating)) FROM zomato_dataset
GROUP BY city
HAVING COUNT(*) >10
ORDER BY AVG(rating) DESC
LIMIT 1;

--3.Get restaurants with rating above city average rating.

WITH cityavg AS (SELECT city, ROUND(AVG(rating)) as avg_rating FROM zomato_dataset
GROUP BY city
)
SELECT zomato_dataset.restaurantname, zomato_dataset.city, zomato_dataset.rating,
cityavg.avg_rating FROM zomato_dataset
JOIN cityavg ON zomato_dataset.city = cityavg.city
WHERE zomato_dataset.rating > cityavg.avg_rating
ORDER BY rating DESC;

--4.Find the most popular cuisine (highest votes) per city

SELECT * FROM(
SELECT city,cuisines, SUM(votes) total_votes,
RANK() OVER(PARTITION BY city ORDER BY SUM(votes) DESC ) as rank
FROM zomato_dataset
GROUP BY city,cuisines
) WHERE rank = 1
ORDER BY total_votes DESC;

--5.Identify restaurants with above-average votes and below-average cost in their respective city.

WITH cityavg AS(SELECT city, AVG(votes) AS avg_votes, AVG(average_cost_for_two) AS avg_cost
FROM zomato_dataset
GROUP BY city)
SELECT zomato_dataset.restaurantname, zomato_dataset.votes, zomato_dataset.average_cost_for_two
FROM zomato_dataset
JOIN cityavg ON zomato_dataset.city = cityavg.city
WHERE zomato_dataset.votes > cityavg.avg_votes AND zomato_dataset.average_cost_for_two < cityavg.avg_cost;

--6.Generate a ranking of restaurants in each city based on rating and votes using window functions.

SELECT city,restaurantname,rating,votes,
RANK() OVER(PARTITION BY restaurantname ORDER BY rating DESC,votes DESC)
FROM zomato_dataset;

-------------------------------------------------------------------------------------------------------------