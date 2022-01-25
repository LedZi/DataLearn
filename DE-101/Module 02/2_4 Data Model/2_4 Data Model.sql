-- Creation of tables

-- Table1
drop table if exists customer_dim;
CREATE TABLE customer_dim
(
 customer_dim_id serial NOT NULL,
 customer_id     varchar(10) NOT NULL,
 customer_name   varchar(30) NOT NULL,
 segment         varchar(15) NOT NULL,
 CONSTRAINT PK_14 PRIMARY KEY ( customer_dim_id )
);

-- Table2
drop table if exists geo_dim;
CREATE TABLE geo_dim
(
 geo_dim_id  serial NOT NULL,
 country     varchar(15) NOT NULL,
 city        varchar(25) NOT NULL,
 "state"       varchar(25) NOT NULL,
 postal_code int NOT NULL,
 region      varchar(50) NOT NULL,
 CONSTRAINT PK_35 PRIMARY KEY ( geo_dim_id )
);

-- Table3
drop table if exists order_date_dim;
CREATE TABLE order_date_dim
(
 order_date_dim_id serial NOT NULL,
 order_date        date NOT NULL,
 year              int NOT NULL,
 quarter           int NOT NULL,
 month             int NOT NULL,
 week              int NOT NULL,
 week_day          int NOT NULL,
 CONSTRAINT PK_25 PRIMARY KEY ( order_date_dim_id )
);

-- Table4
drop table if exists product_dim;
CREATE TABLE product_dim
(
 product_dim_id serial NOT NULL,
 product_id     varchar(20) NOT NULL,
 category       varchar(20) NOT NULL,
 sub_category   varchar(20) NOT NULL,
 product_name   varchar(130) NOT NULL,
 CONSTRAINT PK_43 PRIMARY KEY ( product_dim_id )
);

-- Table5
drop table if exists ship_mode_dim;
CREATE TABLE ship_mode_dim
(
 ship_mode_id serial NOT NULL,
 ship_mode    varchar(15) NOT NULL,
 CONSTRAINT PK_9 PRIMARY KEY ( ship_mode_id )
);

-- Table6
drop table if exists sales_fact;
CREATE TABLE sales_fact
(
 sales_fact_id     serial NOT NULL,
 order_id          varchar(20) NOT NULL,
 order_date_dim_id serial NOT NULL,
 customer_dim_id   serial NOT NULL,
 product_dim_id    serial NOT NULL,
 ship_mode_id      serial NOT NULL,
 geo_dim_id        serial NOT NULL,
 ship_date         date NOT NULL,
 sales             numeric(10,2) NOT NULL,
 quantity          integer NOT NULL,
 discount          numeric(4,2) NOT NULL,
 profit            numeric(10,2) NOT NULL,
 CONSTRAINT PK_5 PRIMARY KEY ( sales_fact_id ),
 CONSTRAINT FK_63 FOREIGN KEY ( geo_dim_id ) REFERENCES geo_dim ( geo_dim_id ),
 CONSTRAINT FK_69 FOREIGN KEY ( ship_mode_id ) REFERENCES ship_mode_dim ( ship_mode_id ),
 CONSTRAINT FK_72 FOREIGN KEY ( product_dim_id ) REFERENCES product_dim ( product_dim_id ),
 CONSTRAINT FK_75 FOREIGN KEY ( customer_dim_id ) REFERENCES customer_dim ( customer_dim_id ),
 CONSTRAINT FK_78 FOREIGN KEY ( order_date_dim_id ) REFERENCES order_date_dim ( order_date_dim_id )
);

CREATE INDEX FK_65 ON sales_fact
(
 geo_dim_id
);

CREATE INDEX FK_71 ON sales_fact
(
 ship_mode_id
);

CREATE INDEX FK_74 ON sales_fact
(
 product_dim_id
);

CREATE INDEX FK_77 ON sales_fact
(
 customer_dim_id
);

CREATE INDEX FK_80 ON sales_fact
(
 order_date_dim_id
);



-- Upload data into tables

update orders 
set postal_code = 05401
where postal_code is null;

-- insert into customer_dim
insert into customer_dim (customer_id, customer_name, segment)
select customer_id, customer_name, segment
from orders
group by customer_id, customer_name, segment
order by customer_name;

select * from customer_dim cd 

-- insert into geo_dim
insert into geo_dim (country, city, state, region, postal_code)
select country, city, state, region, postal_code
from orders
group by country, city, state, region, postal_code
order by city;

select * from geo_dim gd 

-- Можно еще так
--select row_number() over(), 
--	country, 
--	city, 
--	state, 
--	postal_code, 
--	region 
--from (select distinct country, city, state, postal_code, region from orders) a;

-- insert into product_dim
insert into product_dim (category, sub_category, product_name, product_id)
select category, subcategory, product_name, product_id
from orders
group by category, subcategory, product_name, product_id
order by product_id;

select * from product_dim pd 

-- insert into ship_mode_dim
insert into ship_mode_dim (ship_mode)
select distinct ship_mode
from orders
order by ship_mode;

select * from ship_mode_dim smd 

--insert into order_date_dim
insert into order_date_dim (order_date, year, quarter, month, week, week_day)
select order_date, extract (year from order_date) as year, 
                   extract (quarter from order_date) as quarter, 
                   extract (month from order_date) as month,
                   extract (week from order_date) as week,
                   extract (day from order_date) as week_day              
from orders
group by 1
order by 1;

select *, 
count(*) over() as num
from order_date_dim odd 

--insert into sales_fact
insert into sales_fact (order_id, sales, quantity, discount, profit, customer_dim_id, product_dim_id, 
order_date_dim_id, geo_dim_id, ship_mode_id, ship_date)
select order_id, sales, quantity, discount, profit, customer_dim_id, product_dim_id, 
order_date_dim_id, geo_dim_id, ship_mode_id, ship_date
from orders
inner join customer_dim on orders.customer_id = customer_dim.customer_id
inner join geo_dim on orders.postal_code = geo_dim.postal_code and orders.city = geo_dim.city
inner join ship_mode_dim on orders.ship_mode = ship_mode_dim.ship_mode
inner join order_date_dim on orders.order_date = order_date_dim.order_date
inner join product_dim on orders.product_id = product_dim.product_id and orders.product_name = product_dim.product_name
order by orders.order_id;



--9994 rows?
select count(*) from sales_fact;


--custom query for BI
select * 
from sales_fact sf 
inner join customer_dim on sf.customer_dim_id = customer_dim.customer_dim_id
inner join geo_dim on sf.geo_dim_id = geo_dim.geo_dim_id
inner join ship_mode_dim on sf.ship_mode_id = ship_mode_dim.ship_mode_id
inner join order_date_dim on sf.order_date_dim_id = order_date_dim.order_date_dim_id 
inner join product_dim on sf.product_dim_id = product_dim.product_dim_id 























