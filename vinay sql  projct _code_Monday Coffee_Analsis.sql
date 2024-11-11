create  database  Monday_Coffee;
use Monday_Coffee;
CREATE TABLE city
(
city_id int  primary  key,  	
city_name varchar(50),
population int,  	
estimated_rent float,  	
city_rank int  
);
CREATE  TABLE customers
(customer_id int  primary  key ,
customer_name varchar(50),
city_id int,
constraint fk_city FOREIGN KEY (city_id) references city(city_id)  
);
CREATE  TABLE  products
( 
product_id int  primary  key,	
product_name  varchar(50),	
price  float
);
CREATE  TABLE  sales
(
sale_id	int  primary  key,
sale_date	date,
product_id	int,
customer_id	 int,
total	float ,
rating int,
constraint fk_products foreign key (product_id) references products (product_id),
constraint fk_customers foreign key (customer_id) references customers (customer_id)
);
-- Monday coffee data analysis 
SELECT * FROM city;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM sales;

-- - question-1 coffee consumers count
-- How  many  peoople  in  each city are  estimated to consume  coffee ,given  that 25% of the  population does ?
SELECT  
city_name,
(population*0.25)/1000000 as  coffee_consumers ,
city_rank
FROM  city
ORDER  BY 2 DESC;

-- 2.Total  revenue  from  coffee sales
-- what  is  total revenue  generated  from coffee sales all  cities in the  last  quarter of  2023?

SELECT ci.city_name,
 sum(s.total) as total_revenue
 FROM sales as  s
 join customers as c
 on s.customer_id=c.customer_id
 join city as ci
 on ci.city_id = c.city_id
WHERE
 extract(year from s.sale_date) = 2023
 and  
 extract(quarter from  s.sale_date) = 4
 group  by 1
 order  by  2;
 
-- 3.sales  count  of each product
-- how  many units  of each produc have been sold ?

SELECT p.product_name,
count(s.sale_id) as  total_order
FROM products as  p
left join  sales as  s
on  s.product_id=p.product_id
group by 1
order  by 2  desc ;

-- 4.Average  sales  amount  per  city ?
-- what  is average  sales  amount  per customers  in  each days?
SELECT ci.city_name,
sum(s.total) as total_revenue,
count(distinct s.customer_id) as total_customers,
ROUND(
SUM(s.total)/
count(distinct s.customer_id)
,2) as  avg_sale
 FROM sales as  s
 join customers as c
 on s.customer_id=c.customer_id
 join city as ci
 on ci.city_id = c.city_id
  group  by 1
 order  by  2 desc;
 
 
--  Q.5 city population and  consumerrs
-- provide a  list of  city along  with their  population and  esimated  coffee consumers

with city_table as 
(SELECT 
city_name,
ROUND((population *0.25)/1000000,2) as coffee_cunsummers
FROM city
),
customerS_table
as
( 
SELECT 
ci.city_name,
count(distinct c.customer_id) as  unique_customer
FROM sales as s
join  customers as c
on c.customer_id=s.customer_id
join city  as  ci
on ci.city_id=c.city_id
group  by 1
)
SELECT  
ci.city_name,
ci.coffee_cunsummers as  coffee_conssumers,
ci.unique_customer
from city_table
join customers_table
on city_table.city_name=ci.city_name;


-- q.6 top selling  product by  city
-- what  is the  top 3 selling products in ach city based  on sales  volume ?

SELECT * 
FROM  
(Select  
ci.city_name,
p.product_name,
count(s.sale_id) as  total_orders,
dense_rank() over (partition by ci.city_name order by count(s.sale_id) DESC) as ranks
from  sales as s
join products as  p
on s.product_id=p.product_id
join customers as c 
on c.customer_id=s.customer_id
join city as ci
on  c.city_id=ci.city_id
group  by  1,2
-- order by 1,3 desc
 ) as  t1
 WHERE ranks<=3;
 
 
 -- 7.customers segmentation  by city
--  how  many  unique  customers  are  there  in eacch  city  who  have  purchased  coffee products

 SELECT  ci.city_name,
 count(distinct c.customer_id) as  unique_cx
 FROM  city as ci
 LEFT join  customers as c
 on  ci.city_id=c.city_id
 join sales as s 
 on  c.customer_id=s.customer_id
 where 
 s.product_id in (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
 group  by  1;
 
 -- 8 avg sales  vs  rent
 -- fid  each city their  avg  sales  per  customers  and  avg  rent  per  customers 
 with  city_table
 as 
 (
 SELECT ci.city_name,
count(distinct s.customer_id) as total_customers,
ROUND(
SUM(s.total)/
count(distinct s.customer_id)
,2) as  avg_sale
 FROM sales as  s
 join customers as c
 on s.customer_id=c.customer_id
 join city as ci
 on ci.city_id = c.city_id
  group  by 1
 order  by  2 desc ),
 
city_rent
 AS 
 (select  city_name
 estimated_rent 
 from  city )
  
select 
 cr.city_name,
 cr.estimated_rent
 city_rent
 from city_rent as  cr
 join city_table as  ct
 on cr.city_name=ct.city_name; 
 
--  -  --9 Monthly  sales  growth
 -- calculate  % sales  growth  rate on sales  overs  diff  time period  monthly by each city
 
 with monthly_sales 
 as 
 (SELECT 
 ci.city_name,
 EXTRACT(MONTH from sale_date ) as month,
 EXTRACT(YEAR from sale_date ) as year,
 SUM(s.total) as total_sale
 from  sales as  s 
 join customers as c 
 on  s.customer_id=c.customer_id
 join city as ci
 on  ci.city_id=c.city_id
 group  by 1,2,3
 ORDER BY  1,3 ),
growth_ratio 
as 
(
 Select
 city_name,
 month,
 year,
 total_sale as  cr_month_sale,
 LAG(total_sale,1) over (partition by city_name order by  city_name,month) as  last_month_sale
 from  monthly_sales)
 Select  
 city_name,
 month,
 year,
 cr_month_sale,
 last_month_sale,
 cr_month_sale-last_month_sale/last_month_sale *100
 as  growth_ratio
 from   growth_ratio;
 
 
 




