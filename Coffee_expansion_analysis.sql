-- ================================================================
-- 📊 COFFEE SALES ANALYTICS PROJECT
-- Database: coffeesales
-- Description: An end-to-end SQL-based analysis of coffee sales
-- across cities, customers, and products to derive business insights.
-- ================================================================

-- Step 1: Create and select the database
CREATE DATABASE coffeesales;
USE coffeesales;

-- ================================================================
-- Step 2: Define the Schema
-- ================================================================

-- Table: city
CREATE TABLE city (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(20), 
    population INT,
    estimated_rent INT,
    city_rank INT
);

-- Table: customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50), 
    city_id INT,
    CONSTRAINT fk_cityid FOREIGN KEY (city_id) REFERENCES city(city_id)
);

-- Table: products
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    price FLOAT
);

-- Table: sales
CREATE TABLE sales (
    sales_id INT PRIMARY KEY,
    sales_date DATE,
    product_id INT,
    customer_id INT,
    total FLOAT,
    rating FLOAT,
    CONSTRAINT fk_productid FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_customerid FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- ================================================================
-- Step 3: Data Verification
-- ================================================================
SELECT * FROM city;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM sales;

-- ================================================================
-- Step 4: Data Analysis Queries
-- ================================================================

-- 1️⃣ Percentage of population consuming coffee (assuming 40%)
SELECT 
    city.city_name,
    city.population,
    0.40 * city.population AS coffee_consumers
FROM city
ORDER BY city.population DESC;

-- ---------------------------------------------------------------
-- 2️⃣ Total revenue generated across all cities
SELECT 
    SUM(sales.total) AS total_revenue
FROM sales;

-- ---------------------------------------------------------------
-- 3️⃣ Total revenue by city
SELECT 
    city.city_name,
    SUM(sales.total) AS revenue
FROM sales
JOIN customers ON sales.customer_id = customers.customer_id
JOIN city ON customers.city_id = city.city_id
GROUP BY city.city_name
ORDER BY revenue DESC;

-- ---------------------------------------------------------------
-- 4️⃣ Product-wise sales revenue
SELECT 
    sales.product_id,
    products.product_name,
    SUM(sales.total) AS revenue
FROM sales
JOIN products ON products.product_id = sales.product_id
GROUP BY products.product_id
ORDER BY revenue DESC;

-- ---------------------------------------------------------------
-- 5️⃣ Product sales count (frequency of sale)
SELECT 
    sales.product_id,
    products.product_name,
    COUNT(sales.product_id) AS sale_count
FROM products
JOIN sales ON products.product_id = sales.product_id
GROUP BY sales.product_id
ORDER BY sale_count DESC;

-- ---------------------------------------------------------------
-- 6️⃣ Average sale amount and customer count per city
SELECT 
    customers.city_id,
    city.city_name,
    ROUND(AVG(sales.total), 2) AS average_sale,
    COUNT(DISTINCT customers.customer_id) AS customer_count,
    ROUND(SUM(sales.total) / COUNT(DISTINCT customers.customer_id), 2) AS avg_per_customer
FROM sales
JOIN customers ON sales.customer_id = customers.customer_id
JOIN city ON customers.city_id = city.city_id
GROUP BY customers.city_id, city.city_name
ORDER BY avg_per_customer DESC;

-- ---------------------------------------------------------------
-- 7️⃣ Estimated coffee consumers vs actual customers per city
SELECT 
    city.city_name,
    0.40 * city.population AS estimated_coffee_consumers,
    COUNT(customers.customer_id) AS current_customers
FROM city
JOIN customers ON city.city_id = customers.city_id
GROUP BY city.city_name, city.population
ORDER BY estimated_coffee_consumers DESC;

-- ---------------------------------------------------------------
-- 8️⃣ Top 3 selling products in each city
WITH ranked_products AS (
    SELECT 
        city.city_name,
        products.product_name,
        COUNT(sales.sales_id) AS total_orders,
        DENSE_RANK() OVER (
            PARTITION BY city.city_name 
            ORDER BY COUNT(sales.sales_id) DESC
        ) AS rank_in_city
    FROM customers
    JOIN sales ON customers.customer_id = sales.customer_id
    JOIN city ON city.city_id = customers.city_id
    JOIN products ON products.product_id = sales.product_id
    GROUP BY city.city_name, products.product_name
)
SELECT *
FROM ranked_products
WHERE rank_in_city IN (1, 2, 3)
ORDER BY city_name, rank_in_city;

-- ---------------------------------------------------------------
-- 9️⃣ Unique coffee products sold per city (top 3)
WITH coffee_products AS (
    SELECT 
        city.city_name,
        products.product_name,
        COUNT(sales.product_id) AS items_sold,
        DENSE_RANK() OVER(
            PARTITION BY city.city_name 
            ORDER BY products.product_name DESC
        ) AS product_rank
    FROM products
    JOIN sales ON products.product_id = sales.product_id
    JOIN customers ON customers.customer_id = sales.customer_id
    JOIN city ON city.city_id = customers.city_id
    WHERE sales.product_id <= 14
    GROUP BY city.city_name, products.product_name
)
SELECT *
FROM coffee_products
WHERE product_rank IN (1, 2, 3)
ORDER BY city_name, product_rank;

-- ---------------------------------------------------------------
-- 🔟 Average sale vs. estimated rent per customer
SELECT
    city.city_name,
    ROUND(SUM(sales.total) / COUNT(DISTINCT sales.customer_id), 2) AS avg_sale_per_customer,
    ROUND(city.estimated_rent / COUNT(DISTINCT sales.customer_id), 2) AS avg_rent_per_customer
FROM sales
JOIN customers ON sales.customer_id = customers.customer_id
JOIN city ON city.city_id = customers.city_id
GROUP BY city.city_name, city.estimated_rent
ORDER BY avg_rent_per_customer;

-- ---------------------------------------------------------------
-- 1️⃣1️⃣ Monthly sales growth (overall company)
SELECT 
    YEAR(sales.sales_date) AS sales_year,
    MONTH(sales.sales_date) AS sales_month,
    SUM(sales.total) AS monthly_total
FROM sales
GROUP BY YEAR(sales.sales_date), MONTH(sales.sales_date)
ORDER BY sales_year, sales_month;

-- ---------------------------------------------------------------
-- 1️⃣2️⃣ Monthly sales growth by city
WITH monthly_sales AS (
    SELECT 
        city.city_name,
        YEAR(sales.sales_date) AS sales_year,
        MONTH(sales.sales_date) AS sales_month,
        SUM(sales.total) AS monthly_revenue
    FROM customers
    JOIN city ON customers.city_id = city.city_id
    JOIN sales ON sales.customer_id = customers.customer_id
    GROUP BY city.city_name, YEAR(sales.sales_date), MONTH(sales.sales_date)
),
growth_ratio AS (
    SELECT 
        city_name,
        sales_year,
        sales_month,
        monthly_revenue,
        LAG(monthly_revenue, 1) OVER (
            PARTITION BY city_name 
            ORDER BY sales_year, sales_month
        ) AS last_month_sale
    FROM monthly_sales
)
SELECT 
    city_name,
    sales_year,
    sales_month,
    monthly_revenue,
    last_month_sale,
    ROUND(
        ((monthly_revenue - last_month_sale) / last_month_sale) * 100,
        2
    ) AS growth_percent
FROM growth_ratio
WHERE last_month_sale IS NOT NULL
ORDER BY city_name, sales_year, sales_month;

-- ---------------------------------------------------------------
-- 1️⃣3️⃣ Market Potential Analysis
-- Combining coffee consumption, revenue, rent, and customers
SELECT 
    city.city_name,
    0.40 * city.population AS estimated_coffee_consumers,
    COUNT(DISTINCT sales.customer_id) AS active_customers,
    SUM(sales.total) AS total_city_revenue,
    city.estimated_rent
FROM sales
JOIN customers ON sales.customer_id = customers.customer_id
JOIN city ON city.city_id = customers.city_id
GROUP BY city.city_name, city.population, city.estimated_rent
ORDER BY active_customers DESC;
