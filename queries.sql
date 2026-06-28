-- Step 4: Получить общее количество строк в таблице customers и назвать результирующую колонку customers_count
select count(1) as customers_count
from customers;

-- Step 6.1
with sales_data as (
	select
		sales_person_id,
		concat(e.first_name, ' ', e.last_name) as seller,
		s.product_id,
		p.price,
		SUM(quantity) as product_quantity,
		COUNT(quantity) as product_sales_count
	from sales s 
		inner join products p on p.product_id = s.product_id 
		inner join employees e on s.sales_person_id = e.employee_id 
	group by s.sales_person_id, seller, s.product_id, p.price
)

select 
	seller,
	SUM(product_sales_count) as operations,
	FLOOR(SUM(product_quantity * price)) as income
from sales_data
group by seller
order by income desc
offset 0 limit 10

-- Step 6.2
with 
sales_data as (
	select
		sales_person_id,
		concat(e.first_name, ' ', e.last_name) as seller,
		s.product_id,
		p.price,
		SUM(quantity) as product_quantity,
		COUNT(quantity) as product_sales_count
	from sales s 
		inner join products p on p.product_id = s.product_id 
		inner join employees e on s.sales_person_id = e.employee_id 
	group by s.sales_person_id, seller, s.product_id, p.price
),
income_data as (
	select 
		seller,
		SUM(product_sales_count) as operations,
		FLOOR(SUM(product_quantity * price)) as income
	from sales_data
	group by seller
	order by income desc
),
income_avg_data as (
	select
		seller,
		income,
		operations,
		FLOOR(AVG(income / operations)) as average_income
	from income_data
	group by seller, income, operations
),
income_avg_total_data as (
	select 
		seller,
		average_income,
		FLOOR(AVG(income / operations) over () ) as avg_total_income
	from income_avg_data
)

select 
	seller,
	average_income
from income_avg_total_data
where average_income < avg_total_income
order by average_income asc

-- Step 6.3
with
sales_data as (
	select
		sales_person_id,
		concat(e.first_name, ' ', e.last_name) as seller,
		s.product_id,
		p.price,
		SUM(quantity) as product_quantity,
		COUNT(quantity) as product_sales_count,
		LOWER(TO_CHAR(s.sale_date, 'FMDay')) as day_of_week,
		EXTRACT(ISODOW from s.sale_date) as day_number
	from sales s
	inner join products p on p.product_id = s.product_id 
	inner join employees e on s.sales_person_id = e.employee_id 
	group by s.sales_person_id, seller, s.product_id, p.price, s.sale_date 
)

select
	seller,
	day_of_week,
	SUM(price * product_quantity) OVER (PARTITION BY seller, day_of_week) AS income
from sales_data
order by day_number, seller