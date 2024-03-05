Данный запрос считает общее количество покупателей из таблицы customers:

select count(customer_id) as customers_count
from customers 


Данный запрос выводит десять лучших продавцов по суммарнной выручке за все время:
select concat(employees.first_name, ' ', employees.last_name) as name,
count(sales.sale_date) AS operations,
COALESCE(round(sum(sales.quantity*products.price), 0), 0) as income
from employees
left join sales on employees.employee_id = sales.sales_person_id
left join products on products.product_id = sales.product_id 
group by employees.first_name, employees.last_name
order by income desc limit 10

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
order by average_income