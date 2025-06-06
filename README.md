# Zomato-data-analysis

## Project Overview

Project Title: Zomato Restaurant Analysis
Level: Intermediate–Advanced
Database: Zomato Project

## Objectives

**Data Import & Setup**: Import and structure a comprehensive Zomato dataset.

**Data Cleaning**: Identify and handle missing or null values.

**Exploratory Data Analysis (EDA)**: Perform basic analysis to understand data dimensions and patterns.

**Business Analysis**: Use SQL to derive insights for location trends, customer preferences, and restaurant performance.

**Advanced Analytics**: Leverage CTEs, ranking, and window functions for deep dives into city-wise and cuisine-wise trends.


## Project Structure

### Database Setup

**Database Creation**: The project begins by creating a database named zomato_db.

**Table Creation**

The table zomato contains:

RestaurantID, RestaurantName, CountryCode, City, Address, Locality, LocalityVerbose,

Cuisines, Currency, Has_Table_booking, Has_Online_delivery, Is_delivering_now,

Switch_to_order_menu, Price_range, Votes, Average_Cost_for_two, Rating

CREATING TABLE

```sql
CREATE TABLE zomato_dataset (
    RestaurantID INT,
    RestaurantName TEXT,
    CountryCode INT,
    City TEXT,
    Address TEXT,
    Locality TEXT,
    LocalityVerbose TEXT,
    Cuisines TEXT,
    Currency TEXT,
    Has_Table_booking TEXT,
    Has_Online_delivery TEXT,
    Is_delivering_now TEXT,
    Switch_to_order_menu TEXT,
    Price_range INT,
    Votes INT,
    Average_Cost_for_two FLOAT,
    Rating FLOAT
);
```
2. Data Exploration & Cleaning
Record Count:
```sql
 SELECT COUNT(*) FROM zomato;
```
Unique Cities:
```sql
SELECT COUNT(DISTINCT City) FROM zomato;
```
Cuisine Types:
```sql
SELECT DISTINCT Cuisines FROM zomato;
```
Null Values Check:

```sql
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
```
3. Data Analysis & Key SQL Queries

🔰 Beginner

1. List all unique cities where restaurants are located.
2. Find all restaurants that offer online delivery.
3. Get names of restaurants in ‘Augusta’ with a rating greater than 4.5
4. Count how many restaurants have table booking available.
5. List all distinct cuisines available in the dataset.

⚙️ Intermediate

1. Which cuisine has the highest average rating?
2. Find the number of restaurants in each country.
3. Get the total votes received by restaurants in each city, sorted descending.
4. Compare the average cost for two between restaurants with and without online delivery.
5. Which locality has the most restaurants

🧠 Advanced

1. Get the top 3 cuisines by average rating in each city.
2. Find the city with the highest average restaurant rating, considering only cities with more than 10 restaurants.
3. Get restaurants with rating above city average rating.
4. Find the most popular cuisine (highest votes) per city.
5. Identify restaurants with above-average votes and below-average cost in their respective city.
6. Generate a ranking of restaurants in each city based on rating and votes using window functions.

-------------------------------------------------------------------------------------------------------------

## SOLVING QUERIES :

--1.List all unique cities where restaurants are located.
```sql
SELECT DISTINCT city FROM zomato_dataset;
```
--2.Find all restaurants that offer online delivery.
```sql
SELECT restaurantname FROM zomato_dataset
WHERE has_online_delivery = 'Yes';
```
--3.Get names of restaurants in ‘Augusta’ with a rating greater than 4.5
```sql
SELECT * FROM zomato_dataset
WHERE city = 'Augusta' AND rating > 4.5;
```
--4.Count how many restaurants have table booking available.
```sql
SELECT COUNT(*) AS TablebookingRestaurants FROM zomato_dataset
WHERE has_table_booking = 'Yes';
```
--5.List all distinct cuisines available in the dataset.
```sql
SELECT DISTINCT cuisines, COUNT(cuisines) AS Number_of_Restaurants FROM zomato_dataset
GROUP BY cuisines
ORDER BY COUNT(cuisines) DESC;
```
--6.Which cuisine has the highest average rating?
```sql
SELECT cuisines, AVG(rating)FROM zomato_dataset
GROUP BY cuisines
ORDER BY 2 DESC
LIMIT 1;
```
--7.Find the number of restaurants in each country.
```sql
SELECT countrycode, COUNT(*)
FROM zomato_dataset
GROUP BY countrycode
ORDER BY 2 DESC;
```
--8.Get the total votes received by restaurants in each city, sorted descending.
```sql
SELECT city, SUM(votes) AS total_votes FROM zomato_dataset
GROUP BY city
ORDER BY 2 DESC;
```
--9.Compare the average cost for two between restaurants with and without online delivery.
```sql
SELECT has_online_delivery, ROUND(AVG(average_cost_for_two)) AS avg_cost_for_two
FROM zomato_dataset
GROUP BY has_online_delivery;
```
--10.Which locality has the most restaurants
```sql
SELECT locality, COUNT(*) AS restaurantcount FROM zomato_dataset
GROUP BY locality
ORDER BY 2 DESC
LIMIT 1;
```
--11.Get the top 3 cuisines by average rating in each city.
```sql
SELECT city, cuisines, rank FROM(
SELECT city, cuisines, AVG(rating),
RANK () OVER(PARTITION BY city ORDER BY AVG(rating) DESC) AS rank
FROM zomato_dataset
GROUP BY city, cuisines
)
WHERE rank <= 3;
```

--12.Find the city with the highest average restaurant rating, considering only cities with more than 10 restaurants.
```sql
SELECT city, ROUND(AVG(rating)) FROM zomato_dataset
GROUP BY city
HAVING COUNT(*) >10
ORDER BY AVG(rating) DESC
LIMIT 1;
```
--13.Get restaurants with rating above city average rating.
```sql
WITH cityavg AS (SELECT city, ROUND(AVG(rating)) as avg_rating FROM zomato_dataset
GROUP BY city
)
SELECT zomato_dataset.restaurantname, zomato_dataset.city, zomato_dataset.rating,
cityavg.avg_rating FROM zomato_dataset
JOIN cityavg ON zomato_dataset.city = cityavg.city
WHERE zomato_dataset.rating > cityavg.avg_rating
ORDER BY rating DESC;
```
--14.Find the most popular cuisine (highest votes) per city
```sql
SELECT * FROM(
SELECT city,cuisines, SUM(votes) total_votes,
RANK() OVER(PARTITION BY city ORDER BY SUM(votes) DESC ) as rank
FROM zomato_dataset
GROUP BY city,cuisines
) WHERE rank = 1
ORDER BY total_votes DESC;
```
--15.Identify restaurants with above-average votes and below-average cost in their respective city.
```sql
WITH cityavg AS(SELECT city, AVG(votes) AS avg_votes, AVG(average_cost_for_two) AS avg_cost
FROM zomato_dataset
GROUP BY city)
SELECT zomato_dataset.restaurantname, zomato_dataset.votes, zomato_dataset.average_cost_for_two
FROM zomato_dataset
JOIN cityavg ON zomato_dataset.city = cityavg.city
WHERE zomato_dataset.votes > cityavg.avg_votes AND zomato_dataset.average_cost_for_two < cityavg.avg_cost;
```
--16.Generate a ranking of restaurants in each city based on rating and votes using window functions.
```sql
SELECT city,restaurantname,rating,votes,
RANK() OVER(PARTITION BY restaurantname ORDER BY rating DESC,votes DESC)
FROM zomato_dataset;
```


## Findings

- **Restaurant Hotspots**: Cities like Delhi, Bangalore, and Mumbai have the highest number of restaurants. These places are buzzing with food options and lots of competition.

- **Cuisines People Love**: North Indian, Chinese, and Fast Food stand out as the most common cuisines. But depending on the city, preferences change—some cities favor Arabian or seafood more.

- **Cost vs Quality**: In many cities, you can find great food at a reasonable price. Good ratings aren’t limited to expensive places.

- **Top-Rated Favorites**: A few restaurants get most of the attention with high votes and ratings. These are likely people’s go-to spots with great service and consistent quality.

- **Online Delivery Matters**: Restaurants that offer online delivery often have more customer engagement. It shows that people value convenience when choosing where to eat.

## Reports:

- **City-Level Summary**: Shows how many restaurants are there in each city, their average rating, and how much they usually charge.

- **Cuisines Report**: Highlights which cuisines are popular, highly rated, or more likely to offer delivery or table booking.

- **Location Trends**: Helps compare different cities to see which ones have costlier food, better ratings, or more delivery options.

- **Top Restaurant Rankings**: Uses advanced SQL to rank the best restaurants based on rating and customer votes.

## Conclusion:

This project gave me a clear picture of how people dine and what they prefer in different cities. It wasn’t just about running SQL queries—it was about using data to understand real customer behavior, restaurant trends, and pricing strategies. Working on this helped me practice key SQL concepts like grouping, filtering, ranking, and handling real-world data. More importantly, I saw how data can answer important business questions, and that’s what makes analysis valuable. Whether it’s for a food delivery app or a restaurant chain, these insights can help make smarter decisions.

# Author
## Hrudai
BBA Graduate | Aspiring Data Analyst
SQL | Excel | Business Analysis
