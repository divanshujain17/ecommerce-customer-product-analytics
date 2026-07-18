SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%y-%m') AS month,
    ROUND(SUM(i.price), 2) AS revenue
FROM orders AS o
JOIN items AS i
    ON o.order_id = i.order_id
GROUP BY month
ORDER BY month;

SELECT
    DATE_FORMAT(order_purchase_timestamp, '%y-%m') AS month,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%y-%m') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(i.price), 2) AS total_revenue,
    ROUND(SUM(i.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders AS o
JOIN items AS i
    ON o.order_id = i.order_id
GROUP BY month
ORDER BY month;
