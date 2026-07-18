create database ecommerce_analysis;

create table customers
(
customer_id varchar(50), 
customer_unique_id varchar(50), 
customer_zip_code_prefix int (10), 
customer_city varchar(100), 
customer_state varchar(100)
);
create table orders
(
order_id varchar(50),
customer_id varchar(50),
order_status varchar(20),
order_purchase_timestamp datetime,
order_approved_at datetime,
order_delivered_carrier_date datetime,
order_delivered_customer_date datetime,
order_estimated_delivery_date datetime
);
create table items
(
order_id varchar(50),
order_item_id int,
product_id varchar(50),
seller_id varchar(50),
shipping_limit_date datetime,
price decimal,
freight_value decimal
);
create table payments
(
order_id varchar(50),
payment_sequential int,
payment_type varchar(10),
payment_installments int,
payment_value decimal
);
create table products
(
product_id varchar(50),
product_category_name varchar(100),
product_name_lenght int,
product_description_lenght int,
product_photos_qty int, 
product_weight_g int,
product_length_cm int, 
product_height_cm int,
product_width_cm int
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'datasets/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'datasets/olist_order_payments_dataset.csv'
INTO TABLE payments
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'datasets/olist_order_items_dataset.csv'
INTO TABLE items
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'datasets/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'datasets/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

select COUNT(*) from customers;
select count(*) from orders;
select count(*) from items;
select count(*) from products;
select count(*) from payments;

select c.customer_unique_id, count(distinct o.order_id) as total_orders, round(sum(i.price),2) as total_revenue, round(sum(i.price)/count(distinct o.order_id),2) as avg_order_value, max(o.order_purchase_timestamp) as last_purchase_date 
from customers as c
join orders as o
on c.customer_id=o.customer_id
join items as i
on o.order_id=i.order_id
group by c.customer_unique_id
order by total_revenue desc;

SELECT
    c.customer_unique_id,
    o.order_id,
    o.order_purchase_timestamp,
    i.product_id,
    i.price
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN items i
    ON o.order_id = i.order_id
WHERE c.customer_unique_id = '0a0a92112bd4c708ca5fde585afaa872';

select count(distinct customer_unique_id) as total_customers
from customers;

select count(*) as repeat_customers
from (
select c.customer_unique_id
from customers as c
join orders as o
on c.customer_id=o.customer_id
group by c.customer_unique_id
having count(distinct o.order_id)>1)t;

select c.customer_unique_id, count(distinct o.order_id) as total_orders, round(sum(i.price),2) as total_revenue
from customers as c
join orders as o
on c.customer_id=o.customer_id
join items as i
on o.order_id=i.order_id
group by c.customer_unique_id
order by total_orders desc
limit 10;

with customer_rfm as (
select c.customer_unique_id, 
datediff(
(select max(order_purchase_timestamp)
from orders), max(o.order_purchase_timestamp)
) as recency,
count(distinct o.order_id) as frequency, round(sum(i.price),2) as monetary
from customers as c 
join orders as o
on c.customer_id=o.customer_id
join items as i
on o.order_id=i.order_id
group by c.customer_unique_id
)
select min(recency), min(frequency), min(monetary), max(recency), max(frequency), max(monetary) from customer_rfm;

with customer_rfm as (
select c.customer_unique_id,
datediff(
(select max(order_purchase_timestamp) from orders),
max(o.order_purchase_timestamp)
) as recency,
count(distinct o.order_id) as frequency,
round(sum(i.price),2) as monetary
from customers as c
join orders as o
on c.customer_id=o.customer_id
join items as i
on o.order_id=i.order_id
group by c.customer_unique_id
)

select frequency, count(*) as customer_count
from customer_rfm
group by frequency
order by frequency;

with customer_rfm as (
select c.customer_unique_id,
count(distinct o.order_id) as frequency,
round(sum(i.price),2) as monetary
from customers as c
join orders as o
on c.customer_id=o.customer_id
join items as i 
on o.order_id=i.order_id
group by c.customer_unique_id
)
select 
case 
when monetary<100 then 'Under 100'
when monetary<500 then '100-500'
when monetary<1000 then '500-1000'
when monetary<5000 then '1000-5000'
else '5000+'
end as revenue_bucket,
count(*) as customers
from customer_rfm
group by revenue_bucket
order by customers desc;

with customer_rfm as (
select c.customer_unique_id,
datediff(
(select max(order_purchase_timestamp) from orders),
max(o.order_purchase_timestamp)
) as recency,
count(distinct o.order_id) as frequency,
round(sum(i.price),2) as monetary
from customers as c
join orders as o
on c.customer_id=o.customer_id
join items as i
on o.order_id=i.order_id
group by c.customer_unique_id
), rfm_scores as (
select *,
6-ntile(5) over (order by recency asc) as r_score,
ntile(5) over (order by frequency asc) as f_score,
ntile(5) over (order by monetary asc) as m_score
from customer_rfm
)
select r_score,f_score,m_score,count(*)as customers
from rfm_scores
group by r_score, f_score, m_score
order by customers desc;

with customer_rfm as (
select c.customer_unique_id,
datediff(
(select max(order_purchase_timestamp) from orders),
max(o.order_purchase_timestamp)
) as recency,
count(distinct o.order_id) as frequency,
round(sum(i.price),2) as monetary
from customers as c
join orders as o
on c.customer_id=o.customer_id
join items as i
on o.order_id=i.order_id
group by c.customer_unique_id
), rfm_scores as (
select *,
6-ntile(5) over (order by recency asc) as r_score,
ntile(5) over (order by frequency asc) as f_score,
ntile(5) over (order by monetary asc) as m_score
from customer_rfm
)
SELECT *
FROM rfm_scores
WHERE r_score = 5
  AND f_score = 5
  AND m_score = 4
LIMIT 20;

with customer_rfm as (
select c.customer_unique_id,
datediff(
(select max(order_purchase_timestamp) from orders),
max(o.order_purchase_timestamp)
) as recency,
count(distinct o.order_id) as frequency,
round(sum(i.price),2) as monetary
from customers as c
join orders as o
on c.customer_id=o.customer_id
join items as i
on o.order_id=i.order_id
group by c.customer_unique_id
), rfm_scores as (
select *,
6-ntile(5) over (order by recency asc) as r_score,
ntile(5) over (order by frequency asc) as f_score,
ntile(5) over (order by monetary asc) as m_score
from customer_rfm
), 
customer_segments as (
select *, 
case when r_score >=4 and f_score >=4 and m_score >=4
then 'Champions'
when r_score >=3 and f_score >=4
then 'Loyal Customers'
when r_score <=2 and f_score <=2
then 'At Risk'
else 'Others'
end as segment
from rfm_scores
)
select segment, count(*) as customers
from customer_segments
group by segment
order by customers desc;

with customer_rfm as (
select c.customer_unique_id,
datediff(
(select max(order_purchase_timestamp) from orders),
max(o.order_purchase_timestamp)
) as recency,
count(distinct o.order_id) as frequency,
round(sum(i.price),2) as monetary
from customers as c
join orders as o
on c.customer_id=o.customer_id
join items as i
on o.order_id=i.order_id
group by c.customer_unique_id
), rfm_scores as (
select *,
6-ntile(5) over (order by recency asc) as r_score,
ntile(5) over (order by frequency asc) as f_score,
ntile(5) over (order by monetary asc) as m_score
from customer_rfm
), 
customer_segments as (
select *, 
case when r_score >=4 and f_score >=4 and m_score >=4
then 'Champions'
when r_score >=3 and f_score >=4
then 'Loyal Customers'
when r_score <=2 and f_score <=2
then 'At Risk'
else 'Others'
end as segment
from rfm_scores
)
select segment, 
round(avg(recency),0) as avg_recency,
round(avg(frequency),2) as avg_frequency,
round(avg(monetary),2) as avg_montary
from customer_segments
group by segment;


with customer_rfm as (
select c.customer_unique_id,
datediff(
(select max(order_purchase_timestamp) from orders),
max(o.order_purchase_timestamp)
) as recency,
count(distinct o.order_id) as frequency,
round(sum(i.price),2) as monetary
from customers as c
join orders as o
on c.customer_id=o.customer_id
join items as i
on o.order_id=i.order_id
group by c.customer_unique_id
), rfm_scores as (
select *,
6-ntile(5) over (order by recency asc) as r_score,
ntile(5) over (order by frequency asc) as f_score,
ntile(5) over (order by monetary asc) as m_score
from customer_rfm
), 
customer_segments as (
select *, 
case when r_score >=4 and f_score >=4 and m_score >=4
then 'Champions'
when r_score >=3 and f_score >=4
then 'Loyal Customers'
when r_score <=2 and f_score <=2
then 'At Risk'
else 'Others'
end as segment
from rfm_scores
)
SELECT *
FROM rfm_scores;


with customer_rfm as (
select c.customer_unique_id,
datediff(
(select max(order_purchase_timestamp) from orders),
max(o.order_purchase_timestamp)
) as recency,
count(distinct o.order_id) as frequency,
round(sum(i.price),2) as monetary
from customers as c
join orders as o
on c.customer_id=o.customer_id
join items as i
on o.order_id=i.order_id
group by c.customer_unique_id
), rfm_scores as (
select *,
6-ntile(5) over (order by recency asc) as r_score,
ntile(5) over (order by frequency asc) as f_score,
ntile(5) over (order by monetary asc) as m_score
from customer_rfm
), 
customer_segments as (
select *, CASE WHEN r_score >= 4 AND m_score >= 4
THEN 'High Value Active'
WHEN r_score <= 2 AND m_score >= 4
THEN 'High Value At Risk'
WHEN r_score >= 4 AND m_score <= 2
THEN 'Recent Low Value'
WHEN r_score <= 2 AND m_score <= 2
THEN 'At Risk'
ELSE 'Regular Customers'
END AS segment
from rfm_scores
)
select segment, count(*) as customers
from customer_segments
group by segment
order by customers desc;

with customer_rfm as (
select c.customer_unique_id,
datediff(
(select max(order_purchase_timestamp) from orders),
max(o.order_purchase_timestamp)
) as recency,
count(distinct o.order_id) as frequency,
round(sum(i.price),2) as monetary
from customers as c
join orders as o
on c.customer_id=o.customer_id
join items as i
on o.order_id=i.order_id
group by c.customer_unique_id
), rfm_scores as (
select *,
6-ntile(5) over (order by recency asc) as r_score,
ntile(5) over (order by frequency asc) as f_score,
ntile(5) over (order by monetary asc) as m_score
from customer_rfm
), 
customer_segments as (
select *, CASE WHEN r_score >= 4 AND m_score >= 4
THEN 'High Value Active'
WHEN r_score <= 2 AND m_score >= 4
THEN 'High Value At Risk'
WHEN r_score >= 4 AND m_score <= 2
THEN 'Recent Low Value'
WHEN r_score <= 2 AND m_score <= 2
THEN 'At Risk'
ELSE 'Regular Customers'
END AS segment
from rfm_scores
)
SELECT *
FROM rfm_scores;

select date_format(o.order_purchase_timestamp, '%y-%m') as month,
round(sum(i.price),2) as revenue
from orders as o
join items as i
on o.order_id=i.order_id
group by month
order by month;

select date_format(order_purchase_timestamp, '%y-%m') as month,
count(distinct order_id) as total_orders
from orders
group by month
order by month;


select date_format(o.order_purchase_timestamp, '%y-%m') as month,
count(distinct o.order_id) as total_orders,
round(sum(i.price),2) as total_revenue,
round(sum(i.price)/count(distinct o.order_id),2) as avg_order_value
from orders as o
join items as i
on o.order_id=i.order_id
group by month
order by month;

select p.product_category_name as catergory,
count(distinct i.order_id) as total_orders,
round(sum(i.price),2) as total_revenue,
round(avg(i.price),2) as avg_product_price,
count(distinct i.product_id) as unique_products,
round(sum(i.price)*100 / sum(sum(i.price)) over(),2) as revenue_share_percent
from items as i
join products as p
on i.product_id=p.product_id
group by catergory
order by total_revenue desc;

SELECT s.customer_state_full as customer_state,
COUNT(DISTINCT o.order_id) AS total_orders,
COUNT(DISTINCT c.customer_unique_id) AS total_customers,
ROUND(SUM(i.price), 2) AS total_revenue,
ROUND(AVG(i.price), 2) AS avg_order_value
FROM state_names as s
join customers as c
on s.customer_state=c.customer_state
JOIN orders as o
ON c.customer_id = o.customer_id
JOIN items as i
ON o.order_id = i.order_id
GROUP BY customer_state
ORDER BY total_revenue DESC;