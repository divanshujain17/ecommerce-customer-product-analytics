SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(i.price), 2) AS total_revenue,
    ROUND(SUM(i.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value,
    MAX(o.order_purchase_timestamp) AS last_purchase_date
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN items AS i
    ON o.order_id = i.order_id
GROUP BY c.customer_unique_id
ORDER BY total_revenue DESC;

SELECT
    c.customer_unique_id,
    o.order_id,
    o.order_purchase_timestamp,
    i.product_id,
    i.price
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN items AS i
    ON o.order_id = i.order_id
WHERE c.customer_unique_id = '0a0a92112bd4c708ca5fde585afaa872';

SELECT COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers;

SELECT COUNT(*) AS repeat_customers
FROM (
    SELECT c.customer_unique_id
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
) AS t;

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(i.price), 2) AS total_revenue
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN items AS i
    ON o.order_id = i.order_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC
LIMIT 10;
