# 8 Weeks Challenge: Data Bank SQL Case Study 
## Introduction: 
#### Neo-Banks: new aged digital only banks without physical branches.
#### Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. There are a few interesting caveats that go with this business model, and this is where the Data Bank team need your help!
#### Source : <https://8weeksqlchallenge.com/case-study-4/>

## Available Data: 
#### Regions

<img width="249" alt="Screenshot 2024-03-12 at 9 40 15 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/42a4ddea-081b-4917-9d83-4b6ea97139e1">

#### Customer Nodes
##### Top 10 Rows of Customer Nodes: 

<img width="603" alt="Screenshot 2024-03-12 at 9 41 07 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/5ebb1e41-9f55-4286-80da-ba118528992f">

#### Customer Transactions

<img width="506" alt="Screenshot 2024-03-12 at 9 42 34 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/0fa352fa-5e39-4135-933b-b637d565ae96">

## 1. Customer Nodes Exploration 
### Q: How many unique nodes are there on the Data Bank system?
```
select count(distinct node_id) 
    from customer_nodes ;
```
#### Output:  

| count(distinct node_id) |
| ----------------------- |
| 5                       |


### Q: What is the number of nodes per region?
```sql
select region_name, count(distinct node_id)
    from customer_nodes 
    join regions 
    using(region_id)
    group by region_name
    order by region_name ;
```
#### Output: 

| region_name | count(distinct node_id) |
| ----------- | ----------------------- |
| Africa      | 5                       |
| America     | 5                       |
| Asia        | 5                       |
| Australia   | 5                       |
| Europe      | 5                       |

### Q: How many customers are allocated to each region?

```sql
 select region_name, count(distinct customer_id) num_customer
    from customer_nodes
    join regions 
    using(region_id)
    group by region_name
    order by region_name;
```
#### Output:

| region_name | num_customer |
| ----------- | ------------ |
| Africa      | 102          |
| America     | 105          |
| Asia        | 95           |
| Australia   | 110          |
| Europe      | 88           |

### Q: How many days on average are customers reallocated to a different node?

```sql
 with cte as (
    select customer_id, region_id, node_id, 
    lead(node_id,1)over(partition by customer_id order by start_date) next, start_date, end_date
    from customer_nodes
      where end_date <> '9999-12-31'
      order by customer_id ),
    cte1 as (
      select *,
      case when node_id = next then null else end_date end ed,
       rank()over(partition by customer_id order by start_date) ranking
      from cte),
      cte2 as (
        select *,
        case when lag(ed,1)over(partition by customer_id order by start_date) is null and ranking != 1 then lag(start_date,1)over(partition by customer_id order by start_date)
        when ed is null then null 
    else start_date end actual_start_date                                            
      from cte1)
    select 
    *from cte2
    limit 15;
```

#### Output: 

| customer_id | region_id | node_id | next | start_date | end_date   | ed         | ranking | actual_start_date |
| ----------- | --------- | ------- | ---- | ---------- | ---------- | ---------- | ------- | ----------------- |
| 1           | 3         | 4       | 4    | 2020-01-02 | 2020-01-03 |            | 1       |                   |
| 1           | 3         | 4       | 2    | 2020-01-04 | 2020-01-14 | 2020-01-14 | 2       | 2020-01-02        |
| 1           | 3         | 2       | 5    | 2020-01-15 | 2020-01-16 | 2020-01-16 | 3       | 2020-01-15        |
| 1           | 3         | 5       | 3    | 2020-01-17 | 2020-01-28 | 2020-01-28 | 4       | 2020-01-17        |
| 1           | 3         | 3       | 2    | 2020-01-29 | 2020-02-18 | 2020-02-18 | 5       | 2020-01-29        |
| 1           | 3         | 2       |      | 2020-02-19 | 2020-03-16 | 2020-03-16 | 6       | 2020-02-19        |
| 2           | 3         | 5       | 3    | 2020-01-03 | 2020-01-17 | 2020-01-17 | 1       | 2020-01-03        |
| 2           | 3         | 3       | 3    | 2020-01-18 | 2020-02-09 |            | 2       |                   |
| 2           | 3         | 3       | 5    | 2020-02-10 | 2020-02-21 | 2020-02-21 | 3       | 2020-01-18        |
| 2           | 3         | 5       | 2    | 2020-02-22 | 2020-03-07 | 2020-03-07 | 4       | 2020-02-22        |
| 2           | 3         | 2       | 4    | 2020-03-08 | 2020-03-12 | 2020-03-12 | 5       | 2020-03-08        |
| 2           | 3         | 4       |      | 2020-03-13 | 2020-03-13 | 2020-03-13 | 6       | 2020-03-13        |
| 3           | 5         | 4       | 5    | 2020-01-27 | 2020-02-18 | 2020-02-18 | 1       | 2020-01-27        |
| 3           | 5         | 5       | 3    | 2020-02-19 | 2020-03-06 | 2020-03-06 | 2       | 2020-02-19        |
| 3           | 5         | 3       | 4    | 2020-03-07 | 2020-03-24 | 2020-03-24 | 3       | 2020-03-07        |

### Q: What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
```sql
with cte as (
    select customer_id, region_id, node_id, 
    lead(node_id,1)over(partition by customer_id order by start_date) next, start_date, end_date
    from customer_nodes
      where end_date <> '9999-12-31'
      order by customer_id ),
    cte1 as (
      select *,
      case when node_id = next then null else end_date end ed,
       rank()over(partition by customer_id order by start_date) ranking
      from cte),
      cte2 as (
        select *,
        case when lag(ed,1)over(partition by customer_id order by start_date) is null and ranking != 1 then lag(start_date,1)over(partition by customer_id order by start_date)
        when ed is null then null 
    else start_date end actual_start_date                                            
      from cte1)
    select round(avg(datediff(ed,actual_start_date)),2) avg_days_relocate from cte2;
```
#### Output:
| avg_days_relocate |
| ----------------- |
| 17.33             |




