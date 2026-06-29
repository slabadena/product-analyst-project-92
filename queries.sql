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
WITH sales_data AS (
    SELECT
        s.sales_person_id,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        s.product_id,
        p.price,
        s.quantity,
        s.sale_date,
        EXTRACT(ISODOW FROM s.sale_date) AS day_of_week_number,
        LOWER(TO_CHAR(s.sale_date, 'FMDay')) AS day_of_week
    FROM sales s
    INNER JOIN products p
        ON p.product_id = s.product_id
    INNER JOIN employees e
        ON s.sales_person_id = e.employee_id
)

SELECT
    seller,
    day_of_week,
    FLOOR(SUM(price * quantity)) AS income
FROM sales_data
GROUP BY
    seller,
    day_of_week_number,
    day_of_week
ORDER BY
    day_of_week_number ASC,
    seller ASC;

-- Step 7.1
WITH age_data AS (
    SELECT
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            ELSE '40+'
        END AS age_category
    FROM customers
)
SELECT
    age_category,
    COUNT(*) AS age_count
FROM age_data
GROUP BY age_category
ORDER BY
    CASE
        WHEN age_category = '16-25' THEN 1
        WHEN age_category = '26-40' THEN 2
        ELSE 3
    END;

-- Step 7.2
WITH sales_data AS (
    select
    	s.customer_id,
        s.product_id,
        p.price,
        SUM(s.quantity) as quantity,
        TO_CHAR(sale_date, 'YYYY-MM') AS selling_month
    FROM sales s
    INNER JOIN products p
        ON p.product_id = s.product_id
    INNER JOIN customers c
        ON c.customer_id = s.customer_id
    group by selling_month, s.product_id, p.price, s.customer_id
    order by selling_month asc
),
income_data as (
	select
		selling_month,
		COUNT(distinct customer_id) as total_customers,
		FLOOR(SUM(price * quantity)) as income
	from sales_data
	group by selling_month
)

select * from income_data