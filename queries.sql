/*Общее количество покупателей из таблицы customers*/

select count(customer_id) as customers_count
from customers;


/*Десять лучших продавцов по суммарнной выручке за все время*/
select
    concat(employees.first_name, ' ', employees.last_name) as seller,
    count(sales.sale_date) as operations,
    coalesce(floor(sum(sales.quantity * products.price)), 0) as income
from employees
left join sales on sales.sales_person_id = employees.employee_id
left join products on products.product_id = sales.product_id
group by employees.first_name, employees.last_name
order by income desc limit 10;

/*Продавцы, чья ср. выручка сделки меньше ср. выручки сделки по всем продавцам*/
with av as (
    select
	    concat(employees.first_name, ' ', employees.last_name) as seller,
	    floor(sum(sales.quantity * products.price) / count(sales.sale_date)) as average_income
    from employees
    left join sales on sales.sales_person_id = employees.employee_id
    left join products on products.product_id = sales.product_id 
    group by employees.first_name, employees.last_name
)

    select
        *
    from av
    where average_income < (select 
	    floor(sum(sales.quantity * products.price) / count(sales.sale_date)) as average
	    from employees
	    left join sales on employees.employee_id = sales.sales_person_id
	    left join products on products.product_id = sales.product_id
    )
order by average_income;

/*Информация о выручке по дням недели*/
with tab as (
    select *
    from (
        select
            concat(e.first_name, ' ', e.last_name) as seller,
            to_char(s.sale_date, 'day') as day_of_week,
            to_char(s.sale_date, 'ID') as id,
            floor(sum(s.quantity * p.price)) as income
        from employees as e
        inner join sales as s on e.employee_id = s.sales_person_id
        inner join products as p on s.product_id = p.product_id
        group by seller, day_of_week, id
    )
    order by id, seller
)
select seller, day_of_week, income
from tab;

/*Количество покупателей в разных возрастных группах*/
select 
	age_category,
	count(1) as age_count  
	from (
select first_name, last_name, age,
case 
when age between 16 and 25 then '16-25'
when age between 26 and 40 then '26-40'
when age > 40 then '40+'
end as age_category
from customers
) a
group by age_category order by 1;


/*Количество уникальных покупателей и выручке, которую они принесли*/
select 
	to_char(sale_date , 'yyyy-MM') as selling_month,
	count(distinct  concat(first_name,' ', last_name))as total_customers,
	floor(sum(quantity*price)) as income
from customers
join sales on customers.customer_id = sales.customer_id
join products on sales.product_id = products.product_id
group by selling_month
order by selling_month;


/*Покупатели, первая покупка которых была в ходе проведения акций*/
select 
	customer,
	sale_date,
	seller 
from (
select 
distinct on(c.customer_id) c.customer_id, 
concat(c.first_name,' ', c.last_name) as customer, 
sale_date, 
sales_id, 
concat(e.first_name,' ', e.last_name) as seller, 
p.price 
from sales s
join customers c on c.customer_id = s.customer_id
join products p on s.product_id = p.product_id
join employees e on s.sales_person_id = e.employee_id
group by 1, 2, 3, 4, 5, 6
having price = 0
order by 1, 3
) a;
