# 8 Weeks Challenge: Clique Bait SQL Case Study
## Introduction: 
#### Clique Bait is an online seafood store
#### My task is to support Danny’s, Clique Bait's CEO,  vision and analyze his dataset, and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.
#### Source: <https://8weeksqlchallenge.com/case-study-6/>
## Available Data: 
#### Users
<img width="219" alt="Screenshot 2024-03-07 at 4 09 00 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/8874dc9c-dc0d-463d-8afc-62569acb788d">

#### Events
<img width="432" alt="Screenshot 2024-03-07 at 4 09 57 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/b9486e80-81d0-472b-8a81-816b3bbde06c">

#### Event Identifier
<img width="150" alt="Screenshot 2024-03-07 at 4 10 17 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/831bddc3-9e78-46a7-b262-b365ceeaffe5">

#### Campaign Identifier
<img width="534" alt="Screenshot 2024-03-07 at 4 10 38 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/ad8d465b-2927-47e9-bb96-bfad190edc63">

#### Page Hierarchy
<img width="323" alt="Screenshot 2024-03-07 at 4 11 04 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/6c740719-252d-41b0-b9c8-9106acb48b56">


## 1. Enterprise Relationship Diagram
<img width="872" alt="Screenshot 2024-03-06 at 9 15 58 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/697124e3-f26e-4dc3-96ff-131a5a698fd5">

#### Note: Table Campaign Identifier does not have a direct connection with the other four tables 

## 2. Digital Analysis

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
    count(case when i.event_name = 'Add to Cart' then e.visit_id else null end) num_add_to_cart
from events e
join page_hierarchy p on e.page_id = p.page_id
join event_identifier i on e.event_type = i.event_type
where p.product_category is not null 
group by 1 
order by 1 desc;

````
#### Output: 
<img width="347" alt="Screenshot 2024-03-06 at 11 40 12 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/80423a08-695c-4eaf-90b4-e1b7201832cd">

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

## 3. Product Funnel Analysis
### Q: Create a table to answer the following questions:
	### How many times was each product viewed?
	### How many times was each product added to cart?
	### How many times was each product added to a cart but not purchased (abandoned)?
	### How many times was each product purchased?
 	### Which product had the most views, cart adds and purchases?
	### Which product was most likely to be abandoned?
	### Which product had the highest view to purchase percentage?
	### What is the average conversion rate from view to cart add?
	### What is the average conversion rate from cart add to purchase?
 
````sql
select page_name as product_name, 
count(case when event_name = 'Page view' then visit_id else null end) num_views,
count(case when event_name = 'Add to Cart' then visit_id else null end) num_add_to_cart, 
count(case when event_name = 'Add to Cart' and visit_id not in (select visit_id from events where event_type = 3) then visit_id else null end) num_incomplete_purchase, 
count(distinct case when event_name = 'Add to Cart' and visit_id in (select visit_id from events where event_type = 3) then visit_id else null end) num_purchase,
round(count(case when event_name = 'Add to Cart' then visit_id else null end)/count(case when event_name = 'Page view' then visit_id else null end)*100,2) conversion_rate_view_to_add_to_cart, 
 round(count(case when event_name = 'Add to Cart' and visit_id in (select visit_id from events where event_type = 3) then visit_id else null end) /count(case when event_name = 'Add to Cart' then visit_id else null end)*100,2) conversion_rate_add_to_cart_purchase
from product_table
where product_category is not null
group by 1
order by 6 desc ;
with cte as (
select page_name as product_name, 
count(case when event_name = 'Page view' then visit_id else null end) num_views,
count(case when event_name = 'Add to Cart' then visit_id else null end) num_add_to_cart, 
count(case when event_name = 'Add to Cart' and visit_id not in (select visit_id from events where event_type = 3) then visit_id else null end) num_incomplete_purchase, 
count(distinct case when event_name = 'Add to Cart' and visit_id in (select visit_id from events where event_type = 3) then visit_id else null end) num_purchase,
round(count(case when event_name = 'Add to Cart' then visit_id else null end)/count(case when event_name = 'Page view' then visit_id else null end)*100,2) conversion_rate_view_to_add_to_cart, 
 round(count(case when event_name = 'Add to Cart' and visit_id in (select visit_id from events where event_type = 3) then visit_id else null end) /count(case when event_name = 'Add to Cart' then visit_id else null end)*100,2) conversion_rate_add_to_cart_purchase
from product_table
where product_category is not null
group by 1
order by 6 desc)
````
#### Output: 
<img width="926" alt="Screenshot 2024-03-07 at 10 35 14 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/4c67942b-e435-4c69-b34f-4ac2a0836b1b">

 	1. Oyster is the most viewed product
  	2. Lobster is the most cart adds and purchase
   	3. Russian Caviar is the most likely to be abandoned 
    4. Black Truffle had the highest view to purchase percentage 

````sql
-- use the previous code as cte

select round(avg(conversion_rate_view_to_add_to_cart),2) avg_rate_view_add_to_cart, round(avg(conversion_rate_add_to_cart_purchase),2) avg_rate_add_to_purchase 
from cte;
````

<img width="425" alt="Screenshot 2024-03-07 at 10 30 20 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/c2011a77-702e-4f74-8356-d5e789e1df3e">


## 4. Campaigns Analysis

### Q: Generate a table consisting of the following columns: 

	user_id,
	visit_id,
	visit_start_time: the earliest event_time for each visit,
	page_views: count of page views for each visit,
	cart_adds: count of product cart add events for each visit,
	purchase: flag if a purchase event exists for each visit
	campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
	impression: count of ad impressions for each visit
	click: count of ad clicks for each visit
	cart_products: a comma-separated text value with products added to the cart sorted by the order they were added to the cart 
 
```` sql
drop table if exists users_orders; 
create table users_orders  as (
with cte as (
select distinct e.visit_id, u.user_id, min(e.event_time) start_time, 
sum(case when i.event_name = 'Page View' then 1 else 0 end) num_view_pages,
sum(case when i.event_name = 'Add to Cart' then 1 else 0 end) num_add_to_cart,
sum(case when i.event_name = 'Ad Impression' then 1 else 0 end) num_ad_impression, 
sum(case when i.event_name = 'Ad Click' then 1 else 0 end) num_ad_click,
sum(case when i.event_name = 'Purchase' then 1 else 0 end) purchase, 
group_concat(case when p.product_category is not null and i.event_name = 'Add to Cart' then p.page_name else null end order by e.sequence_number) as cart_products
from events e 
join users u on e.cookie_id = u.cookie_id
join event_identifier i on e.event_type = i.event_type
join page_hierarchy p on p.page_id = e.page_id
group by 1,2)

select c.*, i.campaign_name
from cte c
left join campaign_identifier i on c.start_time between i.start_date and i.end_date
order by user_id, start_time)
;
select user_id, visit_id, start_time, num_view_pages, num_add_to_cart, num_ad_impression, num_ad_click, case when purchase = 1 then 'Yes' else 'No' end purchase, cart_products, campaign_name
from users_orders order by user_id;



````
#### Output: 
<img width="1086" alt="Screenshot 2024-03-07 at 5 41 23 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/5e35f75a-1d99-4925-8984-a9eda0201376">

### Campaign Analysis 
#### Q: How ad impression affect users' purchase behavior? 
```` sql
select 
case when num_ad_impression >0 then 'Yes' else 'No' end as ad_impression, 
count(distinct visit_id) total_num_visits,
sum(purchase) num_purchase, 
round(sum(purchase)/count(distinct visit_id)*100,2) purchasing_rate
from users_orders
group by 1; 
````
<img width="423" alt="Screenshot 2024-03-07 at 9 29 23 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/313a2864-3e35-47f6-b403-c2e43b0e7dab">

	A: Visits with at least one ad impression have a higher rate of purchases compared to visits without ad impressions. 

#### Q: Does clicking into the ad increase the purchase rate?
````sql

select 
case when num_ad_click >0 then 'Yes' else 'No' end as ad_click, 
count(distinct visit_id) total_num_visits,
sum(purchase) num_purchase, 
round(sum(purchase)/count(distinct visit_id)*100,2) purchasing_rate
from users_orders
where num_ad_impression >0
````
<img width="381" alt="Screenshot 2024-03-07 at 9 34 43 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/574fcbe4-ec30-4911-a2c4-e756f5976586">

	A: After further analysis of visits with at least one ad impression, it was found that visits where users clicked on ads had a purchase rate approximately 24% higher than visits where users did not click on ads.

#### Q: What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?

<img width="204" alt="Screenshot 2024-03-07 at 10 12 03 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/20b3253d-3d61-43f7-92c0-656afbcf35fa">


	A: Visits where users received an ad impression and clicked on the ad have the highest purchase rate compared to visits without ad impressions and visits where users received an ad impression but did not click.

 #### Q: Quantify whether the campaign is a success by each campaign 
```sql
select 
case when num_ad_click >0 and num_ad_impression>0  then 'Received and Click'
when num_ad_impression >0 and num_ad_click = 0 then "Received But No Click"
else "Did Not Receive Any" end as Ads, 
round(sum(purchase)/count(distinct visit_id)*100,2) purchase_rate
from users_orders 
group by 1; 

select case when campaign_name is null then "No Campaign" else campaign_name end as campaign_name, 
case when num_ad_impression = 0 then 'No' else 'Yes' end as ad_impression,
count(distinct visit_id) num_visit,
round(sum(purchase)/count(distinct visit_id)*100,2) purchase_rate
from users_orders
group by 1,2

```

<img width="578" alt="Screenshot 2024-03-07 at 10 08 42 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/0ecac2ce-7115-4dd7-a37a-ba7b6265f681">

	A: Using the 'No Campaign' as a benchmark to compare the number of visits, the number of purchases, purchase rate, and average number of viewed pages, the campaign 'Half Off - Treat Your Shellf(ish)' has the highest number of visits and purchases, making it appear to be the most popular campaign

 
