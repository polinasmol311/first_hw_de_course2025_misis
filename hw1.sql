-- создание таблиц
create table users (
	id int primary key,
	name char varying(100),
	email char varying(100),
	created_at timestamp
)

create table categories (
	id int primary key,
	name char varying(100)
)

create table products (
	id int primary key,
	name char varying(100),
	price numeric(10,2),
	category_id int references categories (id)
)

create table orders (
	id int primary key,
	user_id int references users (id),
	status char varying(50),
	created_at timestamp
)

create table order_items(
	id int primary key,
	order_id int references orders (id),
	product_id int references products (id),
	quantity int 
)

create table payments (
	id int primary key,
	order_id int references orders (id),
	amount numeric(10,2),
	payment_date timestamp 
)

--задача 1
with order_totals as (
	select c.name category_name, o.id orders_id, sum(p.price * oi.quantity) sum_products
	from categories c 
	join products p on c.id = p.category_id
	join order_items oi on p.id = oi.product_id
	join orders o on oi.order_id = o.id
	where date_part('month', o.created_at::timestamp) = 3
	group by c.name , o.id
)

select category_name, avg(sum_products) avg_order_amount from order_totals group by category_name

--задача 2
select users.name user_name, 
sum(payments.amount) total_spent, 
rank() over(order by sum(payments.amount) desc)  
from users 
join orders on users.id = orders.user_id 
join payments on payments.order_id = orders.id 
where orders.status = 'Оплачен'
group by users.name limit 3

--задача 3
select TO_CHAR(o.created_at::timestamp, 'YYYY-MM') month, 
count(*) total_orders, 
sum(p.amount) total_payments 
from payments p 
join orders o on p.order_id = o.id 
group by month 
order by month

--задача 4
select 
p.name product_name, 
sum(oi.quantity) total_sold, 
round(sum(oi.quantity)::numeric / (select sum(oi.quantity) from order_items oi) * 100, 2) sales_percantage 
from products p 
join order_items oi on p.id = oi.product_id
group by p.name
order by total_sold desc limit 5

--задача 5 
select u.name user_name, sum(p.amount) total_spent 
from users u 
join orders o on u.id = o.user_id
join payments p on o.id = p.order_id 
where o.status = 'Оплачен' 
group by u.name 
having sum(amount) > (select avg(sum_amount) 
						from (select sum(p.amount) sum_amount 
						from payments p 
						join orders o on p.order_id = o.id 
						where o.status = 'Оплачен' 
						group by o.user_id)