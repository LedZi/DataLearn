-- Total Sales and Total Profit
select round(sum(sales),2) as total_sales, round(sum(profit),2) as total_profit
from orders o 

--Profit Ratio
select round(sum(profit)/sum(sales),2) as profit_ratio
from orders o 

--Profit Per Order
select order_id, sum(sales) as sales_order, sum(profit) as profit_per_order, round(sum(profit)/sum(sales),2) as profit_ratio
from orders o 
group by order_id 
order by 1

--Sales per Customer
select customer_id, round(sum(sales),2) as sales_per_customer
from orders o 
group by customer_id 
order by 2 desc

--Average discount
select order_id, avg(discount)
from orders o 
group by order_id 
order by 2 desc

--Monthly Sales by Segment
select extract(year from order_date) as year, extract (month from order_date) as month, segment, round(sum(sales),2) as sales
from orders o 
group by 1, 2, 3
order by 1, 2, 3

--Monthly Sales by Product Category
select extract(year from order_date) as year, extract (month from order_date) as month, category, round(sum(sales),2) as sales
from orders o 
group by 1, 2, 3
order by 1, 2, 3

-- Sales by Product Category over time
select category, round(sum(sales),2) as sales
from orders o 
group by 1
order by 2 desc

-- Customer Analysis
select customer_id, round(sum(sales),2) as sales, round(sum(profit),2) as profit
from orders o 
group by 1
order by 2 desc

-- Customer Ranking
select customer_id, rank () over (order by sum(profit) desc) as customer_rank, round(sum(sales),2) as sales, round(sum(profit),2) as profit
from orders o 
group by 1
order by 2

-- Sales per region
select region, round(sum(sales),2) as sales_per_region
from orders o 
group by region
order by 2 desc 