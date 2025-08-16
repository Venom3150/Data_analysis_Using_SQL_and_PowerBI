# Data Analysis Using SQL and Power BI

# Overview
This project presents a comprehensive data analysis of a pizza sales dataset. The primary objective is to extract valuable insights, identify key sales trends, and answer critical business questions to help a fictional pizza company optimize its operations and strategy. The analysis is performed using MySQL for data cleaning and querying, with the results visualized in a Power BI dashboard.

# Dataset
The dataset for this project is a `pizza_sales.csv` file, which contains detailed information about a year's worth of pizza sales. It includes data on order details, pizza names, prices, sizes, and ingredients.

# Tools 
- MySQL: Used for data cleaning, preparation, and querying to answer business questions.
- Power BI: Utilized to create an interactive dashboard for visualizing the key findings.

# Data Cleaning & Preparation
Before working on the project it is better to make sure that the raw dataset remains untouched which can benefit with reproducibility, data integrity and audit trial. It is carried out in MySQL as follows: 
```sql
-- Creating the copy of the raw datasets
CREATE TABLE copied_pizza_sale 
LIKE pizza_sales;

-- Inserting the values into the copied dataset
INSERT copied_pizza_sale
SELECT *
FROM pizza_sales;
```
Now, the project is carried out in following steps: 
1. Duplicate Check: A query was run to ensure there were no duplicate records.
```sql
WITH duplicate_pizza_data AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY pizza_id, order_id,pizza_name_id, quantity,
                            order_date, order_time, unit_price,total_price,pizza_size,
                            pizza_category, pizza_ingredients, pizza_name) as row_num
FROM copied_pizza_sale)

SELECT *
FROM duplicate_pizza_data
WHERE row_num > 1;
```
2. Check for the null values: Each column was checked for null or empty values.
```sql
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
```

3. Data Standardization: Data types for columns such as `order_date`,`pizza_name_id`,`pizza_size` etc., were modified for consistency and to ensure proper query execution. And assigned `pizza_id` as the primary key. 
```sql
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
```

The dataset is now in the standard format and we can dive deeper to answer the business questions. 

# Business Questions & SQL Queries
The analysis was focused on answering key business questions related to sales performance, customer behavior, and product popularity.

**Key Performance Indicators (KPIs):**
The following queries were used to calculate core business metrics.

**1. Total Revenue:** This metric provides a high-level overview of the company's financial performance by summing up the total price of all sales transactions.
```sql
SELECT CONCAT("$ ",ROUND(SUM(total_price),3) )as total_revenue    # Concatinated with the dollar sign and rounded in 3 decimal point
FROM copied_pizza_sale;
```

**2. Average Order Value:** This KPI measures the average amount spent per order, which helps to understand typical customer spending behavior and can inform pricing and upselling strategies.
```sql
SELECT ((Round(SUM(total_price) / COUNT(DISTINCT order_id),2))) AS Average_Order_value
FROM copied_pizza_sale;
```

**3. Total Pizzas Sold:** A straightforward count of all pizzas sold, this metric indicates the overall demand and popularity of the products.
```sql
SELECT SUM(quantity) as Total_pizza_sold
FROM copied_pizza_sale;
```

**4. Total Orders:** This provides a count of the total number of unique transactions, which is a key indicator of business volume and customer traffic.
```sql
SELECT COUNT(DISTINCT order_id) as Total_order
FROM copied_pizza_sale;
```

**5. Average Pizzas per Order:** This metric calculates the average quantity of pizzas bought per transaction, offering insights into customer purchase patterns and potential for bundle deals.
```sql
SELECT SUM(quantity) / COUNT(DISTINCT order_id) as Average_Pizza_Per_Order
FROM copied_pizza_sale;
```

# Daily & Monthly Sales Trends
Queries were executed to identify sales patterns over time:

**Daily Trend for Total Orders:** This analysis helps identify which days of the week are the busiest, which is essential for optimizing staffing levels and managing inventory.
```sql
SELECT DAYNAME(order_date) as Week_days, COUNT(DISTINCT order_id) as Total_orders
FROM copied_pizza_sale
GROUP BY DAYNAME(order_date);
```
The screenshot of the result and its visualization are given below side by side.
![](https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/daily_trend%20sql.png) 
![](https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/Daily%20trend.png)
