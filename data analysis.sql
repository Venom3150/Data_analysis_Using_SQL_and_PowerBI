-- Creating the copy of the raw datasets
CREATE TABLE copied_pizza_sale 
LIKE pizza_sales;

-- Inserting the values into the copied dataset
INSERT copied_pizza_sale
SELECT *
FROM pizza_sales;

-- Checking the copied dataset 
SELECT * 
FROM copied_pizza_sale;

-- Data Cleaning
-- 1. Checking for duplicate values
WITH duplicate_pizza_data AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY pizza_id, order_id,pizza_name_id, quantity, order_date, order_time, unit_price,
			total_price,pizza_size, pizza_category, pizza_ingredients, pizza_name) as row_num
FROM copied_pizza_sale)

SELECT *
FROM duplicate_pizza_data
WHERE row_num > 1;


-- 2. Checking the null values
SELECT * 
FROM copied_pizza_sale
WHERE pizza_id IS NULL;  # Checking if the pizza_id is null

SELECT * 
FROM copied_pizza_sale
WHERE order_id IS NULL;  # Checking if the order id is null

SELECT * 
FROM copied_pizza_sale
WHERE pizza_name_id IS NULL; # Checking if the pizza_name_id is null

SELECT * 
FROM copied_pizza_sale
WHERE quantity IS NULL; # Checking if the quantity is null

SELECT * 
FROM copied_pizza_sale
WHERE order_date IS NULL; # Checking for the null order_date

SELECT * 
FROM copied_pizza_sale
WHERE order_time IS NULL; # Checking for the null order_time

SELECT * 
FROM copied_pizza_sale
WHERE unit_price IS NULL OR
	  total_price IS NULL OR
      pizza_size IS NULL OR
      pizza_category IS NULL OR
      pizza_ingredients IS NULL OR
      pizza_name IS NULL; 


-- 3. Standardize the data 
ALTER TABLE copied_pizza_sale
MODIFY COLUMN order_date DATE;

SELECT order_date, 
str_to_date(order_date,"%d-%m-%YYYY")
from copied_pizza_sale;

-- Change the datatypes of pizza_name_id
ALTER TABLE copied_pizza_sale
MODIFY COLUMN pizza_name_id VARCHAR(50);

ALTER TABLE copied_pizza_sale 
MODIFY column pizza_size VARCHAR(50);

ALTER TABLE copied_pizza_sale
MODIFY COLUMN pizza_category VARCHAR(50);


ALTER TABLE copied_pizza_sale
MODIFY COLUMN pizza_ingredients VARCHAR(150);

ALTER TABLE copied_pizza_sale
MODIFY COLUMN pizza_name VARCHAR(75);

ALTER TABLE copied_pizza_sale
ADD CONSTRAINT pk primary key(pizza_id);

SELECT order_date, order_time
FROM copied_pizza_sale;


-- 1. Total Revenue: 

SELECT CONCAT("$ ",ROUND(SUM(total_price),3) )as total_revenue # Concatinated with the dollar sign and rounded in 3 decimal point
FROM copied_pizza_sale;

-- 2. Average Order values

SELECT ((Round(SUM(total_price) / COUNT(DISTINCT order_id),2))) AS Average_Order_value
FROM copied_pizza_sale;


-- 3. Total Pizza Sold

SELECT SUM(quantity) as Total_pizza_sold
FROM copied_pizza_sale;

-- 4. Total Orders

SELECT COUNT(DISTINCT order_id) as Total_order
FROM copied_pizza_sale;

-- 5. Average Pizzas per order

SELECT SUM(quantity) / COUNT(DISTINCT order_id) as Average_Pizza_Per_Order
FROM copied_pizza_sale;



-- Daily Trend For Total Orders
SELECT DAYNAME(order_date) as Week_days, COUNT(DISTINCT order_id) as Total_orders
FROM copied_pizza_sale
GROUP BY DAYNAME(order_date);

-- Monthly Trend For Total Orders

SELECT MONTHNAME(order_date) as Month_of_Year, COUNT(DISTINCT order_id) Total_orders
FROM copied_pizza_sale
GROUP BY MONTHNAME(order_date)
ORDER BY 2 DESC;

SELECT ROUND(SUM(total_price),2)
FROM copied_pizza_sale;

-- Percentage of Sales by Pizza Category
SELECT pizza_category,  ROUND(SUM(total_price),2) as Total_Sales,
ROUND((SUM(total_price)/ (SELECT SUM(total_price) FROM copied_pizza_sale)* 100 ),2)AS Percentage
FROM copied_pizza_sale
GROUP BY pizza_category
ORDER BY 2 DESC;

# Filter by Month
SELECT pizza_category,  ROUND(SUM(total_price),2) as Total_Sales,
ROUND((SUM(total_price)/ (SELECT SUM(total_price) FROM copied_pizza_sale WHERE MONTH(order_date) = 1)* 100 ),2)AS Percentage
FROM copied_pizza_sale
WHERE MONTH(order_date) = 1
GROUP BY pizza_category
ORDER BY 2 DESC;


-- Percentage of sales by Pizza size 

SELECT pizza_size, ROUND(SUM(total_price),2) as Total_sale, 
ROUND(SUM(total_price) * 100 / (SELECT sum(total_price) FROM copied_pizza_sale),2) as Percentage_Sales
FROM copied_pizza_sale
GROUP BY pizza_size;

# Based on the quarters 
SELECT pizza_size, ROUND(SUM(total_price),2) as Total_sale, 
ROUND(SUM(total_price) * 100 / (SELECT sum(total_price) FROM copied_pizza_sale WHERE QUARTER(order_date) = 1),2) as Percentage_Sales
FROM copied_pizza_sale
WHERE QUARTER(order_date) = 1
GROUP BY pizza_size;


-- Total Pizzas Sold by Pizza Category
SELECT pizza_category, SUM(quantity) AS Total_pizza_sold
FROM copied_pizza_sale
GROUP BY pizza_category;


-- Top selling pizzas by revenue

SELECT pizza_name, SUM(total_price) as Highest_Revenue
From copied_pizza_sale
GROUP BY pizza_name
ORDER BY 2 DESC
limit 5;

-- Bottom 5 selling pizzas 
SELECT pizza_name, SUM(total_price) as Lowest_Revenue
From copied_pizza_sale
GROUP BY pizza_name
ORDER BY 2 
limit 5;


-- Bottom 5 selling pizzas based on quantity
SELECT pizza_name, SUM(quantity) as Lowest_quantity
From copied_pizza_sale
GROUP BY pizza_name
ORDER BY 2 ASC
limit 5;

-- Top 5 selling pizzas based on quantity
SELECT pizza_name, SUM(quantity) as Highest_quantity
From copied_pizza_sale
GROUP BY pizza_name
ORDER BY 2 DESC
limit 5;







