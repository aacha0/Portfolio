# 8 Weeks Challenges: Pizza Runner
## Introduction: 
#### Did you know that over 115 million kilograms of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…)
#### Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”
#### Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!
#### Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.
#### Source: <https://8weeksqlchallenge.com/case-study-2/> 
## Available Data: 

#### Runners

#### Customer_orders

#### Runner_orders 

#### Pizza_names

#### Pizza_id 

#### Pizza_toppings

## 1. Pizza Metrics

### Q: How many pizzas were ordered?
```sq
select count(*) as num_pizzas
from customer_orders;

```
#### Output:
<img width="97" alt="Screenshot 2024-03-16 at 7 24 05 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/3bc0877f-2bc0-4e20-9193-a7011e6b0bbc">

### Q: How many unique customer orders were made?

```sql
select count(distinct order_id) num_orders
from customer_orders
;
```
#### Output:

<img width="101" alt="Screenshot 2024-03-16 at 9 38 44 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/4851a232-8699-488b-ab54-1e6c6d47fdf1">


### Q: How many successful orders were delivered by each runner?
```sql
-- cleaned data first
-- replaced empty string or 'null' values from cancellation column with NULL

update runner_orders
set cancellation = null 
where cancellation =  '' or cancellation = 'null';

-- count how many orders that were not canceled
select runner_id,count(distinct order_id) num_delivered_orders
from runner_orders
where cancellation is null
group by 1;
```
#### Output:

<img width="190" alt="Screenshot 2024-03-16 at 9 40 16 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/349137dc-3f07-47e3-8b09-7bece11693e6">


### Q: How many of each type of pizza was delivered?

```sql

select n.pizza_name, count(*) num_pizzas
from customer_orders c
join pizza_names n on c.pizza_id = n.pizza_id 
where c.order_id in (select order_id from runner_orders where cancellation is null) 
group by 1;

```

#### Output: 

<img width="144" alt="Screenshot 2024-03-16 at 7 42 46 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/31cf1145-24f6-433e-b051-4c8fc66fecf6">


### Q: How many Vegetarian and Meatlovers were ordered by each customer?
```sql
with cte as (
select distinct c.customer_id, p.pizza_id,p.pizza_name
from customer_orders c
cross join pizza_names p
)
select a.customer_id, a.pizza_name, count(c.order_id) 
from cte a 
left join customer_orders c on a.customer_id = c.customer_id and a.pizza_id = c.pizza_id
group by 1,2

```
#### Output:

<img width="218" alt="Screenshot 2024-03-16 at 9 37 13 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/7180db88-8ebc-4028-bd92-5c2d0ad15275">


### Q: What was the maximum number of pizzas delivered in a single order?

```sql
with cte as(
select c.order_id, count(c.customer_id) num_pizzas
from customer_orders c
join runner_orders r on c.order_id = r.order_id 
where r.cancellation is  null 
group by 1 )
select *
from cte 
where num_pizzas in (select max(num_pizzas) from cte)
```

#### Output: 
<img width="148" alt="Screenshot 2024-03-16 at 9 49 12 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/0ab071d8-7b18-4bb7-870a-c322d523a4f0">


### Q: For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

```sql
-- cleand the data
-- replaced  empty string or 'null' values from extras and exclusions columns with NULL

update customer_orders 
set exclusions = null 
where exclusions = '' or exclusions = 'null';

update customer_orders 
set extras = null 
where extras = '' or extras = 'null';

-- created a view to store orders that were delivered 
drop view if exists delivered_orders;
create view delivered_orders as(
select c.*
from customer_orders c
join runner_orders r on c.order_id = r.order_id 
where r.cancellation is null) ;

select customer_id, 
count(case when exclusions is not null or extras is not null then order_id else null end) adjusted_orders,
count(case when exclusions is  null and extras is  null then order_id else null end) no_change_orders, 
count(order_id) 
from delivered_orders
group by 1

```
#### Output: 

<img width="292" alt="Screenshot 2024-03-16 at 10 01 40 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/301d13b4-e867-4156-bef6-f8c1da0f7da8">

### Q: How many pizzas were delivered that had both exclusions and extras?

<img width="223" alt="image" src="https://github.com/aacha0/Portfolio/assets/148589444/b1c78654-48e4-4f69-9200-1c1abf929d44">


### Q: What was the total volume of pizzas ordered for each hour of the day?

### Q: What was the volume of orders for each day of the week?
