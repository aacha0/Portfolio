# 8 Weeks Challenge: Balanced Tree Clothing Co. SQL Case Study
## Introduction: 
#### Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!
#### Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business.
#### Source: <https://8weeksqlchallenge.com/case-study-7/

## Available Data: 
#### Product Details
balanced_tree.product_details includes all information about the entire range that Balanced Clothing sells in their store.

<img width="748" alt="Screenshot 2024-03-08 at 6 34 08 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/a8a11821-00cf-43dd-926b-c611b0858cfc">

#### Product Sales
balanced_tree.sales contains product level information for all the transactions made for Balanced Tree including quantity, price, percentage discount, member status, a transaction ID and also the transaction timestamp.

<img width="390" alt="Screenshot 2024-03-08 at 6 34 38 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/02dbff6e-8e86-48a2-b806-90e73422a5ec">

#### Product Hierarchy 

<img width="254" alt="Screenshot 2024-03-08 at 6 35 28 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/1376f85c-2552-477b-be14-4a5bcd4bc3f8">

#### Product Price

<img width="177" alt="Screenshot 2024-03-08 at 6 35 49 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/3e8b42e8-0afb-4cb3-8b54-fcb10fc76a51">

## 1. High Level Sales Analysis 
### Q: What was the total quantity sold for all products?
````sql
select sum(qty) total_sold_qty from sales;
````
#### Output: 
<img width="88" alt="Screenshot 2024-03-08 at 6 40 20 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/bd4c138a-aaa7-4fec-8f6f-ebbbbc65b5b1">

### Q: What is the total generated revenue for all products before discounts?

````sql
select sum(qty*price) total_sales from sales;
````
#### Output: 
<img width="115" alt="Screenshot 2024-03-08 at 6 43 09 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/b3812ce6-c70c-4111-bfe0-7eede9dcc1d2">


### Q: What was the total discount amount for all products?

```sql
select round(sum(discount/100*price),2) discount_amt from sales;
````
#### Output: 
<img width="91" alt="Screenshot 2024-03-08 at 6 52 39 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/d634ad83-8edc-49c9-96cc-ec94b1245ab7">

## 2. Transaction Analysis
### Q: How many unique transactions were there?

```sql
select count(distinct txn_id) num_unique_txn_id from sales
```
#### Output: 
<img width="170" alt="Screenshot 2024-03-08 at 7 03 42 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/79c1e783-a890-44cb-ac86-aae06fcb3edf">

### Q: What is the average unique products purchased in each transaction?
```sql
with cte as (
select txn_id, count(distinct prod_id) num_product
from sales 
group by 1)

select round(avg(num_product),2) avg_unique_num_product
from cte
```
#### Output: 
<img width="155" alt="Screenshot 2024-03-08 at 7 06 32 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/88c21701-216b-45f5-8fdb-4128b3f068d2">

### Q: What are the 25th, 50th and 75th percentile values for the revenue per transaction?
```sql
WITH cte AS
(SELECT txn_id,
        SUM(qty * price) AS revenue
 FROM balanced_tree.sales
 GROUP BY 1)

SELECT percentile_cont(0.25) WITHIN GROUP (ORDER BY revenue) AS revenue_25percentile,
       percentile_cont(0.5) WITHIN GROUP (ORDER BY revenue) AS revenue_50percentile,
       percentile_cont(0.75) WITHIN GROUP (ORDER BY revenue) AS revenue_75percentile
FROM cte;
```
#### Output: 
<img width="980" alt="image" src="https://github.com/aacha0/Portfolio/assets/148589444/a6488d0b-bad7-47cb-b6f6-d1a085b87405">

### Q: What is the average discount value per transaction?
```sql
with cte as(
select txn_id, sum(qty*price*discount/100) discount
from sales 
group by 1 )
select  round(avg(discount),2) avg_discount 
from cte
```
#### Output: 
<img width="110" alt="Screenshot 2024-03-08 at 10 25 48 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/5b2c48b3-ae3a-46ba-abce-b7f46a29434a">

#### Q: What is the percentage split of all transactions for members vs non-members?

```sql
select case when member = 1 then 'member' else 'non-member' end as member, 
round(count(distinct txn_id)/(select count(distinct txn_id) from sales)*100,2) pct
from sales
group by 1
```
#### Output: 

<img width="122" alt="Screenshot 2024-03-08 at 10 32 42 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/608cc625-4534-46d7-a185-75cec33036bd">

### Q: What is the average revenue for member transactions and non-member transactions?
```sql
with cte as(
select txn_id, member, sum(price*qty) rev
from sales 
group by 1,2 )
select case when member = 1 then 'member' else 'non-member' end as member, 
round(avg(rev),2) avg_revenue
from cte
group by 1
```
#### Output:

<img width="152" alt="Screenshot 2024-03-08 at 10 39 00 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/dcafae34-975a-4f8e-8b0f-8ce045d59bbd">


## 3. Product Analysis
### Q: What are the top 3 products by total revenue before discount?
```sql
with cte as(
select d.product_name, sum(p.price*p.qty) rev, dense_rank()over(order by sum(p.price*p.qty) desc) r
from sales p
join product_details d on p.prod_id = d.product_id
group by 1) 
select product_name, rev as revenue_b4_discount
from cte
where r <= 3
```
#### Output: 

<img width="295" alt="Screenshot 2024-03-08 at 11 57 48 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/5d31a102-799e-4fe8-b776-01d394305cae">

### Q: What is the total quantity, revenue and discount for each segment?
```sql
select d.segment_name, sum(s.qty) total_qty, sum(s.price*s.qty)revenue, round(sum(s.price*s.qty*s.discount/100),2) discount
from sales s
join product_details d on s.prod_id = d.product_id 
group by 1 

```
#### Output: 

<img width="247" alt="Screenshot 2024-03-09 at 12 02 54 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/bc037435-7484-47e0-bae5-b790232c29c8">

### Q: What is the top selling product for each segment?
```sql
with cte as(
select d.segment_name, d.product_name, sum(qty) total_qty, dense_rank()over(partition by d.segment_name order by sum(qty) desc) r
from sales s
join product_details d on s.prod_id = d.product_id 
group by 1,2
)

select segment_name, product_name, total_qty
 from cte
 where r = 1;
```
#### Output: 

<img width="317" alt="Screenshot 2024-03-09 at 12 09 16 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/a08536f7-0cd9-4b90-8c44-2cea56c1b34a">

### Q: What is the total quantity, revenue and discount for each category?

```sql
select d.category_name, sum(s.qty) total_qty, sum(s.price*s.qty)revenue, round(sum(s.price*s.qty*s.discount/100),2) discount
from sales s
join product_details d on s.prod_id = d.product_id 
group by 1 
;
```

#### Output: 

<img width="246" alt="Screenshot 2024-03-09 at 12 10 58 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/e6dba243-6cc8-4e76-913c-fef915c1f656">

### Q: What is the top selling product for each category?

```sql
with cte as(
select d.category_name, d.product_name, sum(qty) total_qty, dense_rank()over(partition by d.category_name order by sum(qty) desc) r
from sales s
join product_details d on s.prod_id = d.product_id 
group by 1,2
)

select category_name, product_name, total_qty
 from cte
 where r = 1;
```
#### Output: 

<img width="306" alt="Screenshot 2024-03-09 at 12 12 56 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/f5cef81d-351d-4fd0-bd8c-fbe87209a782">

### Q: What is the percentage split of revenue by product for each segment?
```sql
 with cte as (
select d.segment_name, d.product_name, sum(s.price*s.qty) rev
from sales s
join product_details d on s.prod_id = d.product_id 
group by 1,2)
select segment_name, product_name, round(rev/sum(rev)over(partition by segment_name)*100,2) rev_pct
from cte
order by 1,2
```
#### Output: 

<img width="308" alt="Screenshot 2024-03-09 at 12 38 42 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/6dbd2f1e-cd1b-40f2-ae01-d8b800ea618b">


### Q: What is the percentage split of revenue by segment for each category?

```sql
with cte as(
select d.category_name, d.segment_name, sum(s.price*s.qty) rev
from sales s
join product_details d on s.prod_id = d.product_id 
group by 1,2)

select category_name, segment_name, rev as revenue, round(rev/sum(rev)over(partition by category_name)*100,2) pct_segment_rev
from cte 


```
#### Output: 

<img width="321" alt="Screenshot 2024-03-09 at 12 29 27 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/6a820078-8320-41d5-b642-fbdf18a8c16f">


### Q: What is the percentage split of total revenue by category?
```sql
select d.category_name, round(sum(s.price*qty)/(select sum(price*qty) from sales)*100,2) rev_pct
from sales s
join product_details d on s.prod_id = d.product_id 
group by 1
order by 2 desc;
```
#### Output: 

<img width="140" alt="Screenshot 2024-03-09 at 12 20 46 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/8bb812f3-213d-4b8e-8faf-eea61bc90b30">

### Q: What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

```sql
select d.product_name, round(count(distinct txn_id)/(select count(distinct txn_id) from sales)*100,2)penetration_pct
from sales s
join product_details d on s.prod_id = d.product_id 
group by 1
order by 1
```

#### Output: 

<img width="305" alt="Screenshot 2024-03-09 at 12 35 20 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/2093afdb-ff0f-4e9a-8c54-4fe64ad7e6b5">

### Q: What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
```sql
-- filter transactions that only have three items
with cte as(
select txn_id, prod_id, product_name
from sales s
join product_details d  on s.prod_id = d.product_id
where txn_id in (select txn_id
from sales
group by 1
having count(distinct prod_id) = 3)),
-- concat the product list in each transaction
cte1 as(
select txn_id, group_concat(prod_id order by prod_id asc) prod_ids, group_concat(product_name order by product_name asc) product_names
 from cte
 group by 1),
-- count the appearance of each combination of the ordered products
 cte2 as(
select prod_ids, product_names , count(*) cnt
from cte1 
group by 1,2
order by cnt desc)
select prod_ids, product_names, cnt 
from cte2 
where cnt in (select max(cnt) from cte2)
```

#### Output: 

<img width="637" alt="Screenshot 2024-03-09 at 12 56 49 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/8aeaeaf2-68de-4ee1-a879-c126e002ab24">











