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

```sql
select count(*) num_extra_excluded_toppings_pizzas
from delivered_orders
where extras is not null and exclusions is not null ;
```

#### Output: 

<img width="223" alt="image" src="https://github.com/aacha0/Portfolio/assets/148589444/b1c78654-48e4-4f69-9200-1c1abf929d44">


### Q: What was the total volume of pizzas ordered for each hour of the day?

```sql
select hour(order_time) hour_day, count(*) num_orders
from customer_orders
group by 1
order by 1
```

#### Output: 

<img width="125" alt="Screenshot 2024-03-16 at 10 19 59 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/171b1b26-eca1-46d9-b5eb-dd29a3f2bfbf">

### Q: What was the volume of orders for each day of the week?

```sql
select date_format(order_time,'%W') day_of_week, count(*) num_orders
from customer_orders
group by 1;
```

#### Output:

<img width="143" alt="Screenshot 2024-03-16 at 10 23 01 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/ab0cc4bb-40c7-42a6-8a66-b56e59324042">

## 2. Runner and Customer Experience
### Q: How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

```sql
select date_format(registration_date, '%U') week, count(*) num_runners
from runners 
group by 1 ;
```

<img width="120" alt="Screenshot 2024-03-16 at 10 31 32 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/961046a2-b878-4f55-9270-c1726c301ec3">

### Q: What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
```sql
select r.runner_id,  round(avg((timestampdiff(minute,c.order_time ,r.pickup_time))),2) avg_pick_up
from customer_orders c
join runner_orders r on c.order_id = r.order_id 
group by 1
```
#### Output:

<img width="132" alt="Screenshot 2024-03-16 at 10 51 09 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/04b42176-7ad2-4206-8cee-ff974aa7e6dc">

### Q: Is there any relationship between the number of pizzas and how long the order takes to prepare?

```sql
with cte as(
select distinct c.order_id, round((timestampdiff(minute,c.order_time ,r.pickup_time)),2) preparing_period
from customer_orders c
join runner_orders r on c.order_id = r.order_id ), 
cte1 as(
select order_id, count(*) num_orders
from customer_orders 
group by 1)
select a.order_id, b.num_orders, a.preparing_period
from cte a
join cte1 b on a.order_id = b.order_id
where preparing_period is not null
order by 2 desc

```
#### Output: 

<img width="272" alt="Screenshot 2024-03-16 at 11 09 36 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/cb202a9b-b125-4efa-8407-e3130eafaec1">


### Q: What was the average distance travelled for each customer?
```sql
-- replaced empty string and 'null' value with NULL
update runner_orders 
set distance = null 
where distance = 'null' ;

update runner_orders 
set pickup_time = null
where pickup_time = 'null';

update runner_orders 
set duration = null
where duration = 'null';

-- removed units to make data consistant 
UPDATE runner_orders
SET distance = REGEXP_REPLACE(distance, '[^0-9.]', '')
WHERE distance REGEXP '[^0-9.]';

UPDATE runner_orders
SET duration = REGEXP_REPLACE(duration, '[^0-9.]', '')
WHERE duration REGEXP '[^0-9.]';

select c.customer_id,  concat(round(avg(r.distance),2),' km') avg_distance 
from runner_orders r
join customer_orders c on r.order_id = c.order_id 
group by 1


```
#### Output:
<img width="147" alt="Screenshot 2024-03-16 at 11 27 13 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/3bacfe14-07c1-412c-ab8d-116fa427e812">

### Q: What was the difference between the longest and shortest delivery times for all orders?

```sql
select max(duration)-min(duration) time_diff
from runner_orders r
where duration is not null
;
```
#### Output:

<img width="56" alt="Screenshot 2024-03-16 at 11 42 25 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/e3130de9-6a39-4328-80be-3370a7e3e5b6">


### Q: What was the average speed for each runner for each delivery and do you notice any trend for these values?

```sql
SELECT 
  r.runner_id, 
  c.customer_id, 
  c.order_id, 
  COUNT(c.order_id) AS pizza_count, 
  r.distance, (r.duration / 60) AS duration_hr , 
  ROUND((r.distance/r.duration * 60), 2) AS avg_speed
FROM runner_orders r
JOIN customer_orders c
  ON r.order_id = c.order_id
WHERE distance != 0
GROUP BY r.runner_id, c.customer_id, c.order_id, r.distance, r.duration
ORDER BY c.order_id;

```

#### Output:

<img width="505" alt="Screenshot 2024-03-16 at 11 51 01 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/58c23a33-e41a-4631-bc97-7434d1e5748f">


### Q: What is the successful delivery percentage for each runner?

```sql
select runner_id, 
round(sum(case when cancellation is null then 1 else 0 end)/count(*)*100,2) successful_pct
from runner_orders
group by 1
```
#### Output: 
<img width="162" alt="Screenshot 2024-03-16 at 11 54 26 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/484586bd-447f-45f0-becd-b0ed5d1102b0">


## 3. Ingredient Optimisation
### Q: What are the standard ingredients for each pizza?

```sql
-- ungrouped topping ids
drop view if exists toppings;
create view toppings as (
with cte as(
with recursive num as(
select 1 as n 
union 
select n+1 from num
where n< 15 ) 
select pizza_id, substring_index(substring_index(toppings,',',n),',',-1) topping
from pizza_recipes 
join num 
on n<= length(toppings)-length(replace(toppings,',',''))+1
order by 1)
select pizza_id, topping, topping_name
from cte c 
join pizza_toppings t on c.topping = t.topping_id
) ;



select n.pizza_name, group_concat(topping_name) toppings
from toppings t 
join pizza_names n on n.pizza_id = t.pizza_id
group by 1

```

#### Output: 

<img width="446" alt="Screenshot 2024-03-17 at 12 33 43 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/7bae8556-8104-4ce5-b040-9722a6ad8b38">

### Q: What was the most commonly added extra?
```sql
with cte as(
with recursive num as(
select 1 as n 
union 
select n+1 from num
where n<=5)

select 
trim(substring_index(substring_index(extras, ',',n),',',-1)) extras, count(*) num_pizzas
from customer_orders c
join num 
where n<= length(extras)-length(replace(extras,',',''))+1
group by 1) 

select extras topping_id, topping_name, num_pizzas
from cte c
join pizza_toppings t on c.extras = t.topping_id
where num_pizzas in (select max(num_pizzas) from cte) 
```

<img width="254" alt="Screenshot 2024-03-17 at 12 46 44 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/1556ac0b-dbac-4adc-8607-43604b610145">

### Q: What was the most common exclusion?
```sql
with cte as(
with recursive num as(
select 1 as n 
union 
select n+1 from num
where n<=5)

select 
trim(substring_index(substring_index(exclusions, ',',n),',',-1)) exclusions, count(*) num_pizzas
from customer_orders c
join num 
where n<= length(exclusions)-length(replace(exclusions,',',''))+1
group by 1) 

select exclusions topping_id, topping_name, num_pizzas
from cte c
join pizza_toppings t on c.exclusions = t.topping_id
where num_pizzas in (select max(num_pizzas) from cte) 
```
#### Output: 

<img width="254" alt="Screenshot 2024-03-17 at 12 48 06 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/529e9ca3-9c92-4fe9-8aea-bd9e2e7af3a4">

### Q: Generate an order item for each record in the customers_orders table in the format of one of the following:
  ### Meat Lovers
  ### Meat Lovers - Exclude Beef
  ### Meat Lovers - Extra Bacon
  ### Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

```sql
-- create a view to store table that have exclusions and extras to be in topping_name instead of topping_id
drop view if exists customer_orders_details;
create view customer_orders_details as(
with cte as(
select order_id, customer_id, pizza_id, 
substring_index(trim(exclusions),',',1) exclu1, 
case when substring_index(trim(exclusions),',',1) = substring_index(trim(exclusions),',',-1) then null else substring_index(trim(exclusions),',',-1) end exclu2,
coalesce(substring_index(trim(extras),',',1),'') extra1, 
case when substring_index(trim(extras),',',1) = substring_index(trim(extras),',',-1) then null else substring_index(trim(extras),',',-1) end extra2, 
row_number()over(partition by order_id, pizza_id) r
from customer_orders)
select order_id, customer_id, a.pizza_id,b.pizza_name, 
 concat(c.topping_name,coalesce(concat(', ',d.topping_name),''))exclusions, 
  concat(e.topping_name,coalesce(concat(', ',f.topping_name),''))extras,r
from cte a 
join pizza_names b on a.pizza_id = b.pizza_id
left join pizza_toppings c on c.topping_id = a.exclu1
left join pizza_toppings d on d.topping_id = a.exclu2
left join pizza_toppings e on e.topping_id = a.extra1
left join pizza_toppings f on f.topping_id = a.extra2) ;

select order_id, customer_id, 
case when exclusions is null and extras is null then pizza_name
when exclusions is not null and extras is null then concat(pizza_name,' - Exclude ',exclusions)
 when extras is not null and exclusions is null then concat(pizza_name,' - Extra ',extras)
 else concat(pizza_name,' - Exclude ',exclusions, ' - Extra ',extras) end as customer_orders
from customer_orders_details;
```
#### Output: 
<img width="549" alt="Screenshot 2024-03-17 at 10 48 30 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/5c43a271-b34b-4f80-937a-a360db942bb4">

### Q: Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
### Q: For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
```sql
with cte as(
select c.*,
substring_index(trim(exclusions),',',1) exclu1, 
case when substring_index(trim(exclusions),',',1) = substring_index(trim(exclusions),',',-1) then null else substring_index(trim(exclusions),',',-1) end exclu2,
substring_index(trim(extras),',',1) extra1, 
case when substring_index(trim(extras),',',1) = substring_index(trim(extras),',',-1) then null else substring_index(trim(extras),',',-1) end extra2,
 t.topping_name
from customer_orders_details c 
join toppings t on c.pizza_id = t.pizza_id
order by 1),
cte1 as(
(select order_id, customer_id, pizza_id, pizza_name, r,
case when topping_name = exclu1 or topping_name = trim(leading ' ' from exclu2) then null else topping_name end as topping
from cte)
union all 
(select distinct order_id, customer_id, pizza_id,pizza_name, r, extra1
from cte 
where extra1 is not null )
union all
(select distinct order_id, customer_id, pizza_id, pizza_name, r, trim(leading ' ' from extra2)
from cte 
where extra2 is not null )
) ,
cte2 as (
select order_id, customer_id, pizza_id,pizza_name, r, topping, count(topping) cnt,
case when count(topping) >1  then concat(count(topping),'X',topping) else topping end as num_topping
from cte1
group by 1,2,3,4,5,6
having cnt >0 
order by cnt
) 
select order_id, customer_id, 
concat(pizza_name, ' : ', group_concat(num_topping order by topping)) as order_details
from cte2
group by order_id, customer_id, pizza_name, r
```
#### Output: 

<img width="665" alt="Screenshot 2024-03-18 at 1 59 50 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/c463a943-d195-419c-81bb-3ed3ffee7f7d">

### Q: What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

```sql
with cte as(
select c.*,
substring_index(trim(exclusions),',',1) exclu1, 
case when substring_index(trim(exclusions),',',1) = substring_index(trim(exclusions),',',-1) then null else substring_index(trim(exclusions),',',-1) end exclu2,
substring_index(trim(extras),',',1) extra1, 
case when substring_index(trim(extras),',',1) = substring_index(trim(extras),',',-1) then null else substring_index(trim(extras),',',-1) end extra2,
 t.topping_name
from customer_orders_details c 
join toppings t on c.pizza_id = t.pizza_id
order by 1),
cte1 as(
(select order_id, customer_id, pizza_id, pizza_name, r,
case when topping_name = exclu1 or topping_name = trim(leading ' ' from exclu2) then null else topping_name end as topping
from cte)
union all 
(select distinct order_id, customer_id, pizza_id,pizza_name, r, extra1
from cte 
where extra1 is not null )
union all
(select distinct order_id, customer_id, pizza_id, pizza_name, r, trim(leading ' ' from extra2)
from cte 
where extra2 is not null )
) 
select topping, count(topping) cnt
from cte1
where topping is not null
group by 1
order by cnt desc
```
#### Output: 

<img width="151" alt="Screenshot 2024-03-18 at 2 03 57 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/52740ad4-5720-45db-bf62-64e495b72a69">


#### Bacon is the most popular ingredient. Onions, Peppers, Tomatoes, and Tomato Sauce are tied to the last place. 
