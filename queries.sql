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