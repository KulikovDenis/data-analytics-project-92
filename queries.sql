Данный запрос считает общее количество покупателей из таблицы customers:

select count(customer_id) as customers_count
from customers 


Данный запрос вывод десять лучших продавцов по суммарнной выручке за все время:
select concat(employees.first_name, ' ', employees.last_name) as name,
count(sales.sale_date) AS operations,
COALESCE(round(sum(sales.quantity*products.price), 0), 0) as income
from employees
left join sales on employees.employee_id = sales.sales_person_id
left join products on products.product_id = sales.product_id 
group by employees.first_name, employees.last_name
order by income desc limit 10

