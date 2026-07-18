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
)
SELECT
    MIN(recency) AS min_recency,
    MIN(frequency) AS min_frequency,
    MIN(monetary) AS min_monetary,
    MAX(recency) AS max_recency,
    MAX(frequency) AS max_frequency,
    MAX(monetary) AS max_monetary
FROM customer_rfm;

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
)
SELECT
    frequency,
    COUNT(*) AS customer_count
FROM customer_rfm
GROUP BY frequency
ORDER BY frequency;

WITH customer_rfm AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(i.price), 2) AS monetary
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    JOIN items AS i
        ON o.order_id = i.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN monetary < 100 THEN 'Under 100'
        WHEN monetary < 500 THEN '100-500'
        WHEN monetary < 1000 THEN '500-1000'
        WHEN monetary < 5000 THEN '1000-5000'
        ELSE '5000+'
    END AS revenue_bucket,
    COUNT(*) AS customers
FROM customer_rfm
GROUP BY revenue_bucket
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
)
SELECT
    r_score,
    f_score,
    m_score,
    COUNT(*) AS customers
FROM rfm_scores
GROUP BY r_score, f_score, m_score
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
)
SELECT *
FROM rfm_scores
WHERE r_score = 5
  AND f_score = 5
  AND m_score = 4
LIMIT 20;
