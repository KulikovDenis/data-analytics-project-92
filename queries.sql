/*Данный запрос считает общее количество покупателей из таблицы customers*/

select count(customer_id) as customers_count
from customers;


/*Данный запрос выводит десять лучших продавцов по суммарнной выручке за все время*/
select concat(employees.first_name, ' ', employees.last_name) as seller,
count(sales.sale_date) AS operations,
COALESCE(FLOOR(sum(sales.quantity*products.price)), 0) as income
from employees
left join sales on employees.employee_id = sales.sales_person_id
left join products on products.product_id = sales.product_id 
group by employees.first_name, employees.last_name
order by income desc limit 10;

/*Данный запрос выводит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам*/
with av as (
	select concat(employees.first_name, ' ', employees.last_name) as seller,
	floor(sum(sales.quantity*products.price)/count(sales.sale_date)) as average_income
	from employees
	left join sales on employees.employee_id = sales.sales_person_id
	left join products on products.product_id = sales.product_id 
	group by employees.first_name, employees.last_name
)
select *
from av
where average_income < (select 
	floor(sum(sales.quantity*products.price)/count(sales.sale_date)) as average
	from employees
	left join sales on employees.employee_id = sales.sales_person_id
	left join products on products.product_id = sales.product_id
)
order by average_income;

/*Данный запрос выводит информацию о выручке по дням недели*/
with tab as(
select * from (select concat(first_name,' ', last_name) as seller, to_char(sale_date, 'day') as day_of_week, to_char(sale_date, 'ID') as id,
floor(sum(quantity*price)) as income from employees 
join sales on employee_id=sales_person_id
join products on sales.product_id=products.product_id
group by 1, 2, 3) a
order by 3, seller)
select seller, day_of_week, income from tab;

/*Данный запрос выводит количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+*/
select age_category, count(1) as age_count  from(
select first_name, last_name, age,
case 
when age between 16 and 25 then '16-25'
when age between 26 and 40 then '26-40'
when age > 40 then '40+'
end as age_category
from customers)a
group by age_category order by 1;


/*Данный запрос выводит данные по количеству уникальных покупателей и выручке, которую они принесли*/
SELECT TO_CHAR(sale_date , 'yyyy-MM') as selling_month,
count(distinct  concat(first_name,' ', last_name))as total_customers,
floor(sum(quantity*price)) as income
FROM customers
join sales on customers.customer_id = sales.customer_id
join products on sales.product_id=products.product_id
group by selling_month
order by selling_month;


/*Данный запрос выводит данные о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0)*/
select customer, sale_date, seller from (
select 
distinct on(c.customer_id) c.customer_id, 
concat(c.first_name,' ', c.last_name) as customer, 
sale_date, 
sales_id, 
concat(e.first_name,' ', e.last_name) as seller, 
p.price 
from sales s
join customers c on c.customer_id=s.customer_id
join products p on s.product_id=p.product_id
join employees e on s.sales_person_id=e.employee_id
group by 1,2,3,4,5,6
having price=0
order by 1,3
)a;