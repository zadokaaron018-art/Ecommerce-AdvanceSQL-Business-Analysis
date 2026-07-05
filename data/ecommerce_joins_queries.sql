-- ============================================================
-- Advanced SQL Joins & Business Analysis
-- Tool: PostgreSQL (pgAdmin 4)
-- Database: ecommerce_db
-- Role framing: Junior Data Analyst
-- ============================================================

-- 1. Customer performance report: name, city, total orders, total spend, ranked highest to lowest.
SELECT
    c.customer_name,
    c.city,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_revenue
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_name, c.city
ORDER BY total_revenue DESC;

-- 2. Total revenue by city; top 3 revenue-generating cities.
SELECT
    delivery_city,
    SUM(total_amount) AS total_revenue
FROM orders
WHERE delivery_city IS NOT NULL
GROUP BY delivery_city
ORDER BY total_revenue DESC
LIMIT 3;

-- 3. Customers who have never placed an order.
SELECT
    c.customer_name,
    c.city,
    o.order_id
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 4. Orders with no matching customer record (orphaned orders).
SELECT
    o.order_id,
    c.customer_id,
    o.product_name
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 5. Total revenue and total quantity sold per product; identify best-performing product.
SELECT
    product_name,
    SUM(quantity) AS total_quantity,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY product_name
ORDER BY total_revenue DESC;

-- 6. Customers whose total spending is above the average customer spending.
SELECT customer_name,
    total_spent
FROM (
    SELECT
        c.customer_name,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_name
) sub
WHERE total_spent > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(total_amount) AS total_spent
        FROM orders
        GROUP BY customer_id
    ) avg_table
);

-- 7. Key business KPIs: total revenue, total orders, average order value,
-- total customers, and customers without orders — all in one query.
SELECT
    SUM(o.total_amount) AS total_revenue,
    COUNT(o.order_id) AS total_orders,
    AVG(o.total_amount) AS avg_order_value,
    (SELECT COUNT(customer_name) FROM customers) AS total_customers,
    (SELECT COUNT(customer_name)
        FROM customers c
        LEFT JOIN orders o
            ON c.customer_id = o.customer_id
        WHERE o.customer_id IS NULL
    ) AS customers_without_orders
FROM orders o;
