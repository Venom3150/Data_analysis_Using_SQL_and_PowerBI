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

