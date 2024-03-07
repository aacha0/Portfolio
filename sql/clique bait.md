# Danny Ma - Clique Bait
## Introduction: 
#### Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry!
## Available Data: 
#### Users, Events, Event Identifier, Campaign Identifier, and Page Hierarchy

### 1. Enterprise Relationship Diagram
<img width="872" alt="Screenshot 2024-03-06 at 9 15 58 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/697124e3-f26e-4dc3-96ff-131a5a698fd5">

#### Note: Table Campaign Identifier does not have a direct connection with the other four tables 

### 2. Digital Analysis

### Q: How many users are there?
````sql
select count(distinct user_id) as number_of_users
from users
````
#### Output:
<img width="154" alt="Screenshot 2024-03-06 at 9 22 37 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/5694ad0e-da8c-46c4-ad25-eececc25611c">

### Q: How many cookies does each user have on average?
````sql
with cte as (
select user_id, count(cookie_id) cookie_num
from users
group by 1) 
select round(avg(cookie_num),2) avg_num_cookies
from cte
````
#### Output:
<img width="117" alt="Screenshot 2024-03-06 at 9 27 10 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/ece172bd-5406-4422-90fd-56d23be26a79">
##### On average, each user has 3.56 cookies

### Q: What is the unique number of visits by all users per month?
````sql
select monthname(event_time) as month, count(distinct e.visit_id) num_visits
from users u 
join events e on u.cookie_id = e.cookie_id
group by 1
order by 2 desc
````

#### Output: 
<img width="123" alt="Screenshot 2024-03-06 at 10 48 20 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/7e20a3e9-5e83-45a5-b2d5-1b460b0150a3">
 
### Q: What is the number of events for each event type?
```sql
select i.event_name,e.event_type, count(*) num_events
from events e 
join event_identifier i
on e.event_type = i.event_type
group by 1,2

````
#### Output:
<img width="217" alt="Screenshot 2024-03-06 at 9 37 54 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/cca1cbf9-e863-4c75-9c5b-5a3b1c890234">

##### Page view is the most frequent action/event followed by add to cart, purchase, ad impression, and ad click

### Q: What is the percentage of visits which have a purchase event?
```` sql
select 
round(count(distinct case when i.event_name = 'Purchase' then visit_id else null end)/count(distinct case when i.event_name = 'Page View' then visit_id else null end)*100,2) purchase_percentage
from events e 
join event_identifier i
on e.event_type = i.event_type

````
#### Output: 
<img width="139" alt="Screenshot 2024-03-06 at 9 56 59 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/c5b18108-8e62-47b9-b007-332c42bd32d9">

### Q: What is the percentage of visits which view the checkout page but do not have a purchase event?
````sql
with cte as (
select 
e.visit_id
from events e
join page_hierarchy p on p.page_id = e.page_id
where p.page_name = 'Checkout' )


select round(count(visit_id)/(select count(distinct visit_id) from cte)*100,2) incomplete_purchase
from cte 
where visit_id not in (select visit_id from events where event_type = 3) 

````
#### Output
<img width="155" alt="Screenshot 2024-03-06 at 11 08 03 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/6949f3a6-c2a1-419f-b200-c0c79fc3ce1d">


### Q: What are the top 3 pages by number of views?
````sql
with cte as (
select e.page_id, p.page_name, count(*) num_visits, dense_rank()over(order by count(visit_id) desc) as r
from events e
join page_hierarchy p on e.page_id = p.page_id
group by 1,2 )

select page_id, page_name, num_visits
from cte 
where r<= 3
order by r
-- I could simply order the table by the 'num_visits' in descending order and limit it to 3 rows. However, this approach will not accurately reflect the top 3 if there's a tie. Therefore, I created a CTE to rank 'page_name' based on the 'num_visits' first, and then retrieve the records that are ranked in the top 3
````
<img width="184" alt="Screenshot 2024-03-06 at 10 12 57 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/62cccea9-3e11-433d-8640-e3da70e364b6">

### Q: What is the number of views and cart adds for each product category?
```` sql

select p.product_category, 
	count(case when i.event_name = 'Page View' then e.visit_id else null end) num_view_page, 
	count(distinct case when i.event_name = 'Page View' then e.visit_id else null end) num_unique_visit_id_view_page, 
    count(case when i.event_name = 'Add to Cart' then e.visit_id else null end) num_add_to_cart,
    count(distinct case when i.event_name = 'Add to Cart' then e.visit_id else null end) num_unique_visit_id_add_to_cart
from events e
join page_hierarchy p on e.page_id = p.page_id
join event_identifier i on e.event_type = i.event_type
group by 1 
order by 1 desc

````
<img width="786" alt="Screenshot 2024-03-06 at 10 29 18 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/2fb06fd2-286a-4637-a1ed-635672e0bc50">

### Q: What are the top 3 products by purchases?

````sql
with cte as (
select visit_id, e.page_id, p.page_name, e.event_type 
from events e
join event_identifier i on e.event_type= i.event_type
join page_hierarchy p on p.page_id = e.page_id
where i.event_name = 'Add to Cart' and visit_id in (select visit_id from events where event_type = 3 ) )

select page_name, count(distinct visit_id) num_purchase
from cte 
group by 1
order by 2 desc 
limit 3 

````
#### Output: 
<img width="155" alt="Screenshot 2024-03-06 at 11 15 16 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/babec2aa-74b7-40e8-b887-1c58ebb8a44b">

