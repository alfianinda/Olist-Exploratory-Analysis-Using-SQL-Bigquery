-- OLIST EXPLORATORY ANALYSIS USING SQL BIGQUERY 
-- QUERY LINK: https://console.cloud.google.com/bigquery?sq=471716799905:8c57794f2acc45dfaca9cb40cfd51e3f

-------------------------------------------------------------------------------------------------------------------------------------------
-- 1. Calculate the total users/customers that are listed each year and show the growth percentage from the beginning to the current year
-------------------------------------------------------------------------------------------------------------------------------------------

-- sql 1: counting the number of customers
SELECT
	COUNT(*) AS no_rows,
	COUNT(DISTINCT customer_id) AS no_customer_id,
	COUNT(DISTINCT customer_unique_id) AS no_unique_customer_id
FROM (
  SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year, c.customer_id, c.customer_unique_id
  FROM `sql-project-inna.olist_dataset.olist_customers_dataset` AS c
  JOIN `sql-project-inna.olist_dataset.olist_orders_dataset` AS o
  ON c.customer_id = o.customer_id
);
-- no_customer_id = 99,441 > 96,096 = no_unique_customer_id so some customers might have more than one customer_id,

-- sql 2: This code uses 3 common table expressions (CTEs): 
-- Join_customers_orders to join customers and orders tables
-- Customer_counts to calculate the total customers listed each year
-- Cumulative_counts to calculate the cumulative number of customers over time. 
-- The final query retrieves the year, total customers, cumulative customers, and growth percentage by comparing the current cumulative count with the previous year's cumulative count.
WITH join_customers_orders AS (
  SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year, c.customer_unique_id
  FROM `sql-project-inna.olist_dataset.olist_customers_dataset` AS c
  JOIN `sql-project-inna.olist_dataset.olist_orders_dataset` AS o
  ON c.customer_id = o.customer_id
),
customer_counts AS (
  SELECT year, COUNT(DISTINCT customer_unique_id) AS total_customers
  FROM join_customers_orders
  GROUP BY year
  ORDER BY year
),
cumulative_counts AS (
  SELECT *, SUM(total_customers) OVER (ORDER BY year) AS cumulative_customers
  FROM customer_counts
)

SELECT 
  *,
  ROUND(((cumulative_customers - (LAG(cumulative_customers) OVER (ORDER BY year)))/LAG(cumulative_customers) OVER (ORDER BY year)) * 100, 2) AS growth_percentage
FROM cumulative_counts
ORDER BY year;
-- The year 2016. It shows a total of 326 customers listed in that year. The cumulative customer count is also 326, as it is the first year in the dataset. The growth percentage is null because there is no previous year to compare the growth.
-- The year 2017. The total number of customers listed in that year is 43,713. The cumulative customer count is 44,039, which is the sum of the previous cumulative count (326) and the current year's total customers. The growth percentage is calculated as 13,408.9, representing the significant increase from the previous year.
-- The year 2018. In this year, there were 52,749 customers listed. The cumulative customer count is 96,788, obtained by adding the previous cumulative count (44,039) to the total customers of the current year. The growth percentage is calculated as 119.78, indicating a substantial growth rate compared to the previous year.

-------------------------------------------------------------------------------------------------------------------------------------------
-- 2. Determine in which state should the company locate their warehouse; it should be in an area where the order density is the highest. (density ≠ amount)
-------------------------------------------------------------------------------------------------------------------------------------------

-- This code uses 2 common table expressions (CTEs): 
-- Join_customer_orders to join customers and orders tables
-- Order_population_counts indicates the total count of orders and population for that state. 
-- The final query shows the calculated order density by dividing the order count by the population of the state. By retrieving the row with the highest order density, it can be determined the state where the company should locate their warehouse, as it indicates the area with the highest concentration of orders relative to the population.
WITH join_customers_orders AS (
  SELECT customer_state, order_id, customer_unique_id
  FROM `sql-project-inna.olist_dataset.olist_customers_dataset` AS c
  JOIN `sql-project-inna.olist_dataset.olist_orders_dataset` AS o
  ON c.customer_id = o.customer_id
),
order_population_counts AS (
  SELECT 
    customer_state, 
    COUNT(DISTINCT order_id) AS order_count,
    COUNT(DISTINCT customer_unique_id) AS population
  FROM join_customers_orders
  GROUP BY customer_state
)

SELECT 
  *,
  ROUND(CAST(order_count AS FLOAT64) / population, 2) AS order_density
FROM order_population_counts
ORDER BY order_density DESC
LIMIT 1;
-- the state "RO" has an order count of 253 and a population of 240. The calculated order density for "RO" is 1.05, indicating that there is an average of 1.05 orders per person in that state.
-- Therefore, based on the highest order density, the company should consider locating their warehouse in "RO". This state has the highest concentration of orders relative to its population, making it a potentially favorable area for warehouse placement.

-------------------------------------------------------------------------------------------------------------------------------------------
-- 3. What is the second highest selling product and the second lowest selling products category in English and Portuguese?
-------------------------------------------------------------------------------------------------------------------------------------------

-- This code uses 3 common table expressions (CTEs): 
-- Join_products_order to join products, order_items, and product_category_name_translation tables. 
-- The product_sales CTE calculates the count of distinct orders for each product. 
-- The ranked_sales CTE builds upon the results of product_sales and assigns ranks to each product based on the order count, using ROW_NUMBER() function. It calculates both the rank_high (in descending order of order count) and rank_low (in ascending order of order count).
-- The final query shows filtering from the ranked_sales CTE, for products with either the second highest (rank_high = 2) or second lowest (rank_low = 2) order count.
WITH join_products_order AS (
  SELECT p.product_id, p.product_category_name AS product_category_portuguese, pt.string_field_1 AS product_category_english, order_id
  FROM `sql-project-inna.olist_dataset.olist_products_dataset` AS p
  LEFT JOIN `sql-project-inna.olist_dataset.olist_order_items_dataset` AS oi
    ON p.product_id = oi.product_id
  JOIN `sql-project-inna.olist_dataset.product_category_name_translation` AS pt
    ON p.product_category_name = pt.string_field_0
  WHERE p.product_category_name IS NOT NULL
),
product_sales AS (
  SELECT 
    product_id,
    product_category_portuguese,
    product_category_english,
    COUNT(DISTINCT order_id) AS order_count
  FROM join_products_order
  GROUP BY 1,2,3
),
ranked_sales AS (
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY order_count DESC) AS rank_high,
    ROW_NUMBER() OVER (ORDER BY order_count) AS rank_low
  FROM product_sales
)

SELECT *
FROM ranked_sales
WHERE rank_high = 2 OR rank_low = 2;
-- The second highest selling product has a product ID of "aca2eb7d00ea1a7b8ebd4e68314663af" and belongs to the category "furniture_decor" in English and "moveis_decoracao" in Portuguese. It has a total order count of 431.
-- On the other hand, the second lowest selling product category has a product category in English called "electronics" and in Portuguese "eletronicos". It has an order count of 1.
-- These insights reveal the products that are performing well in terms of sales, with the second highest selling product category indicating a strong demand for furniture and decor items. Conversely, the second lowest selling product category suggests a relatively lower demand for electronics. These findings can be valuable for business decision-making, such as inventory management and marketing strategies, to capitalize on popular product categories and potentially improve sales in underperforming categories.

-------------------------------------------------------------------------------------------------------------------------------------------
-- 4. Count how many products arrived late (exceeding the promised delivery date) and the percentage of orders that are delivered on schedule or faster.
-------------------------------------------------------------------------------------------------------------------------------------------

-- This code uses 2 common table expressions (CTEs): 
-- Join_orders to join order_items and orders tables. 
-- The order_metrics CTE calculate the metrics related to order delivery. The CTE calculates the late_arrivals_count, on_time_or_faster_count, and total_orders based on the join_orders table.
-- After defining the CTE, the main query selects the calculated metrics from the CTE and calculates the on_time_or_faster_percentage by dividing on_time_or_faster_count by total_orders and multiplying by 100. The result is rounded to two decimal places.
WITH join_orders AS (
  SELECT DISTINCT oi.order_id, oi.product_id, o.order_delivered_customer_date, o.order_estimated_delivery_date
  FROM `sql-project-inna.olist_dataset.olist_order_items_dataset` AS oi
  JOIN `sql-project-inna.olist_dataset.olist_orders_dataset` AS o
    ON oi.order_id = o.order_id
), 
order_metrics AS (
  SELECT
    COUNTIF(DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) > 0) AS late_arrivals_count,
    COUNTIF(DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) <= 0) AS on_time_or_faster_count,
    COUNT(*) AS total_orders
  FROM join_orders
)

SELECT
  late_arrivals_count,
  ROUND(CAST(on_time_or_faster_count AS FLOAT64) / total_orders * 100, 2) AS on_time_or_faster_percentage
FROM order_metrics;
-- `late_arrivals_count`: There are 6,666 products that arrived late, exceeding the promised delivery date.
-- `on_time_or_faster_percentage`: Approximately 91.31% of the orders were delivered on schedule or faster.
-- These insights indicate that a significant portion of the orders (91.31%) were delivered on schedule or faster, while 6,666 products arrived late. It highlights the importance of monitoring and improving delivery performance to ensure a higher percentage of orders are delivered within the promised timeframe.

-------------------------------------------------------------------------------------------------------------------------------------------
-- 5. Determine whether late delivery affects the ratings (star) given on those products.You can also explain your result in short sentences if necessary.
-------------------------------------------------------------------------------------------------------------------------------------------

-- This code uses 1 common table expressions (CTEs): 
-- Join_reviews_orders to join orders and order_reviews tables. 
-- The main query selects the review score, calculates the average number of days late for each review score category, and counts the number of reviews for each score.
WITH join_reviews_orders AS (
  SELECT DISTINCT o.order_id, o.order_delivered_customer_date, o.order_estimated_delivery_date, r.review_score
  FROM `sql-project-inna.olist_dataset.olist_orders_dataset` AS o
  LEFT JOIN `sql-project-inna.olist_dataset.olist_order_reviews_dataset` r
    ON o.order_id = r.order_id
)

SELECT
  review_score,
  ROUND(AVG(DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY)),2) AS late_arrivals_avg,
  COUNT(*) AS count_reviews
FROM join_reviews_orders
WHERE
  order_delivered_customer_date > order_estimated_delivery_date 
GROUP BY 1
ORDER BY 1;
-- The average percentage of late arrivals is decreasing as the review score increases. This suggests that higher-rated products tend to have lower instances of late delivery.
-- The count of reviews decreases as the review score increases. This is expected since higher-rated products may have fewer reviews overall.
-- The highest average percentage of late arrivals is observed for products with a review score of 1, indicating that these products have a higher likelihood of experiencing late delivery.
-- Products with a review score of 5 have the lowest average percentage of late arrivals, indicating that these products are more likely to be delivered on time or ahead of schedule.
-- Based on these insights, it can be inferred that there is a correlation between late delivery and lower review scores. Products with a higher incidence of late delivery tend to receive lower ratings, while products with better delivery performance tend to receive higher ratings. However, it's important to note that these observations are based on the provided data and further analysis may be required to establish a definitive causal relationship between late delivery and ratings.

