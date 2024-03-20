
CREATE DATABASE IF NOT EXISTS Walmart;

use Walmart;


-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date date,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating decimal(5, 2)
);


LOAD DATA INFILE "F:/Sqlfiles/WalmartSalesData.csv"
INTO TABLE sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'  
IGNORE 1 LINES 
(
  invoice_id,
  branch,
  city,
  customer_type,
  gender,
  product_line,
  unit_price,
  quantity,
  tax_pct,
  total,
  @date,  
  time,
  payment,
  cogs,
  gross_margin_pct,
  gross_income,
  rating
)
SET date = STR_TO_DATE(@date, '%d-%m-%Y');

-- Depending on the time creating a new column whether it is morning, evening or afternoon

select time,
  case
  WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
  WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
  ELSE "Evening" 
  end
  as Period_of_day
  from sales;
  
  alter table sales
  add Period_of_day varchar(30);
  
  update sales
  set Period_of_day= 
                   case
				   WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
                    WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
                   ELSE "Evening" 
                   end;
                   
-- Adding the name of the day
select dayname(date) from sales;

alter table sales
add Dayname varchar(20);

update sales
set Dayname=dayname(date);


-- Add month_name column
select MONTHNAME(date) from sales;

alter table sales 
add Month_name VARCHAR(10);

update sales
set Month_name = MONTHNAME(date);

                   
-- Unique cities count

select distinct(city) as Distinctcity from sales;


-- In which city is each branch?

select distinct city, branch from sales;

-- No of branches in each city

select city, branch, count(branch)  from sales
group by city,branch;


-- Number of unique products

select distinct(product_line) from sales;

-- Gross income by each product_line

select product_line, sum(total) from sales
group by product_line
order by product_line;

-- Most quantity selled product line

select product_line,sum(quantity) as Total_quantity_sold from sales
group by product_line
order by product_line desc;


-- Total revenue by month

select Month_name, sum(total) from sales
group by Month_name;

-- Which product line had the largest revenue?
select product_line, sum(total) as Total_revenue from sales
group by product_line
order by Total_revenue desc;


-- Depending upon the gross_income determine whether it is good, bad or average

select gross_income, (select avg(gross_income) from sales as Average),
     case
     when  gross_income> (select avg(gross_income) from sales) then "Good"
	 when  gross_income between (select avg(gross_income) from sales)+2 and (select avg(gross_income) from sales)-2 then "Average"
	 else "Bad"
     end as status
 from sales;
 
 
 -- Which branch sold more products than average product sold?
 
SELECT 
	branch, 
    SUM(quantity) AS qnty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT avg(quantity) FROM sales);



-- Common product line by gender

select
	gender,
    product_line,
    COUNT(gender) as total_cnt
from sales
group by gender, product_line
order by total_cnt desc;



-- average rating of each product line

select product_line, avg(rating) from sales
group by product_line;



-- Payment methods

select distinct payment from sales;

-- common customer type

select customer_type, count(customer_type) from sales
group by customer_type;


-- which customer type buys the most

select customer_type, count(quantity) from sales
group by customer_type;


--  gender of most of the customers

select gender, count(gender) from sales
group by gender;

-- Which time of the day do customers give most ratings?

select Period_of_day, count(rating) as Rating
from sales
group by Period_of_day
order by rating desc ;


--  Which of the customer types brings the most revenue

select customer_type, sum(total) as Total_Revenue from sales
group by customer_type
order by Total_Revenue desc;
-- 

-- Number of sales made in each time of the day per weekday 

SELECT
	Period_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE Dayname not in ('Sunday', 'Saturday') 
GROUP BY Period_of_day 
ORDER BY total_sales DESC;





select * from sales;
                   
         





