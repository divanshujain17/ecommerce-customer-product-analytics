SELECT
    p.product_category_name AS category,
    COUNT(DISTINCT i.order_id) AS total_orders,
    ROUND(SUM(i.price), 2) AS total_revenue,
    ROUND(AVG(i.price), 2) AS avg_product_price,
    COUNT(DISTINCT i.product_id) AS unique_products,
    ROUND(SUM(i.price) * 100 / SUM(SUM(i.price)) OVER (), 2) AS revenue_share_percent
FROM items AS i
JOIN products AS p
    ON i.product_id = p.product_id
GROUP BY category
ORDER BY total_revenue DESC;
