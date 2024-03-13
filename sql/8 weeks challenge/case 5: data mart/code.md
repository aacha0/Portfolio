# 8 Weeks Challenge: Data Mart SQL Case Study 
## Inroduction:
#### Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce 
#### In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer. Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas
#### Source: <https://8weeksqlchallenge.com/case-study-5/>

## Available Data 
#### Weekly Sales

<img width="1285" alt="Screenshot 2024-03-12 at 10 30 56 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/d737ebfd-80fa-4788-bab0-ff94f40df61b">

## 1. Data Cleansing Steps 
### In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
### Convert the week_date to a DATE format
### Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
### Add a month_number with the calendar month for each week_date value as the 3rd column
### Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
### Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value

<img width="236" alt="Screenshot 2024-03-12 at 10 33 04 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/d87c7735-8d35-4ae1-b11b-4dc20c2e3c57">

### Add a new demographic column using the following mapping for the first letter in the segment values:

<img width="236" alt="Screenshot 2024-03-12 at 10 33 32 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/1313c193-9dce-49ba-b580-58031a9d0496">

### Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
### Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record

```sql
DROP TABLE IF EXISTS data_mart.clean_weekly_sales;
Create table data_mart.clean_weekly_sales(
Select 
  date(str_to_date(week_date,'%d/%m/%y')) week_date, week(str_to_date(week_date,'%d/%m/%y')) week_number, 
  month(week_date) month_number, year(str_to_date(week_date,'%d/%m/%y')) calendar_year,
  region, 
  platform, 
  coalesce(segment, 'unknown') segment, 
  case when segment like '%1' then 'Young Adults' 
  when segment like '%2' then 'Middle Aged' 
  when segment like '%3' or segment like '%4' then 'Retirees' 
  else 'unknown' end age_band,
  case when segment like 'F%' then 'Families'
  when segment like 'C%' then 'Couples'
  else 'unknown' end demographic,
  customer_type, transactions, sales,
  round(sales/transactions,2) as avg_transaction
from data_mart.weekly_sales
order by week_date
) ;
```
## 2. Data Exploration
### Q: What day of the week is used for each week_date value?

```sql
select distinct dayname(week_date) day_of_week
    from clean_weekly_sales;
```
#### Output: 

| day_of_week |
| ----------- |
| Monday      |

### Q: What range of week numbers are missing from the dataset?

```sql
WITH recursive cte AS (
      SELECT 1 AS num
      UNION ALL
      SELECT num+1 FROM cte
      WHERE num+1 <= 52)
    select group_concat(num) missing_week_of_yr 
    from cte 
    where num not in(select distinct week_number from clean_weekly_sales) ;
```

#### Output: 

| missing_week_of_yr                                                         |
| -------------------------------------------------------------------------- |
| 1,2,3,4,5,6,7,8,9,10,11,12,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52 |


### Q: How many total transactions were there for each year in the dataset?

```sql
select calendar_year, sum(transactions) total_transactions_yr
    from clean_weekly_sales 
    group by calendar_year;
```
#### Output: 

| calendar_year | total_transactions_yr |
| ------------- | --------------------- |
| 2018          | 346406460             |
| 2019          | 365639285             |
| 2020          | 375813651             |

### Q: What is the total sales for each region for each month?

```sql
 select region, month_number, sum(sales) total_sales
    from clean_weekly_sales
    group by region, month_number
    order by region, month_number;
```

#### Output: 
| region        | month_number | total_sales |
| ------------- | ------------ | ----------- |
| AFRICA        | 3            | 567767480   |
| AFRICA        | 4            | 1911783504  |
| AFRICA        | 5            | 1647244738  |
| AFRICA        | 6            | 1767559760  |
| AFRICA        | 7            | 1960219710  |
| AFRICA        | 8            | 1809596890  |
| AFRICA        | 9            | 276320987   |
| ASIA          | 3            | 529770793   |
| ASIA          | 4            | 1804628707  |
| ASIA          | 5            | 1526285399  |
| ASIA          | 6            | 1619482889  |
| ASIA          | 7            | 1768844756  |
| ASIA          | 8            | 1663320609  |
| ASIA          | 9            | 252836807   |
| CANADA        | 3            | 144634329   |
| CANADA        | 4            | 484552594   |
| CANADA        | 5            | 412378365   |
| CANADA        | 6            | 443846698   |
| CANADA        | 7            | 477134947   |
| CANADA        | 8            | 447073019   |
| CANADA        | 9            | 69067959    |
| EUROPE        | 3            | 35337093    |
| EUROPE        | 4            | 127334255   |
| EUROPE        | 5            | 109338389   |
| EUROPE        | 6            | 122813826   |
| EUROPE        | 7            | 136757466   |
| EUROPE        | 8            | 122102995   |
| EUROPE        | 9            | 18877433    |
| OCEANIA       | 3            | 783282888   |
| OCEANIA       | 4            | 2599767620  |
| OCEANIA       | 5            | 2215657304  |
| OCEANIA       | 6            | 2371884744  |
| OCEANIA       | 7            | 2563459400  |
| OCEANIA       | 8            | 2432313652  |
| OCEANIA       | 9            | 372465518   |
| SOUTH AMERICA | 3            | 71023109    |
| SOUTH AMERICA | 4            | 238451531   |
| SOUTH AMERICA | 5            | 201391809   |
| SOUTH AMERICA | 6            | 218247455   |
| SOUTH AMERICA | 7            | 235582776   |
| SOUTH AMERICA | 8            | 221166052   |
| SOUTH AMERICA | 9            | 34175583    |
| USA           | 3            | 225353043   |
| USA           | 4            | 759786323   |
| USA           | 5            | 655967121   |
| USA           | 6            | 703878990   |
| USA           | 7            | 760331754   |
| USA           | 8            | 712002790   |
| USA           | 9            | 110532368   |

### Q: What is the total count of transactions for each platform
```sql
select platform, sum(transactions)total_transactions
    from clean_weekly_sales 
    group by platform ;
```

#### Output: 

| platform | total_transactions |
| -------- | ------------------ |
| Retail   | 1081934227         |
| Shopify  | 5925169            |

### Q: What is the percentage of sales for Retail vs Shopify for each month?
```sql
 with cte as (
      select calendar_year, month_number month, platform, sum(sales) sales
      from clean_weekly_sales
      group by calendar_year, month, platform)
    
    select calendar_year, month,
    round(100*max(case when platform = 'Retail' then sales else null end)/sum(sales),2) retail_percentage,
    round(100*max(case when platform = 'Shopify' then sales else null end)/sum(sales),2) shopify_percentage
    from cte 
    group by calendar_year, month
    order by calendar_year, month ;
```

#### Output:

| calendar_year | month | retail_percentage | shopify_percentage |
| ------------- | ----- | ----------------- | ------------------ |
| 2018          | 3     | 97.92             | 2.08               |
| 2018          | 4     | 97.93             | 2.07               |
| 2018          | 5     | 97.73             | 2.27               |
| 2018          | 6     | 97.76             | 2.24               |
| 2018          | 7     | 97.75             | 2.25               |
| 2018          | 8     | 97.71             | 2.29               |
| 2018          | 9     | 97.68             | 2.32               |
| 2019          | 3     | 97.71             | 2.29               |
| 2019          | 4     | 97.80             | 2.20               |
| 2019          | 5     | 97.52             | 2.48               |
| 2019          | 6     | 97.42             | 2.58               |
| 2019          | 7     | 97.35             | 2.65               |
| 2019          | 8     | 97.21             | 2.79               |
| 2019          | 9     | 97.09             | 2.91               |
| 2020          | 3     | 97.30             | 2.70               |
| 2020          | 4     | 96.96             | 3.04               |
| 2020          | 5     | 96.71             | 3.29               |
| 2020          | 6     | 96.80             | 3.20               |
| 2020          | 7     | 96.67             | 3.33               |
| 2020          | 8     | 96.51             | 3.49               |

### Q: What is the percentage of sales by demographic for each year in the dataset?
```sql
 with cte as (
      select calendar_year, demographic, sum(sales) sales 
      from clean_weekly_sales
      group by calendar_year, demographic)
    
    select calendar_year, 
    round(100*max(case when demographic = 'Families' then sales else null end) /sum(sales),2) percentage_families,
    round(100*max(case when demographic = 'Couples' then sales else null end) /sum(sales),2) percentage_couples,
    round(100*max(case when demographic = 'unknown' then sales else null end) /sum(sales),2) percentage_unknown
    from cte 
    group by calendar_year;
```
#### Output: 

| calendar_year | percentage_families | percentage_couples | percentage_unknown |
| ------------- | ------------------- | ------------------ | ------------------ |
| 2018          | 31.99               | 26.38              | 41.63              |
| 2019          | 32.47               | 27.28              | 40.25              |
| 2020          | 32.73               | 28.72              | 38.55              |


### Q: Which age_band and demographic values contribute the most to Retail sales?
```sql
 select age_band, demographic, round(100*sum(sales)/(select sum(sales) from clean_weekly_sales where platform = 'Retail'),2) percentage 
    from clean_weekly_sales 
    where platform = 'Retail'
    group by age_band, demographic
    order by percentage desc;
```

#### Output:
| age_band     | demographic | percentage |
| ------------ | ----------- | ---------- |
| unknown      | unknown     | 40.52      |
| Retirees     | Families    | 16.73      |
| Retirees     | Couples     | 16.07      |
| Middle Aged  | Families    | 10.98      |
| Young Adults | Couples     | 6.56       |
| Middle Aged  | Couples     | 4.68       |
| Young Adults | Families    | 4.47       |


### Q: Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

```sql
select calendar_year, platform,
    round(avg(avg_transaction)) avg_avg_of_trans,
    round(sum(sales) / sum(transactions)) avg_sum_sales_trans
    from clean_weekly_sales 
    group by calendar_year, platform;
```
#### Output: 

| calendar_year | platform | avg_avg_of_trans | avg_sum_sales_trans |
| ------------- | -------- | ---------------- | ------------------- |
| 2018          | Retail   | 43               | 37                  |
| 2018          | Shopify  | 188              | 192                 |
| 2019          | Retail   | 42               | 37                  |
| 2019          | Shopify  | 178              | 183                 |
| 2020          | Shopify  | 175              | 179                 |
| 2020          | Retail   | 41               | 37                  |

## 3. Before & After Analysis 
### This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
### Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
### We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before
### Using this analysis approach - answer the following questions:
### Q: What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
### What about the entire 12 weeks before and after?
### How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

```sql
 DROP TABLE IF EXISTS before_after;
 Create table before_after(
    select *, 
    case when week_date < '2020-06-15' then 'before' else 'after' end as new_packaging 
    from clean_weekly_sales);
with cte as( 
      select week_date, sum(transactions) transactions, sum(sales) sales, dense_rank()over(order by week_date desc) ranking, 'before' as new_packaging
      from before_after
      where new_packaging = 'before'
      group by week_date
      union 
       select week_date, sum(transactions) transactions, sum(sales) sales, dense_rank()over(order by week_date) ranking,'after' as new_packaging
      from before_after
      where new_packaging = 'after'
      group by week_date),
      cte1 as (
        select sum(sales) sales, new_packaging 
      from cte 
      where ranking between 1 and 4
      group by new_packaging)
      
    select 
    max(case when new_packaging = 'after' then sales else null end) - max(case when new_packaging = 'before' then sales else null end) as difference, 
    round(100*((max(case when new_packaging = 'after' then sales else null end) - max(case when new_packaging = 'before' then sales else null end))/max(case when new_packaging = 'before' then sales else null end)),2) percentage_diff
    from cte1 ;
```
#### Output: 

| difference | percentage_diff |
| ---------- | --------------- |
| -26884188  | -1.15           |

### Q: What about the entire 12 weeks before and after?

```sql
 with cte as( 
      select week_date, sum(transactions) transactions, sum(sales) sales, dense_rank()over(order by week_date desc) ranking, 'before' as new_packaging
      from before_after
      where new_packaging = 'before'
      group by week_date
      union 
       select week_date, sum(transactions) transactions, sum(sales) sales, dense_rank()over(order by week_date) ranking,'after' as new_packaging
      from before_after
      where new_packaging = 'after'
      group by week_date),
      cte1 as (
        select sum(sales) sales, new_packaging 
      from cte 
      where ranking between 1 and 12
      group by new_packaging)
      
    select 
    max(case when new_packaging = 'after' then sales else null end) - max(case when new_packaging = 'before' then sales else null end) as difference, 
    round(100*((max(case when new_packaging = 'after' then sales else null end) - max(case when new_packaging = 'before' then sales else null end))/max(case when new_packaging = 'before' then sales else null end)),2) percentage_diff
    from cte1 ;
```
#### Output: 

| difference | percentage_diff |
| ---------- | --------------- |
| -152325394 | -2.14           |

### Q: How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

```sql
with cte as (
      select *
      from clean_weekly_sales 
      where week_number between 21 and 28),
      cte1 as(
        select calendar_year,
        case when week_number between 21 and 24 then 'before'
        else 'after' end as periods, sum(sales) sales
        from cte
      group by calendar_year, periods
      order by calendar_year),
      cte2 as (
        select calendar_year, 
        max(case when periods = 'after' then sales else null end) - max(case when periods = 'before' then sales else null end)as difference, 
    round(100*((max(case when periods = 'after' then sales else null end) - max(case when periods = 'before' then sales else null end))/max(case when periods = 'before' then sales else null end)),2) percentage_diff
        from cte1 
        group by calendar_year
        order by calendar_year) 
        select * from cte2;
```

#### Output:

| calendar_year | difference | percentage_diff |
| ------------- | ---------- | --------------- |
| 2018          | 4102105    | 0.19            |
| 2019          | 2336594    | 0.10            |
| 2020          | -26884188  | -1.15           |

## 4. Bonus 
### Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
### - region
### - platform
### - age_band
### - demographic
### - customer_type

```sql
 select  distinct a.region, (b.region_sum  - a.region_sum) difference, round((b.region_sum  - a.region_sum)/a.region_sum *100,2) percentage_diff
     from comparison a 
     join comparison b 
     on a.region = b.region
     where a.new_packaging = 'before' and b.new_packaging = 'after'
     order by difference ;
```

| region        | difference  | percentage_diff |
| ------------- | ----------- | --------------- |
| OCEANIA       | -2074653413 | -47.61          |
| AFRICA        | -1596735571 | -48.43          |
| ASIA          | -1384312029 | -46.64          |
| USA           | -627900072  | -48.52          |
| CANADA        | -397496324  | -48.73          |
| SOUTH AMERICA | -192077326  | -47.96          |
| EUROPE        | -116342125  | -50.50          |
