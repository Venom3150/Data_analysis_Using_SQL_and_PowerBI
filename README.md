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
<p align = "center">
	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/daily_trend%20sql.png" width = 30% height = 274px hspace = 20px>
 	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/Daily%20trend.png" width = 45% height = 300px>	
</p>

**Monthly Trend for Total Orders:** By breaking down sales by month, this trend analysis reveals seasonal patterns and peak sales periods, which can be used for long-term business planning and marketing campaigns.
```sql
SELECT MONTHNAME(order_date) as Month_of_Year, COUNT(DISTINCT order_id) Total_orders
FROM copied_pizza_sale
GROUP BY MONTHNAME(order_date)
ORDER BY 2 DESC;
```
The screenshot of the result and its visualization are given below side by side. 
<p align = "center">
	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/Monthly_trend_sql.png" width = 30% height= 290px hspace = 10px>
	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/Monthly%20Trend.png" widht = 45% height = 450px>
</p>

# Sales Distribution Analysis
To understand the product mix and customer preferences, the following distributions were analyzed:
- **Percentage of Sales by Pizza Category:** This metric breaks down total sales revenue by category (e.g., Classic, Veggie, Supreme), highlighting which types of pizzas are the most profitable.
```sql
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

```
The screenshot of the result and its visualization are show below side by side. 
<p align = "center">
	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/%25%20sales_category%20sql.png" width = 33% height= 280px hspace = 20px>
 	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/%25%20sales%20by%20category.png" widht = 50% height = 200px>
</p>


- **Percentage of Sales by Pizza Size:** This analysis shows the distribution of sales across different pizza sizes, providing insights into customer preferences that can inform pricing and production decisions.
```sql
SELECT pizza_size, ROUND(SUM(total_price),2) as Total_sale, 
ROUND(SUM(total_price) * 100 / (SELECT sum(total_price) FROM copied_pizza_sale),2) as Percentage_Sales
FROM copied_pizza_sale
GROUP BY pizza_size;

# Filter Base on Quarter
SELECT pizza_size, ROUND(SUM(total_price),2) as Total_sale, 
ROUND(SUM(total_price) * 100 / (SELECT sum(total_price) FROM copied_pizza_sale WHERE QUARTER(order_date) = 1),2) as Percentage_Sales
FROM copied_pizza_sale
WHERE QUARTER(order_date) = 1
GROUP BY pizza_size;
```
The screenshot of the result and its visualization are show below side by side. 
<p align = "center">
	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/%25sales_size%20sql.png" width = 49% height = 300px hspace = 20px>
	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/%25sales%20by%20size.png" widht = 50% height = 200px>
</p>

# Top and Bottom Performing Products
The project identified the most and least popular pizzas based on two key metrics: revenue and quantity sold.

- Top 5 Selling Pizzas by Revenue: Identifies the five pizzas that generated the most total revenue, which are likely candidates for continued promotion and menu highlights.
```sql
SELECT pizza_name, SUM(total_price) as Highest_Revenue
From copied_pizza_sale
GROUP BY pizza_name
ORDER BY 2 DESC
limit 5;
```
The screenshot of the result and its visualization are show below side by side. 
<p align = "center">
	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/high_rev_sql.png" height= "450" hspace = 20px>
 	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/high_rev.png"  height="240" >
</p>

- Bottom 5 Selling Pizzas by Revenue: Pinpoints the five lowest-revenue-generating pizzas, which could be considered for removal from the menu or for special promotional efforts.
```SQL
SELECT pizza_name, ROUND(SUM(total_price),2) as Lowest_Revenue
From copied_pizza_sale
GROUP BY pizza_name
ORDER BY 2 
limit 5;
```
The screenshot of the result and its visualization are show below side by side. 
<p align = "center">
	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/low_rev_sql.png" height= "500" hspace = 20px>
 	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/low_rev.png"  height="220" >
</p>

- Top 5 Selling Pizzas by Quantity: Identifies the five most frequently purchased pizzas, providing insight into which items are the most popular regardless of price.
```SQL
SELECT pizza_name, SUM(quantity) as Highest_quantity
From copied_pizza_sale
GROUP BY pizza_name
ORDER BY 2 DESC
limit 5;
```
The screenshot of the result and its visualization are show below side by side. 
<p align = "center">
	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/high_qnt_sql.png" height= "550" hspace = 20px>
 	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/high_qnt.png"  height="208" >
</p>


- Bottom 5 Selling Pizzas by Quantity: Identifies the least-purchased pizzas, which may signal a need for menu review or marketing changes.
```SQL
SELECT pizza_name, SUM(quantity) as Lowest_quantity
From copied_pizza_sale
GROUP BY pizza_name
ORDER BY 2 ASC
limit 5;
```
The screenshot of the result and its visualization are show below side by side. 
<p align = "center">
	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/low_qnt_sql.png" height= "550" hspace = 20px>
 	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/low_qnt.png"  height="210" >
</p>

# Key findings & insights
This section serves as a high-level summary of the analysis, providing actionable conclusions drawn from the SQL queries and Power BI visualizations.

-**Peak Sales Periods:** You've identified the busiest times for the business. This is crucial for operational planning. For example, knowing that Fridays and the month of July have the highest order volumes allows management to increase staffing and stock up on ingredients during these times to meet demand and prevent lost sales.

-**Sales Distribution:** By analyzing sales by category and size, you can provide key insights into product strategy. For instance, "Classic" pizzas are the most popular category and "Large" is the most popular size, the company can prioritize promoting those items on their menu and through marketing. This helps ensure that the most popular and profitable products are always available and highly visible.

-**Product Performance:** Identifying the top and bottom-selling pizzas is essential for menu management. The top sellers can be featured prominently, while the bottom sellers such as "The Brie Carre Pizza" can be evaluated. The company might then decide to remove an unpopular pizza to simplify operations, or they might launch a special promotion to boost its sales. This data-driven approach helps optimize the menu and reduce food waste.


# Power BI Dashboard
This dynamic and interactive dashboard provides a comprehensive visual overview of the entire analysis. It showcases key performance indicators, sales trends, and product-specific insights, allowing stakeholders to easily interact with the data and make informed decisions. The Power BI file `data_analysis_.pbix` is available in this repository.

# Dashboard Overview Analysis
The overview page of the Pizza Sales Report serves as the primary landing page, providing a high-level summary of the business's performance at a glance.
<p align="center">
	<img src = "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/overview.png" width= 90%>
</p>

# Key Performance Indicators (KPIs)
The dashboard highlights five critical KPIs that offer a comprehensive view of business health over the selected period:

- Total Revenue: Total sales amounted to $817,860, indicating strong financial performance for the year.

- Average Orders Value: The average customer transaction was $38.31, which helps in understanding typical spending habits.

- Total Pizza Sold: A total of 49,574 pizzas were sold, demonstrating robust product demand.

- Total Orders: The business processed 21,350 unique orders.

- Average Pizzas per Order: Customers purchased an average of 2.32 pizzas per order, providing insight into customer purchasing behavior.

# Sales Trends and Distribution
The visualization provides key insights into customer behavior and sales patterns:

- Daily and Monthly Trends: The report clearly identifies that orders are highest from Thursdays through Saturdays. Similarly, the monthly order trend reveals that sales are highest in January and July, indicating seasonal peaks.

- Sales Distribution by Category & Size: The analysis shows that the Classic pizza category is the top contributor to sales, closely followed by Supreme and Veggie pizzas. In terms of size, Large pizzas are the most popular, accounting for nearly half of all sales.

- Sales by Pizza Category: The breakdown of total pizzas sold per category further confirms the dominance of Classic pizzas, which significantly outsold all other categories.

# Product Performance 
<p align = "center">
<img src= "https://github.com/Venom3150/Data_analysis_Using_SQL_and_PowerBI/blob/main/product%20performance.png" width = 90%>
</p>
This page provides a detailed breakdown of the best and worst-selling pizzas across three key metrics: Revenue, Quantity, and Total Orders.

1.Best Selling Pizzas:
- By Revenue: "The Thai Chicken Pizza" generates the most revenue at $43,434, followed by "The Barbecue Chicken Pizza."
- By Quantity: The "Classic Deluxe Pizza" is the most popular by volume, with 2,453 units sold. The data suggests that a higher-quantity seller may not always be the highest-revenue generator.
- By Orders: "The Classic Deluxe Pizza" also received the highest number of orders, confirming its popularity with customers.

2. Lowest Selling Pizzas:
- By Revenue: "The Brie Carre Pizza" is the lowest revenue contributor at $11,588.
- By Quantity: This same pizza is also the least purchased by quantity, with only 490 units sold, indicating low customer demand.
- By Orders: "The Brie Carre Pizza" has the lowest number of orders, reinforcing its position as the lowest-selling item on the menu.

# Conclusion
This project successfully demonstrates a complete data analysis workflow, from raw data to actionable insights and interactive visualization. By leveraging SQL for data cleaning and querying and Power BI for reporting, the analysis provides a clear and comprehensive picture of the business's performance. The key findings on peak sales periods, customer preferences, and product performance offer strategic guidance for optimizing operations, marketing, and menu management. This data-driven approach allows for informed decision-making and a stronger overall business strategy.

