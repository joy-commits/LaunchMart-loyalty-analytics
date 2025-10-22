-- ANALYTICS QUESTIONS

-- Q1: Count the total number of customers who joined in 2023.
SELECT COUNT(*) as customers_from_2023
FROM customers
WHERE join_date >= '2023-01-01' AND join_date < '2024-01-01';

--Q2: For each customer return customer_id, full_name, total_revenue (sum of total_amount from orders). Sort descending.
SELECT c.customer_id, c.full_name, SUM(o.total_amount) as total_revenue
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_revenue DESC;

--Q3: Return the top 5 customers by total_revenue with their rank.
SELECT c.customer_id, c.full_name, SUM(o.total_amount) as total_revenue,
RANK() OVER(ORDER BY(SUM(o.total_amount)) DESC) as customer_rank
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_revenue DESC
LIMIT 5;

--Q4: Produce a table with year, month, monthly_revenue for all months in 2023 ordered chronologically.
SELECT
EXTRACT(YEAR FROM order_date) as order_year,
EXTRACT(MONTH FROM order_date) as order_month,
SUM(total_amount) as monthly_revenue
FROM orders
WHERE order_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY order_year, order_month
ORDER BY order_month ASC;

--Q5: Find customers with no orders in the last 60 days relative to 2023-12-31 (i.e., consider last active date up to 2023-12-31). Return customer_id, full_name, last_order_date.
SELECT c.customer_id, c.full_name, MAX(o.order_date) as last_order_date
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_date <= '2023-12-31'::date - 60
GROUP BY c.customer_id
ORDER BY last_order_date DESC;

--Q6: Calculate average order value (AOV) for each customer: return customer_id, full_name, aov (average total_amount of their orders). Exclude customers with no orders.
SELECT c.customer_id, c.full_name, AVG(o.total_amount) as average_order_value
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY average_order_value DESC;

--Q7: For all customers who have at least one order, compute customer_id, full_name, total_revenue, spend_rank where spend_rank is a dense rank, highest spender = rank 1.
SELECT c.customer_id, c.full_name, SUM(total_amount) as total_rev,
DENSE_RANK() OVER(ORDER BY SUM(total_amount) DESC) as spend_rank
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY spend_rank ASC, total_rev DESC;

--Q8: List customers who placed more than 1 order and show customer_id, full_name, order_count, first_order_date, last_order_date.
WITH cust_orders AS (
SELECT c.customer_id, c.full_name, COUNT(*) as order_count, 
MIN(o.order_date) as first_order_date,
MAX(o.order_date) as last_order_date
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id
)
SELECT *
FROM cust_orders
WHERE order_count > 1;

--Q9: Compute total loyalty points per customer. Include customers with 0 points.
SELECT c.customer_id, c.full_name, COALESCE(SUM(points_earned), 0) as total_points
FROM customers c
JOIN loyalty_points l
ON c.customer_id = l.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_points DESC;

--Q10: Assign loyalty tiers based on total points: Bronze: < 100, Silver: 100–499, Gold: >= 500. Output: tier, tier_count, tier_total_points
WITH customer_points AS (
SELECT c.customer_id, c.full_name, SUM(points_earned) as total_points
FROM customers c
JOIN loyalty_points l
ON c.customer_id = l.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_points DESC
),
tier_table AS (
SELECT CASE 
		WHEN total_points < 100 THEN 'Bronze'
		WHEN total_points between 100 and 499 THEN 'Silver'
		ELSE 'Gold'
		END as tier,
	COUNT(*) as tier_count,
	SUM(total_points) as tier_total_points
FROM customer_points
GROUP BY tier
)
SELECT tier, tier_count, tier_total_points
FROM tier_table;

--Q11: Identify customers who spent more than ₦50,000 in total but have less than 200 loyalty points. Return customer_id, full_name, total_spend, total_points.
WITH cust_table AS
(
SELECT c.customer_id, c.full_name, SUM(o.total_amount) as total_spend, SUM(l.points_earned) as total_points
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN loyalty_points l
ON c.customer_id = l.customer_id
GROUP BY c.customer_id, c.full_name
)
SELECT customer_id, full_name, total_spend, total_points
FROM cust_table
WHERE total_spend > 50000 AND total_points < 200;

--Q12: Flag customers as churn_risk if they have no orders in the last 90 days (relative to 2023-12-31) AND are in the Bronze tier. Return customer_id, full_name, last_order_date, total_points.
WITH churn_risk AS
(
SELECT c.customer_id, c.full_name, SUM(l.points_earned) as total_points,
MAX(o.order_date) as last_order_date
FROM customers c
INNER JOIN loyalty_points l
ON c.customer_id = l.customer_id
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
)
SELECT customer_id, full_name, last_order_date as order_date, total_points
FROM churn_risk
WHERE total_points < 100 AND last_order_date <= '2023-12-31':: date - 90;
