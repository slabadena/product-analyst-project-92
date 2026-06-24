-- Step 4: Получить общее количество строк в таблице customers и назвать результирующую колонку customers_count
select count(1) as customers_count
from customers;

-- Step 5.1
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

-- Step 5.2
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
		FLOOR(SUM(product_quantity * price)) as income,
		FLOOR(AVG(product_quantity * price)) as avg_income_per_deal
	from sales_data
	group by seller
	order by income desc
),
avg_income_data as (
	select 
		seller,
		income,
		avg_income_per_deal,
		FLOOR(AVG(income) over () ) as avg_total_income
	from income_data
)

select 
	seller,
	avg_income_per_deal as average_income
from avg_income_data
where avg_income_per_deal < avg_total_income
order by avg_income_per_deal asc

-- Step 5.3
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