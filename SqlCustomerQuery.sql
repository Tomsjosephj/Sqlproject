CREATE DATABASE Hotel;

USE Hotel;

CREATE TABLE sales(
	customer_id VARCHAR(1),
	order_date DATE,
	product_id INTEGER
);

INSERT INTO sales
	(customer_id, order_date, product_id)
VALUES
	('A', '2021-01-01', 1),
	('A', '2021-01-01', 2),
	('A', '2021-01-07', 2),
	('A', '2021-01-10', 3),
	('A', '2021-01-11', 3),
	('A', '2021-01-11', 3),
	('B', '2021-01-01', 2),
	('B', '2021-01-02', 2),
	('B', '2021-01-04', 1),
	('B', '2021-01-11', 1),
	('B', '2021-01-16', 3),
	('B', '2021-02-01', 3),
	('C', '2021-01-01', 3),
	('C', '2021-01-01', 3),
	('C', '2021-01-07', 3);

CREATE TABLE menu(
	product_id INTEGER,
	product_name VARCHAR(5),
	price INTEGER
);

INSERT INTO menu
	(product_id, product_name, price)
VALUES
	(1, 'sushi', 10),
    (2, 'curry', 15),
    (3, 'ramen', 12);

CREATE TABLE members(
	customer_id VARCHAR(1),
	join_date DATE
);

INSERT INTO members
	(customer_id, join_date)
VALUES
	('A', '2021-01-07'),
    ('B', '2021-01-09'),
	('C', '2021-01-09');
    
-- What is the total amount each customer spent in the restaurant?
    
    select a.customer_id, sum(b.price) from sales as a
    inner join (select product_id,price from menu) as b
    on a.product_id = b.product_id
    group by a.customer_id;
    
    
--  2. How many days has each customer visited the restaurant?
select customer_id, count( distinct order_date) from sales as Total_Visited
group by customer_id;


-- 3. What was the first item from the menu purchased by each customer?


SELECT 
    cfp.customer_id, 
    cfp.first_purchase_date, 
    m.product_name
FROM 
    (SELECT s.customer_id, MIN(s.order_date) AS first_purchase_date
     FROM sales s
     GROUP BY s.customer_id) AS cfp
INNER JOIN 
    sales s ON s.customer_id = cfp.customer_id
           AND cfp.first_purchase_date = s.order_date
INNER JOIN 
    menu m ON m.product_id = s.product_id;
    
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?


select b.product_name, count(*)  as Total_purchased from sales s
inner join (
            select product_id, product_name from menu)as b
on s.product_id=b.product_id
group by b.product_name
order by Total_purchased desc;

-- 5. Which item was the most popular for each customer?

SELECT 
    cp.customer_id, 
    cp.product_name, 
    cp.purchase_count
FROM 
    (
        SELECT 
            s.customer_id, 
            m.product_name, 
            COUNT(*) AS purchase_count
        FROM 
            sales s
        INNER JOIN 
            menu m ON s.product_id = m.product_id
        GROUP BY 
            s.customer_id, m.product_name
    ) AS cp
WHERE
    (cp.customer_id, cp.purchase_count) IN (
        SELECT 
            c.customer_id, 
            MAX(c.purchase_count) AS max_purchase_count
        FROM 
            (
                SELECT 
                    s.customer_id, 
                    m.product_name, 
                    COUNT(*) AS purchase_count
                FROM 
                    sales s
                INNER JOIN 
                    menu m ON s.product_id = m.product_id
                GROUP BY 
                    s.customer_id, m.product_name
            ) AS c
        GROUP BY 
            c.customer_id
    );


--  Calculate Count for Each Product Purchased by Each Customer

select s.customer_id,m.product_name,count(*) as Total_purchase from sales s
inner join menu m 
on m.product_id=s.product_id
group by  s.customer_id,m.product_name;


-- Subqery to Filter Rows with Maximum Purchase Count for Each Customer:

select customer_id,
       max(cp.Total_purchase) as Max_purchase 
from (
select s.customer_id,m.product_name,count(*) as Total_purchase from sales s
inner join menu m 
on m.product_id=s.product_id
group by  s.customer_id,m.product_name

      ) as cp
group by customer_id;


-- 6. Which item was purchased first by the customer after they became a member?

select s.customer_id,
	   s.product_id,
       me.product_name 
from(

      select 
      s.customer_id, 
      min(s.order_date)
      as first_purchase from sales s
          join members m
          on  s.customer_id=m.customer_id
          where s.order_date>= m.join_date
          group by s.customer_id
) as first
join sales s
on s.customer_id= first.customer_id
and first.first_purchase=s.order_date
join menu me
on me.product_id= s.product_id;

-- 7. Which item was purchased just before the customer became a member?
select s.customer_id,
       s.product_id,
       me.product_name  
from (
     select 
     s.customer_id, 
     max(s.order_date) as before_purchase from sales s
     join members m
      on s.customer_id=m.customer_id
      where s.order_date<m.join_date
	  group by s.customer_id
) as first
left join sales s
on s.customer_id=first.customer_id
and first.before_purchase=s.order_date
join menu me
on me.product_id= s.product_id;


-- 8. What is the total items and amount spent for each member before they became a member?

select s.customer_id, 
       count(s.product_id),
       sum(m.price) from sales s
join menu m 
on m.product_id= s.product_id
join members mem
on s.customer_id=mem.customer_id
where s.order_date<mem.join_date
group by s.customer_id ;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select s.customer_id, SUM(
	case
		when m.product_name = 'sushi' then m.price*20 
		else m.price*10 END) AS total_points
from sales s
join menu m on s.product_id = m.product_id
group by s.customer_id;


-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January?*/


SELECT 
    s.customer_id, 
    SUM(
        CASE 
            WHEN s.order_date BETWEEN mb.join_date AND DATE_ADD(mb.join_date, INTERVAL 7 DAY) THEN m.price * 20
            WHEN m.product_name = 'sushi' THEN m.price * 20 
            ELSE m.price * 10 
        END
    ) AS total_points
FROM 
    sales s
JOIN 
    menu m ON s.product_id = m.product_id
LEFT JOIN 
    members mb ON s.customer_id = mb.customer_id
             AND s.order_date <= '2021-01-31'  -- Moved join condition here
GROUP BY 
    s.customer_id;












   
 




    
select * from sales;