Данный запрос считает общее количество покупателей из таблицы customers:

select count(customer_id) as customers_count
from customers;


Данный запрос выводит десять лучших продавцов по суммарнной выручке за все время:
select concat(employees.first_name, ' ', employees.last_name) as name,
count(sales.sale_date) AS operations,
COALESCE(round(sum(sales.quantity*products.price), 0), 0) as income
from employees
left join sales on employees.employee_id = sales.sales_person_id
left join products on products.product_id = sales.product_id 
group by employees.first_name, employees.last_name
order by income desc limit 10;

Данный запрос выводит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам:
with av as (
	select concat(employees.first_name, ' ', employees.last_name) as name,
	COALESCE(round(sum(sales.quantity*products.price)/count(sales.sale_date), 0), 0) as average_income
	from employees
	left join sales on employees.employee_id = sales.sales_person_id
	left join products on products.product_id = sales.product_id 
	group by employees.first_name, employees.last_name
)
select *
from av
where average_income < (select 
	COALESCE(round(sum(sales.quantity*products.price)/count(sales.sale_date), 0), 0) as average
	from employees
	left join sales on employees.employee_id = sales.sales_person_id
	left join products on products.product_id = sales.product_id
)
order by average_income;

Данный запрос выводит информацию о выручке по дням недели:
with week as (select concat(employees.first_name, ' ', employees.last_name) as name,
case EXTRACT(DOW FROM sales.sale_date)
	WHEN 0 THEN 'sunday'
	WHEN 1 THEN 'monday'
	WHEN 2 THEN 'tuesday'
	WHEN 3 THEN 'wednesday'
	WHEN 4 THEN 'thursday'
	WHEN 5 THEN 'friday'
	WHEN 6 THEN 'saturday'
end as weekday,
coalesce(round(sum(sales.quantity*products.price), 0), 0) as income
from employees
left join sales on employees.employee_id = sales.sales_person_id
left join products on products.product_id = sales.product_id 
group by employees.first_name, employees.last_name, weekday
)

select name, weekday, income
from week
where income > '0'
order by case weekday
	WHEN 'monday' THEN 1
	WHEN 'tuesday' THEN '2'
	WHEN 'wednesday' THEN '3'
	WHEN 'thursday' THEN '4'
	WHEN 'friday' THEN '5'
	WHEN 'saturday' THEN '6'
	when 'sunday' THEN '7'
end, name;