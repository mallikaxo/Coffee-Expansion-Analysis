# ☕ Coffee Sales Analytics SQL Project

This project provides a detailed analysis of coffee sales data across multiple cities, focusing on revenue, product performance, market potential, and customer engagement. The analysis is performed using **SQL (MySQL dialect used in the script)**, leveraging various features like joins, window functions, and Common Table Expressions (CTEs) to derive actionable insights.

The original SQL script outlines a complete process, starting with database setup and schema definition, followed by step-by-step data analysis queries across 15 stages.

---

## 📊 Project Goals

The primary objectives of this analysis are to:

1. **Summarize Company Performance:** Calculate total company revenue and analyze sales trends.
2. **Evaluate City-Level Performance:** Break down revenue, average sale, and customer distribution by city.
3. **Analyze Product Performance:** Identify top-selling products globally and for specific cities.
4. **Assess Market Potential:** Compare actual customer numbers against estimated coffee consumers to gauge market penetration.
5. **Track Growth:** Calculate monthly sales trends and month-over-month growth for each city.
6. **Analyze Financial Ratios:** Compare sales-per-customer against estimated rent-per-customer for strategic insights.

---

## 📁 Database Schema

The analysis is based on four inter-related tables:

| Table Name  | Description                                            | Key Columns                                                                        |
| :---------- | :----------------------------------------------------- | :--------------------------------------------------------------------------------- |
| `city`      | Contains demographic and location-specific data.       | `city_id`, `city_name`, `population`, `estimated_rent`                             |
| `customers` | Details about registered customers and their location. | `customer_id`, `customer_name`, `city_id` (FK)                                     |
| `products`  | Catalogue of coffee products and their prices.         | `product_id`, `product_name`, `price`                                              |
| `sales`     | Transactional data for all sales.                      | `sales_id`, `sales_date`, `product_id` (FK), `customer_id` (FK), `total`, `rating` |

---

## ✨ Key Analysis Highlights

The SQL queries extract several critical insights, including:

* **City-Specific Bestsellers (Step 11):** Uses the `DENSE_RANK()` window function to determine the **Top 3 selling products per city**, crucial for localized inventory and marketing.
* **Monthly Sales Growth (Step 14):** Calculates **Month-over-Month (MoM) Growth Percentage** per city using the `LAG()` window function to monitor performance trends.

---

## 🎯 Conclusion and Strategic City Recommendations

Based on the multi-dimensional analysis, the following table summarizes the key metrics for the top-performing cities—**Delhi, Jaipur, and Pune**—to inform strategic decisions regarding investment, expansion, or optimization.

| City       | Key Strategic Strength (Recommendation Focus)                          | Supporting Market Potential Metrics                                                                                         | Supporting Financial & Growth Metrics                                                                                                                      | Recommendation Score |
| :--------- | :--------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------- |
| **Delhi**  | **High Potential & Market Capture** (Focus on Deepening Penetration)   | Highest **Estimated Coffee Consumers** ($12.4 \text{ million}$). Large current customer base ($68$ active customers).       | Good penetration. **Significant growth** and stability in monthly trends. Average $\text{Rent/Customer}$ is $330$ (good $\text{Revenue vs. Rent}$ ratio).  | **$$9.5/10$$**       |
| **Jaipur** | **High Profitability & Efficiency** (Focus on Targeted Expansion)      | High current customer base ($69$ active customers). Strong $\text{Actual Customers}$ to $\text{Estimated Consumers}$ ratio. | **Extremely Low Average $\text{Rent/Customer}$** ($156$). High **Average $\text{Sales/Customer}$** ($11.6 \text{k}$). Fluctuating but net-positive growth. | **$$9.0/10$$**       |
| **Pune**   | **High Value & Top Revenue Generator** (Focus on Revenue Optimization) | Strong current customer base. High $\text{Actual Customers}$ to $\text{Estimated Consumers}$ ratio.                         | **Highest Total Revenue**. **High Average $\text{Sales/Customer}$**. Very low Average $\text{Rent/Customer}$. Consistently **better growth** metrics.      | **$$9.5/10$$**       |

### Strategic Summary

* **Pune** and **Delhi** are top-tier targets for continued **investment and aggressive expansion**. Pune offers the highest current financial return, while Delhi offers the largest pool of untapped consumers.
* **Jaipur** stands out for its **operational efficiency and low cost structure**. It is an ideal city for high-margin, stable operations and conservative expansion efforts.

---

## ☕ Product Recommendations

Building upon the city-level insights, the following **product strategy** aligns with each city’s unique market characteristics and consumer behavior:

| City       | Product Focus                                 | Recommended Products                                                               | Rationale                                                                                                                                                                                                                           |
| :--------- | :-------------------------------------------- | :--------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Delhi**  | **Premium & Lifestyle-Oriented Offerings**    | *Cold Brew Coffee Packs (6 bottles)*, *Vanilla Coffee Syrup*, *Tote Bags & Mugs*   | Delhi’s strong market potential and growing urban coffee culture make it ideal for promoting **premium cold beverages** and **brand merchandise**. High customer density supports **bundled offerings** and lifestyle-driven sales. |
| **Jaipur** | **Value & Experience-Driven Offerings**       | *Ground Espresso Coffee*, *Coffee Beans (Medium Roast)*, *Art Prints & Tote Bags*  | Jaipur’s price-sensitive but loyal customer base suits **high-value, home-brewing products**. Branded art and tote merchandise enhance brand loyalty while maintaining profitability.                                               |
| **Pune**   | **High-End & Performance-Oriented Offerings** | *Ground Espresso Coffee*, *Vanilla Coffee Syrup*, *Cold Brew Packs*, *Coffee Mugs* | Pune’s high-spending, growth-oriented profile supports **premium coffee blends** and **add-on products** (e.g., syrups, mugs). Encouraging repeat purchases through bundle discounts would maximize customer lifetime value.        |

### Additional Product Insights

* **Cold Brew Packs (6 Bottles):** Excellent for warm climates and active consumers; aligns with Delhi and Pune demographics.
* **Ground Espresso Coffee & Coffee Beans:** Ideal for at-home brewing markets (Jaipur and Pune).
* **Vanilla Coffee Syrup:** Encourages experimentation and premiumization across all cities; strong upselling potential.
* **Merchandise (Tote Bags, Art Prints, Mugs):** Boosts brand visibility and supports lifestyle positioning in urban markets.

---

## 🧭 Final Takeaways

The integration of **SQL-driven analytics** with **strategic product recommendations** provides a powerful framework for data-backed decision-making.
Each city exhibits a distinct profile — from Delhi’s massive untapped potential to Pune’s strong financial yield and Jaipur’s operational efficiency — offering a clear roadmap for **targeted product marketing, expansion strategy, and brand positioning** across India’s emerging coffee market.
