create database SuperMarket;

use SuperMarket;

show tables;

select * from customers;
select * from categories;
select * from order_details;
select * from orders;
select * from payments;
select * from products;

-- Retrieve the full names and email addresses of all customers who live in city 'Patriciabury'. --
select concat(first_name,' ', last_name) as full_name, email 
from customers 
where city = 'Patriciabury';

-- List all orders along with the customer’s full name and the total amount paid, including the discount applied. -- 
SELECT o.order_id, CONCAT(c.first_name, ' ', c.last_name) AS full_name, 
SUM(od.quantity * od.sold_price) AS total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_id, full_name;

-- Find the total quantity of each product sold and the total revenue generated from each product. -- 
SELECT pd.product_name, SUM(od.quantity) AS total_quantity_sold, 
SUM(od.quantity * od.sold_price *(1-od.discount)) AS total_revenue
FROM products pd
JOIN order_details as od ON pd.product_id = od.product_id
GROUP BY pd.product_name;

-- Count the number of orders by their status (e.g., pending, shipped, completed) and display the result. --
select count(status) as count, status from orders as o
group by status;

-- Retrieve the number of products available in each category. -- 
select c.category_name, count(c.category_id) as total_product 
from categories as c
join products as pd
on c.category_id = pd.category_id
group by c.category_name;

-- Identify the top 5 customers who have spent the most on orders. --
select c.customer_id, ROUND(sum(od.sold_price*od.quantity*(1-od.discount)),2) as Total, 
concat(c.first_name,' ', c.last_name) as full_name from customers as c
join orders as o on c.customer_id = o.customer_id
join order_details as od on o.order_id = od.order_id
GROUP BY c.customer_id, full_name
order by Total desc
limit 5;

-- Retrieve all orders placed in the last 30 days, along with the order details. --
SELECT o.order_id, o.order_date, od.product_id, od.quantity, od.sold_price
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
WHERE o.order_date >= CURDATE() - INTERVAL 30 DAY;

-- Calculate the percentage of total payments made using each payment method. --
select payment_method, 
ROUND((sum(amount) / (select sum(amount) from payments) * 100), 2) AS total_percentage 
from payments
GROUP BY payment_method;

-- List all products that have a stock quantity below 100. --
select product_id, product_name, stock_quantity from products
where stock_quantity < 100;

-- Calculate the total revenue generated per month over the last year. --
SELECT DATE_FORMAT(p.payment_date, '%Y-%m') AS month, SUM(p.amount) AS total_revenue
FROM payments p
WHERE p.payment_date >= CURDATE() - INTERVAL 1 YEAR
GROUP BY month
ORDER BY month;

-- Determine the total sales for each product category. -- 
select c.category_id, c.category_name, 
round(sum(od.sold_price * od.quantity*(1 - od.discount)),2) AS total_revenue
from categories c
join products p on c.category_id = p.category_id
join order_details od on p.product_id = od.product_id
group by c.category_id, c.category_name;


-- Find all orders that have not yet been shipped and the number of days since they were placed. --
select order_id, status, DATEDIFF(CURDATE(), order_date) as order_days from orders
where shipped_date IS NULL;

-- Determine the number of orders each customer has placed and rank customers based on order frequency. --
select customer_id, count(customer_id) as total_orders from orders
group by customer_id
order by total_orders;

-- Retrieve all orders where a discount was applied and calculate the total discount amount for each order. --
select order_id, round(sum(quantity*sold_price*discount),2) as total_discount 
from order_details
where discount > 0
group by order_id;

-- Retrieve all payments made within '2024-01-01' and '2024-12-31', along with the corresponding order and customer details. --
SELECT o.order_id, p.amount, p.payment_date, c.customer_id, 
CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM payments p
JOIN orders o ON p.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE p.payment_date BETWEEN '2024-01-01' AND '2024-01-31'; 

-- Find the customers who have placed more than 5 orders and have a total spending of over 5000. --
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
COUNT(o.order_id) AS total_orders, 
SUM(p.amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) > 5 AND SUM(p.amount) > 5000;

-- Retrieve all cities where customers are available.--
select city from customers
group by city;

