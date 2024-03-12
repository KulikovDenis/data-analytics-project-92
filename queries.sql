/*Общее количество покупателей из таблицы customers*/

select count(customer_id) as customers_count
from customers;


/*Десять лучших продавцов по суммарнной выручке за все время*/
select
    concat(employees.first_name, ' ', employees.last_name) as seller,
    count(sales.sale_date) as operations,
    coalesce(floor(sum(sales.quantity * products.price)), 0) as income
from employees
left join sales on employees.employee_id = sales.sales_person_id
left join products on sales.product_id = products.product_id
group by employees.first_name, employees.last_name
order by income desc limit 10;

/*Продавцы, чья ср. выручка сделки меньше ср. выручки сделки по всем продавцам*/
with av as (
    select
        concat(employees.first_name, ' ', employees.last_name) as seller,
        floor(sum(s.quantity * p.price) / count(s.sale_date)) as average_income
    from employees as e
    left join sales as s on e.employee_id = s.sales_person_id
    left join products as p on s.product_id = p.product_id
    group by employees.first_name, employees.last_name
)

select *
from av
where
    average_income < (
        select floor(sum(s.quantity * p.price) / count(s.sale_date)) as average
        from employees as e
        left join sales as s on e.employee_id = s.sales_person_id
        left join products as p on s.product_id = p.product_id
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

select
    seller,
    day_of_week,
    income
from tab;

/*Количество покупателей в разных возрастных группах*/
select
    age_category,
    count(*) as age_count
from (
    select
        first_name,
        last_name,
        age,
        case
            when age between 16 and 25 then '16-25'
            when age between 26 and 40 then '26-40'
            when age > 40 then '40+'
        end as age_category
    from customers
)
group by age_categor
order by age_category;


/*Количество уникальных покупателей и выручке, которую они принесли*/
select
    to_char(s.sale_date, 'yyyy-MM') as selling_month,
    count(distinct concat(c.first_name, ' ', c.last_name)) as total_customers,
    floor(sum(s.quantity * p.price)) as income
from customers as c
inner join sales as s on customers.customer_id = s.customer_id
inner join products as p on s.product_id = p.product_id
group by selling_month
order by selling_month;


/*Покупатели, первая покупка которых была в ходе проведения акций*/
select
    customer,
    sale_date,
    seller
from (
    select
        c.customer_id,
        s.sale_date,
        s.sales_id,
        p.price
        concat(e.first_name, ' ', e.last_name) as seller,
        concat(c.first_name, ' ', c.last_name) as customer,
    from sales as s
    inner join customers as c on s.customer_id = c.customer_id
    inner join products as p on s.product_id = p.product_id
    inner join employees as e on s.sales_person_id = e.employee_id
    group by c.customer_id, s.sale_date, s.sales_id, p.price, seller, customer
    having p.price = 0
    order by c.customer_id, s.sale_date
);
