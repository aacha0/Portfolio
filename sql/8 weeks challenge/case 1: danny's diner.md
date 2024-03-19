# 8 Weeks Challenge: Danny's Diner SQL Case Study 
## Introduction: 
#### Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.
#### Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.
#### Source: <https://8weeksqlchallenge.com/case-study-1/>

## Available Data: 

#### Sales
 
<img width="215" alt="Screenshot 2024-03-18 at 5 50 02 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/ba4ae3db-fbc4-4863-a6c8-d50943be1fde">

#### Menu 

<img width="215" alt="Screenshot 2024-03-18 at 5 50 59 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/b844d47f-4767-48dc-8ea9-1353a377d254">

#### Members

<img width="139" alt="Screenshot 2024-03-18 at 5 51 22 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/66d462c4-4fde-4c4c-a9de-a0aa333d1d6c">

## 1. Case Study Questions

### Q: What is the total amount each customer spent at the restaurant?
```sql
select customer_id, sum(m.price) total_spending
 from sales s 
 join menu m on s.product_id = m.product_id
 group by 1
```
#### Output: 

<img width="166" alt="Screenshot 2024-03-18 at 5 53 18 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/c03b7b46-d97f-43f5-b49c-7c34b568a3b4">

### Q: How many days has each customer visited the restaurant?
```sql
select customer_id, count(distinct order_date) num_visiting
 from sales 
 group by 1
```
#### Output: 

<img width="147" alt="Screenshot 2024-03-18 at 5 54 42 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/f2bbcf78-a5ac-4013-b614-5b61bf30ff2d">

### Q: What was the first item from the menu purchased by each customer?
```sql
select distinct customer_id,  m.product_name
 from sales s
 join menu m on s.product_id = m.product_id 
 where (customer_id, order_date) in (select customer_id, min(order_date) from sales group by 1)
```
#### Output: 

<img width="159" alt="Screenshot 2024-03-18 at 5 58 14 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/a070da20-797e-4108-bf44-bb3d43278829">


### Q: What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
with cte as(
 select m.product_name, count(*) cnt,  dense_rank()over(order by count(*) desc) as ranking
 from sales s
 join menu m on s.product_id = m.product_id
 group by 1 )
 select product_name, cnt
 from cte 
 where ranking = 1
 ```

#### Output:
 
<img width="156" alt="Screenshot 2024-03-18 at 8 31 03 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/998def99-c2c9-4560-9339-5971370faeea">


### Q: Which item was the most popular for each customer?
```sql
with cte as(
 select s.customer_id, m.product_name, count(*) cnt
 from sales s
 join menu m on s.product_id = m.product_id
 group by 1,2 
 ) 
 select customer_id, product_name 
 from cte 
 where (customer_id, cnt) in (select customer_id, max(cnt) from cte group by 1)
```
#### Output: 

<img width="176" alt="Screenshot 2024-03-18 at 8 35 02 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/353d0985-72ae-44e1-bf2e-9f247cc35ca8">

### Q: Which item was purchased first by the customer after they became a member?
```sql
 with cte as(
 select s.customer_id, s.order_date, s.product_id, me.product_name, join_date, rank()over(partition by s.customer_id order by order_date) r
 from sales s 
 join members m on s.customer_id =m.customer_id and s.order_date >= m.join_date
 join menu me on me.product_id = s.product_id) 
 
 select customer_id, order_date,join_date, product_id, product_name
 from cte 
 where r = 1
```
#### Output: 

<img width="401" alt="Screenshot 2024-03-18 at 8 42 28 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/5681da05-26c1-42eb-bf3c-fd7376e11f88">

##### Note: I assumed customers signed up for the membership before they made a purchase if they made a purchase and became a member on the same day.

### Q: Which item was purchased just before the customer became a member?
```sql
with cte as(
 select s.customer_id, s.order_date, s.product_id, me.product_name, join_date, rank()over(partition by s.customer_id order by order_date desc)  r
 from sales s 
 join members m on s.customer_id =m.customer_id and s.order_date < m.join_date
 join menu me on me.product_id = s.product_id) 
 
 select customer_id, order_date,join_date, product_id, product_name
 from cte 
 where r = 1
```

#### Output: 

<img width="378" alt="Screenshot 2024-03-18 at 8 46 52 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/201d0a22-b609-4529-be53-aed057882cb9">

### Q: What is the total items and amount spent for each member before they became a member?
```sql
with cte as(
 select s.customer_id, s.order_date, s.product_id, me.product_name, join_date, price
 from sales s 
 join members m on s.customer_id =m.customer_id and s.order_date < m.join_date
 join menu me on me.product_id = s.product_id) 
 select customer_id, sum(price) total_spending, count(product_name) num_items
 from cte
 group by 1
 order by 1
```
#### Output: 

<img width="229" alt="Screenshot 2024-03-18 at 8 54 57 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/2ec5da4b-431f-41a6-86ee-298ec9f4eb7c">

#### Q: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```sql
select s.customer_id, 
 sum(price*(case when product_name = 'sushi' then 2*10 else 10 end)) as total_points
 from sales s 
 join members m on s.customer_id =m.customer_id and s.order_date >= m.join_date
 join menu me on me.product_id = s.product_id
 group by 1
 order by 1
```
#### Output: 

<img width="156" alt="Screenshot 2024-03-18 at 8 59 00 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/400e9ae2-a4f7-432b-ba20-0757ea325ca3">


### Q: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```sql
with cte as (
select s.customer_id, price, product_name, order_date,
case when order_date between order_date and date_add(order_date, interval 6 day) then 20
when order_date > date_add(order_date, interval 6 day) and product_name = 'sushi' then 20
else 10 end as points
from sales s 
join members m on s.customer_id =m.customer_id and s.order_date >= m.join_date
join menu me on me.product_id=s.product_id
where month(order_date) <=1) 

select customer_id, sum(price*points) as total_points 
from cte 
group by 1 
order by 1
```

#### Output: 

<img width="156" alt="Screenshot 2024-03-18 at 9 09 48 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/b55bec3f-1dfe-4d3a-8da7-00aeb335bb85">


## 2. Bonus 
### Join All The Things
### The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

### Recreate the following table output using the available data:
<img width="587" alt="Screenshot 2024-03-18 at 9 11 28 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/d8016366-fbe7-46a2-ae1f-7750ff288bb9">

```sql
create view joined_table as (
select s.customer_id, s.order_date, me.product_name, me.price, 
case when m.customer_id is null then 'N' else 'Y' end as members
from sales s 
join menu me on s.product_id = me.product_id 
left join members m on m.customer_id = s.customer_id and m.join_date<=s.order_date
);
select * from joined_table
```
#### Output: 

<img width="339" alt="Screenshot 2024-03-18 at 9 17 16 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/78c206d2-80a8-4fbd-9bbc-aeb83151f172">


#### Q: Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
```sql
select *, 
case when member = 'Y' then dense_rank()over(partition by member,customer_id order by order_date) else null end as ranking
from joined_table
order by 1
```
#### Output: 

<img width="386" alt="Screenshot 2024-03-18 at 9 21 30 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/3bd61edc-e39a-464d-a291-3ed4b0c89666">
