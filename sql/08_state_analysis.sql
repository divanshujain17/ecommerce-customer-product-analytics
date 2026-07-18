SELECT
    s.customer_state_full AS customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    ROUND(SUM(i.price), 2) AS total_revenue,
    ROUND(SUM(i.price) / COUNT(DISTINCT o.order_id),2) AS avg_order_value
FROM state_names AS s
JOIN customers AS c
    ON s.customer_state = c.customer_state
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN items AS i
    ON o.order_id = i.order_id
GROUP BY customer_state
ORDER BY total_revenue DESC;
