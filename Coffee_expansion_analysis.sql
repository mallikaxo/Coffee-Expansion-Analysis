/* ================================================================
   📊 COFFEE SALES ANALYTICS PROJECT  
   Database: coffeesales  
   Description:
   End-to-end SQL analytics pipeline covering:
   - Schema creation
   - Data verification
   - Revenue analysis
   - Product performance
   - Customer & city behavior
   - Market potential evaluation
   - Strategic expansion logic
   - Product recommendation logic based on price tiers
================================================================ */

/* ================================================================
   STEP 1 — Create & Select Database
================================================================ */

CREATE DATABASE IF NOT EXISTS coffeesales;
USE coffeesales;

/* ================================================================
   STEP 2 — Define Schema
================================================================ */

-- -----------------
-- Table: city
-- -----------------
CREATE TABLE city (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(20),
    population INT,
    estimated_rent INT,
    city_rank INT
);

-- -----------------
-- Table: customers
-- -----------------
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city_id INT,
    CONSTRAINT fk_cityid FOREIGN KEY (city_id) REFERENCES city(city_id)
);

-- -----------------
-- Table: products
-- -----------------
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    price FLOAT
);

-- -----------------
-- Table: sales
-- -----------------
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

/* ================================================================
   STEP 3 — Data Verification
================================================================ */

SELECT * FROM city;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM sales;

/* ================================================================
   STEP 4 — ANALYTICS & INSIGHTS
================================================================ */

/* ---------------------------------------------------------------
   1. Estimated coffee consumers per city (40% assumption)
---------------------------------------------------------------- */
SELECT 
    city_name,
    population,
    0.40 * population AS estimated_consumers
FROM city
ORDER BY population DESC;

/* ---------------------------------------------------------------
   2. Total revenue across all cities
---------------------------------------------------------------- */
SELECT SUM(total) AS total_revenue FROM sales;

/* ---------------------------------------------------------------
   3. Revenue by city
---------------------------------------------------------------- */
SELECT 
    c.city_name,
    SUM(s.total) AS revenue
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city c ON cu.city_id = c.city_id
GROUP BY c.city_name
ORDER BY revenue DESC;

/* ---------------------------------------------------------------
   4. Product-wise revenue
---------------------------------------------------------------- */
SELECT 
    p.product_id,
    p.product_name,
    SUM(s.total) AS revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_id
ORDER BY revenue DESC;

/* ---------------------------------------------------------------
   5. Product sales count (frequency)
---------------------------------------------------------------- */
SELECT 
    p.product_id,
    p.product_name,
    COUNT(s.product_id) AS sale_count
FROM products p
JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_id
ORDER BY sale_count DESC;

/* ---------------------------------------------------------------
   6. Average sale & customer count per city
---------------------------------------------------------------- */
SELECT 
    cu.city_id,
    c.city_name,
    ROUND(AVG(s.total), 2) AS average_sale,
    COUNT(DISTINCT cu.customer_id) AS customer_count,
    ROUND(SUM(s.total) / COUNT(DISTINCT cu.customer_id), 2) AS avg_per_customer
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city c ON cu.city_id = c.city_id
GROUP BY cu.city_id, c.city_name
ORDER BY avg_per_customer DESC;

/* ---------------------------------------------------------------
   7. Estimated vs actual customers per city
---------------------------------------------------------------- */
SELECT 
    c.city_name,
    0.40 * c.population AS estimated_consumers,
    COUNT(cu.customer_id) AS active_customers
FROM city c
JOIN customers cu ON c.city_id = cu.city_id
GROUP BY c.city_name, c.population
ORDER BY estimated_consumers DESC;

/* ---------------------------------------------------------------
   8. Top 3 selling products in each city
---------------------------------------------------------------- */
WITH ranked_products AS (
    SELECT 
        c.city_name,
        p.product_name,
        COUNT(s.sales_id) AS total_orders,
        DENSE_RANK() OVER (
            PARTITION BY c.city_name 
            ORDER BY COUNT(s.sales_id) DESC
        ) AS rank_in_city
    FROM sales s
    JOIN customers cu ON s.customer_id = cu.customer_id
    JOIN city c ON cu.city_id = c.city_id
    JOIN products p ON p.product_id = s.product_id
    GROUP BY c.city_name, p.product_name
)
SELECT *
FROM ranked_products
WHERE rank_in_city <= 3
ORDER BY city_name, rank_in_city;

/* ---------------------------------------------------------------
   9. Unique coffee products (Top 3) per city
---------------------------------------------------------------- */
WITH coffee_products AS (
    SELECT 
        c.city_name,
        p.product_name,
        COUNT(s.product_id) AS items_sold,
        DENSE_RANK() OVER (
            PARTITION BY c.city_name 
            ORDER BY p.product_name DESC
        ) AS product_rank
    FROM products p
    JOIN sales s ON p.product_id = s.product_id
    JOIN customers cu ON cu.customer_id = s.customer_id
    JOIN city c ON cu.city_id = c.city_id
    WHERE s.product_id <= 14
    GROUP BY c.city_name, p.product_name
)
SELECT *
FROM coffee_products
WHERE product_rank <= 3
ORDER BY city_name, product_rank;

/* ---------------------------------------------------------------
   10. Average sale vs. estimated rent (cost analysis)
---------------------------------------------------------------- */
SELECT
    c.city_name,
    ROUND(SUM(s.total) / COUNT(DISTINCT s.customer_id), 2) AS avg_sale_per_customer,
    ROUND(c.estimated_rent / COUNT(DISTINCT s.customer_id), 2) AS rent_per_customer
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city c ON cu.city_id = c.city_id
GROUP BY c.city_name, c.estimated_rent
ORDER BY rent_per_customer;

/* ---------------------------------------------------------------
   11. Monthly sales trend (company-wide)
---------------------------------------------------------------- */
SELECT 
    YEAR(sales_date) AS year,
    MONTH(sales_date) AS month,
    SUM(total) AS monthly_total
FROM sales
GROUP BY YEAR(sales_date), MONTH(sales_date)
ORDER BY year, month;

/* ---------------------------------------------------------------
   12. Monthly sales growth by city
---------------------------------------------------------------- */
WITH monthly_sales AS (
    SELECT 
        c.city_name,
        YEAR(s.sales_date) AS year,
        MONTH(s.sales_date) AS month,
        SUM(s.total) AS monthly_revenue
    FROM sales s
    JOIN customers cu ON s.customer_id = cu.customer_id
    JOIN city c ON cu.city_id = c.city_id
    GROUP BY c.city_name, YEAR(s.sales_date), MONTH(s.sales_date)
),
growth_ratio AS (
    SELECT 
        city_name,
        year,
        month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (
            PARTITION BY city_name ORDER BY year, month
        ) AS prev_month
    FROM monthly_sales
)
SELECT 
    city_name,
    year,
    month,
    monthly_revenue,
    prev_month,
    ROUND(((monthly_revenue - prev_month) / prev_month) * 100, 2)
        AS growth_percent
FROM growth_ratio
WHERE prev_month IS NOT NULL
ORDER BY city_name, year, month;

/* ---------------------------------------------------------------
   13. Market Potential Analysis
---------------------------------------------------------------- */
SELECT 
    c.city_name,
    0.40 * c.population AS estimated_consumers,
    COUNT(DISTINCT s.customer_id) AS active_customers,
    SUM(s.total) AS total_city_revenue,
    c.estimated_rent
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city c ON cu.city_id = c.city_id
GROUP BY c.city_name, c.population, c.estimated_rent
ORDER BY active_customers DESC;

/* ================================================================
   14. Strategic Expansion Logic (Pune, Delhi, Jaipur Justification)
================================================================ */
WITH city_metrics AS (
    SELECT
        c.city_name,
        ROUND(SUM(s.total) / COUNT(DISTINCT s.customer_id), 2) AS revenue_per_customer,
        0.40 * c.population AS estimated_consumers,
        COUNT(DISTINCT s.customer_id) AS active_customers,
        (0.40 * c.population - COUNT(DISTINCT s.customer_id)) AS untapped_market,
        ROUND(SUM(s.total) / c.estimated_rent, 2) AS revenue_to_rent_ratio,
        ROUND(c.estimated_rent / COUNT(DISTINCT s.customer_id), 2) AS rent_per_customer
    FROM sales s
    JOIN customers cu ON s.customer_id = cu.customer_id
    JOIN city c ON cu.city_id = c.city_id
    GROUP BY c.city_name, c.population, c.estimated_rent
)
SELECT
    city_name,
    revenue_per_customer,
    untapped_market,
    revenue_to_rent_ratio,
    rent_per_customer,
    CASE
        WHEN revenue_per_customer = (SELECT MAX(revenue_per_customer) FROM city_metrics)
            THEN 'Highest Financial Return — Ideal for aggressive expansion (Pune)'
        WHEN untapped_market = (SELECT MAX(untapped_market) FROM city_metrics)
            THEN 'Largest Untapped Consumer Base — High growth potential (Delhi)'
        WHEN revenue_to_rent_ratio = (SELECT MAX(revenue_to_rent_ratio) FROM city_metrics)
             AND rent_per_customer = (SELECT MIN(rent_per_customer) FROM city_metrics)
            THEN 'Most Operationally Efficient — Best for stable expansion (Jaipur)'
        ELSE 'General Tier City'
    END AS strategic_recommendation
FROM city_metrics
ORDER BY revenue_per_customer DESC;

/* ================================================================
   15. Product Recommendation Logic Based on Price Tiers (MySQL Safe)
================================================================ */

-- Step 1: Order products by price
WITH ordered_prices AS (
    SELECT 
        product_id,
        product_name,
        price,
        ROW_NUMBER() OVER (ORDER BY price) AS rn,
        COUNT(*) OVER () AS total_count
    FROM products
),

-- Step 2: Determine 50th & 75th percentile positions
percentiles AS (
    SELECT
        CEIL(total_count * 0.50) AS p50_pos,
        CEIL(total_count * 0.75) AS p75_pos
    FROM ordered_prices LIMIT 1
),

-- Step 3: Assign price tiers
product_tiers AS (
    SELECT
        op.product_id,
        op.product_name,
        op.price,
        CASE
            WHEN op.rn >= (SELECT p75_pos FROM percentiles) THEN 'High'
            WHEN op.rn >= (SELECT p50_pos FROM percentiles) THEN 'Medium'
            ELSE 'Low'
        END AS price_tier
    FROM ordered_prices op
),

-- Step 4: Map price tiers to recommended cities
recommended_cities AS (
    SELECT
        pt.product_name,
        pt.price,
        pt.price_tier,
        CASE
            WHEN pt.price_tier = 'High' THEN 'Delhi, Pune'
            WHEN pt.price_tier = 'Medium' THEN 'Jaipur, Pune'
            ELSE 'All Cities'
        END AS recommended_markets
    FROM product_tiers pt
)

-- Final Output
SELECT *
FROM recommended_cities
ORDER BY price DESC;
