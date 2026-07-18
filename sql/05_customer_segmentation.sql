WITH customer_rfm AS (
    SELECT
        c.customer_unique_id,
        DATEDIFF(
            (SELECT MAX(order_purchase_timestamp) FROM orders),
            MAX(o.order_purchase_timestamp)
        ) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(i.price), 2) AS monetary
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    JOIN items AS i
        ON o.order_id = i.order_id
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
    SELECT
        *,
        6 - NTILE(5) OVER (ORDER BY recency ASC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM customer_rfm
),
customer_segments AS (
    SELECT
        *,
        CASE
            WHEN r_score >= 4 AND m_score >= 4 THEN 'High Value Active'
            WHEN r_score <= 2 AND m_score >= 4 THEN 'High Value At Risk'
            WHEN r_score >= 4 AND m_score <= 2 THEN 'Recent Low Value'
            WHEN r_score <= 2 AND m_score <= 2 THEN 'At Risk'
            ELSE 'Regular Customers'
        END AS segment
    FROM rfm_scores
)
SELECT
    segment,
    COUNT(*) AS customers
FROM customer_segments
GROUP BY segment
ORDER BY customers DESC;

WITH customer_rfm AS (
    SELECT
        c.customer_unique_id,
        DATEDIFF(
            (SELECT MAX(order_purchase_timestamp) FROM orders),
            MAX(o.order_purchase_timestamp)
        ) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(i.price), 2) AS monetary
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    JOIN items AS i
        ON o.order_id = i.order_id
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
    SELECT
        *,
        6 - NTILE(5) OVER (ORDER BY recency ASC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM customer_rfm
),
customer_segments AS (
    SELECT
        *,
        CASE
            WHEN r_score >= 4 AND m_score >= 4 THEN 'High Value Active'
            WHEN r_score <= 2 AND m_score >= 4 THEN 'High Value At Risk'
            WHEN r_score >= 4 AND m_score <= 2 THEN 'Recent Low Value'
            WHEN r_score <= 2 AND m_score <= 2 THEN 'At Risk'
            ELSE 'Regular Customers'
        END AS segment
    FROM rfm_scores
)
SELECT *
FROM customer_segments;