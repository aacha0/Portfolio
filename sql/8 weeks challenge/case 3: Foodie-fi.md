# 8 Weeks Challenge: Foodie-fi SQL Case Study 
## Introduction: 
#### Subscription based businesses are super popular and Danny realised that there was a large gap in the market - he wanted to create a new streaming service that only had food related content - something like Netflix but with only cooking shows!
#### Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!
#### Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.
#### Source: <https://8weeksqlchallenge.com/case-study-3/>
## Available Data: 
#### Plans 

<img width="317" alt="Screenshot 2024-03-11 at 11 37 26 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/78a4833b-b5cf-475d-be48-84ecfd7077d9">

#### Subscriptions 
<img width="355" alt="Screenshot 2024-03-11 at 11 38 07 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/abf761f0-753b-4605-931a-cb9dc5f75a1e">

## 1. Data Analysis 
### Q: How many customers has Foodie-Fi ever had?

```sql
 select count(distinct customer_id)
    from subscriptions;
```
#### Output: 
| count(distinct customer_id) |
| --------------------------- |
| 1000                        |

A: 1000 customers 

### Q: What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
```sql
    select extract(month from start_date) month, count(*) count
    from subscriptions 
    where plan_id = 0
    group by month 
    order by month ;
```

#### Output: 
| month | count |
| ----- | ----- |
| 1     | 88    |
| 2     | 68    |
| 3     | 94    |
| 4     | 81    |
| 5     | 88    |
| 6     | 79    |
| 7     | 89    |
| 8     | 88    |
| 9     | 87    |
| 10    | 79    |
| 11    | 75    |
| 12    | 84    |

### Q; What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
```sql
 select plan_name, count(*) count
    from subscriptions s 
    join plans p
    on s.plan_id = p.plan_id
    where extract(year from start_date) > 2020
    group by plan_name, s.plan_id 
    order by s.plan_id;
```

#### Output: 
| plan_name     | count |
| ------------- | ----- |
| basic monthly | 8     |
| pro monthly   | 60    |
| pro annual    | 63    |
| churn         | 71    |

### Q: What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
```sql

    select count(distinct customer_id) num_customers,
    sum(case when plan_id = 4 then 1 else 0 end) cnt_churned_cutsomers,
    round(sum(case when plan_id = 4 then 1 else 0 end)/count(distinct customer_id)*100,1)churn_percentage 
    from subscriptions;
```
#### Output: 
| num_customers | cnt_churned_cutsomers | churn_percentage |
| ------------- | --------------------- | ---------------- |
| 1000          | 307                   | 30.7             |



### Q: How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
```sql
    with cte as(
      select customer_id, plan_id, lead(plan_id, 1) over(partition by customer_id order by start_date) next_plan   
    from subscriptions) 
    
    select count(distinct customer_id) total_customer,  
    sum(case when plan_id = 0 and next_plan = 4 then 1 else 0 end) num_churned_after_trial,  round(sum(case when plan_id = 0 and next_plan = 4 then 1 else 0 end) / count(distinct customer_id)*100) percentage
    from cte ;
```
#### Output: 
| total_customer | num_churned_after_trial | percentage |
| -------------- | ----------------------- | ---------- |
| 1000           | 92                      | 9          |


### Q: What is the number and percentage of customer plans after their initial free trial?
```sql
    with cte as (
    select customer_id, plan_id, lead(plan_id, 1) over(partition by customer_id order by start_date) next_plan
    from subscriptions 
    where customer_id in (select customer_id from subscriptions where plan_id = 0))
    select plan_name, count(*) count , round(count(*)/(select count(distinct customer_id) from cte)*100,2) pct
    from cte c
    join plans p
    on c.next_plan = p.plan_id
    where c.plan_id =0
    group by plan_name;

```

| plan_name     | count |   pct  |  
| ------------- | ----- | -------| 
| basic monthly | 546   |  54.60 |
| pro monthly   | 325   |  9.20  |
| pro annual    | 37    |  3.70  |
| churn         | 92    |  32.50 |


### Q: What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
  select distinct customer_id, max(s.plan_id) over(partition by customer_id order by start_date desc)  last_plan_status 
    from subscriptions s
    where start_date <= '2020-12-31')
 ```sql   
    select plan_name, count(*) count, round(count(*)/(select count(customer_id) from cte)*100,2) percentage
    from cte c
    join plans p
    on c.last_plan_status = p.plan_id 
    group by plan_name 
    ;
```
#### Output: 

| plan_name     | count | percentage |
| ------------- | ----- | ---------- |
| trial         | 19    | 1.90       |
| basic monthly | 224   | 22.40      |
| pro monthly   | 326   | 32.60      |
| pro annual    | 195   | 19.50      |
| churn         | 236   | 23.60      |

### Q: How many customers have upgraded to an annual plan in 2020?
```sql
  select count(*) cnt_upgrade_annual
    from subscriptions 
    where plan_id = 3 and start_date between '2020-01-01' and '2020-12-31' ;
```
#### Output: 
| cnt_upgrade_annual |
| ------------------ |
| 195                |

### Q: How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
```sql
with cte as(
    select distinct customer_id, 
    max(start_date) over(partition by customer_id) max,
    min(start_date) over(partition by customer_id) min,
    datediff(max(start_date) over(partition by customer_id),min(start_date) over(partition by customer_id)) diff 
    from subscriptions 
    where customer_id in (select customer_id from subscriptions where plan_id =3) and plan_id < 4 ) 

    select round(avg(diff),2) avg_days 
    from cte ;
```
#### Output: 

| avg_days |
| -------- |
| 104.62   |

### Q: Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
```sql
 with cte as(
      select distinct customer_id, 
      min(start_date) over(partition by customer_id) min,
      datediff(max(start_date) over(partition by customer_id),min(start_date) over(partition by customer_id)) diff 
      from subscriptions 
      where customer_id in (select customer_id from subscriptions where plan_id =3) and plan_id < 4 
    ),
    bound as(
    select *, floor(diff/30)*30 lower, 
    case when diff%30 = 0 then ceiling(diff/30)*30+30
    else ceiling(diff/30)*30 end upper
    from cte),
    period as (
      select *, concat(lower, ' - ',upper)period from bound
      ) 


    select period, count(*) cnt_upgrade_annual_plan
    from period 
    group by period,lower 
    order by lower;
```

| period    | cnt_upgrade_annual_plan |
| --------- | ----------------------- |
| 0 - 30    | 48                      |
| 30 - 60   | 25                      |
| 60 - 90   | 33                      |
| 90 - 120  | 35                      |
| 120 - 150 | 43                      |
| 150 - 180 | 35                      |
| 180 - 210 | 27                      |
| 210 - 240 | 4                       |
| 240 - 270 | 5                       |
| 270 - 300 | 1                       |
| 300 - 330 | 1                       |
| 330 - 360 | 1                       |

### Q: How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
```sql 
with cte as(
    select customer_id, start_date, plan_id,lead(plan_id, 1) over(partition by customer_id order by start_date) next_plan,
    datediff(lead(start_date, 1) over(partition by customer_id), start_date) date_diff
    from subscriptions 
    where start_date between '2020-01-01' and '2020-12-31')



    select 
    sum(case when plan_id=2 and next_plan=1 then 1 else 0 end) switch_plan, 
    sum(case when plan_id =0 and next_plan =1 and date_diff>7 then 1 else 0 end) did_not_switch_out_plan_after_trial, 
    sum(case when plan_id =0 and next_plan =1 and date_diff=7 then 1 else 0 end) switch_from_trial_to_basix
    from cte
    ;
```
#### Output: 

| switch_plan | did_not_switch_out_plan_after_trial | switch_from_trial_to_basix |
| ----------- | ----------------------------------- | -------------------------- |
| 0           | 0                                   | 538                        |

## 2. Challenge Payment Questions 
### The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:
### - monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
### - upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
### - upgrades from pro monthly to pro annual are paid at the end of the current - billing period and also starts at the end of the month period
### - once a customer churns they will no longer make payments

```sql
  create table payment_details as
    with RECURSIVE cte as(
      select customer_id, s.plan_id, plan_name, cast(start_date as date) start_date
      ,
      lead(start_date, 1) over(partition by customer_id) end_date, 		price
      from subscriptions s
      join plans p
      on s.plan_id =p.plan_id
      where year(start_date) = '2020' and plan_name != 'trial'),
      cte1 as (
        select customer_id, plan_id, plan_name, start_date, 
        case when plan_id = 4 then null 
        else coalesce(end_date, '2020-12-31') end end_date, price 
        from cte),
      cte2 as(
        select customer_id, plan_id, plan_name, start_date, end_date, price 
        from cte1
        
        union all
        select customer_id, plan_id, plan_name, date_add(start_date, interval 1 month) start_date, end_date, price 
        from cte2
        where end_date >= date_add(start_date, interval 1 month)
        and plan_name != 'pro annual'
        ),
        cte3 as(
          select *, lag(plan_id,1)over(partition by customer_id order by start_date)prev_plan,  lag(price,1)over(partition by customer_id order by start_date) prev_payment, (dense_rank() over(partition by customer_id order by start_date) ) ranking
          from cte2),
         cte4 as(
           select customer_id, plan_id, plan_name, start_date, end_date, 
           case when prev_plan != plan_id and plan_id != 4 then price - prev_payment else price end as price
           from cte3)
     select * from cte4;

    select * from payment_details;
```
#### More efficient code 
```sql
with year as (
select customer_id, s.plan_id, plan_name, start_date,price
from subscriptions s
join plans p
on s.plan_id = p.plan_id
where year(start_date) = '2020' and s.plan_id !=0  
order by customer_id, s.plan_id ),
  end_date as(
  select customer_id, plan_id, plan_name, start_date,
  case when plan_id != 4 and lead(start_date,1)over(partition by customer_id) is null then '2020-12-31' 
  else lead(start_date,1)over(partition by customer_id) end as end_date,price
from year) 

select * 
from end_date
jOIN (
        SELECT 0 as n UNION ALL
        SELECT 1 as n UNION ALL
        SELECT 2 as n UNION ALL
        SELECT 3 as n UNION ALL
        SELECT 4 as n UNION ALL
        SELECT 5 as n UNION ALL
        SELECT 6 as n UNION ALL
        SELECT 7 as n UNION ALL
        SELECT 8 as n UNION ALL
        SELECT 9 as n UNION ALL
        SELECT 10 as n UNION ALL
        SELECT 11 as n UNION ALL
        SELECT 12 as n
      ) as n
      ON n.n <= 12
```
---

#### Output: 

| customer_id | plan_id | plan_name     | start_date | end_date   | price   |
| ----------- | ------- | ------------- | ---------- | ---------- | ------- |
| 1           | 1       | basic monthly | 2020-08-08 | 2020-12-31 | 9.90    |
| 1           | 1       | basic monthly | 2020-09-08 | 2020-12-31 | 9.90    |
| 1           | 1       | basic monthly | 2020-10-08 | 2020-12-31 | 9.90    |
| 1           | 1       | basic monthly | 2020-11-08 | 2020-12-31 | 9.90    |
| 1           | 1       | basic monthly | 2020-12-08 | 2020-12-31 | 9.90    |
| 2           | 3       | pro annual    | 2020-09-27 | 2020-12-31 | 199.00  |
| 3           | 1       | basic monthly | 2020-01-20 | 2020-12-31 | 9.90    |
| 3           | 1       | basic monthly | 2020-02-20 | 2020-12-31 | 9.90    |
| 3           | 1       | basic monthly | 2020-03-20 | 2020-12-31 | 9.90    |
| 3           | 1       | basic monthly | 2020-04-20 | 2020-12-31 | 9.90    |
| 3           | 1       | basic monthly | 2020-05-20 | 2020-12-31 | 9.90    |
| 3           | 1       | basic monthly | 2020-06-20 | 2020-12-31 | 9.90    |
| 3           | 1       | basic monthly | 2020-07-20 | 2020-12-31 | 9.90    |
| 3           | 1       | basic monthly | 2020-08-20 | 2020-12-31 | 9.90    |
| 3           | 1       | basic monthly | 2020-09-20 | 2020-12-31 | 9.90    |
```



