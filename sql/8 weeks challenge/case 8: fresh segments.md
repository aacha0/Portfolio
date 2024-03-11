# 8 Weeks Challenge: Fresh Segment SQL Case Study
## Introduction: 
####  Fresh Segments is a digital marketing agency that helps other businesses analyse trends in online ad click behaviour for their unique customer base.
#### Clients share their customer lists with the Fresh Segments team who then aggregate interest metrics and generate a single dataset worth of metrics for further analysis. In particular - the composition and rankings for different interests are provided for each client showing the proportion of their customer list who interacted with online assets related to each interest for each month.
#### Source: <https://8weeksqlchallenge.com/case-study-8/>
## Available Data: 
### Interest Metrics
##### This table contains information about aggregated interest metrics for a specific major client of Fresh Segments which makes up a large proportion of their customer base. Each record in this table represents the performance of a specific interest_id based on the client’s customer base interest measured through clicks and interactions with specific targeted advertising content.

<img width="497" alt="Screenshot 2024-03-09 at 10 56 40 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/d1002343-489e-43ec-945f-84cf662e4ed9">

##### In July 2018, the composition metric is 11.89, meaning that 11.89% of the client’s customer list interacted with the interest interest_id = 32486 - we can link interest_id to a separate mapping table to find the segment name called “Vacation Rental Accommodation Researchers” The index_value is 6.19, means that the composition value is 6.19x the average composition value for all Fresh Segments clients’ customer for this particular interest in the month of July 2018. The ranking and percentage_ranking relates to the order of index_value records in each month year.
### Interest Map:

<img width="665" alt="Screenshot 2024-03-09 at 10 57 07 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/bb83dd9d-7307-4881-b258-9fcc887bb8f9">

## 1. Data Exploration and Cleansing
### Q: Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month

```sql
alter table interest_metrics
drop column month_year ;

alter table interest_metrics 
add month_year date;

update interest_metrics
set month_year = cast(concat(year,'-',month,'-01') as date);
select * from interest_metrics
```

### Q: What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?

```sql
select month_year, count(*) cnt
from interest_metrics
group by 1
order by 1
```
#### Output: 
<img width="117" alt="Screenshot 2024-03-09 at 11 38 17 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/51c49521-a762-4ad8-b001-85fef2056d02">

### Q: What do you think we should do with these null values in the fresh_segments.interest_metrics

```sql
delete from interest_metrics
where month_year is null;
```
#### A: Since we want specific monthly data, we can delete the data that do not have a month_year record. 

### Q: How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? ### What about the other way around?

```sql

select 'interest_metrics' table_name, count(*) cnt
from interest_metrics 
where interest_id not in (select id from interest_map) 
union 
select 'interest_map' table_name, count(*) cnt
from interest_map 
where id not in (select interest_id from interest_metrics)
-- first row shows the interest_id values exist in interest_metrics table but not interest_map table
-- second row shows the interest_id values exist in interest_map table but not interest_metrics table
```
#### Output: 
<img width="138" alt="Screenshot 2024-03-09 at 11 45 32 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/8ae74d7d-a576-4490-9d83-f7b7025e83f4">

### Q: Summarise the id values in the fresh_segments.interest_map by its total record count in this table

```sql
select id, interest_name ,count(mt.interest_id) cnt
from interest_map m
join interest_metrics mt on m.id = mt.interest_id
group by 1,2
order by 3 desc
```
#### Output: 
<img width="229" alt="Screenshot 2024-03-10 at 12 25 33 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/28fc89e8-0cc7-48a0-ae19-cfb4592b0185">

### Q: What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

```sql
select *
from interest_map m
join interest_metrics mt on m.id = mt.interest_id
where mt.interest_id = 21246

```
#### Output: 
<img width="971" alt="Screenshot 2024-03-10 at 12 36 34 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/fc223293-7e8e-4a13-bc69-b1505bbf6ee9">

#### A: We should use `INNER JOIN` to join tables to perform analysis

### Q: Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?

```sql
select count(*)
from interest_map m
join interest_metrics mt on m.id = mt.interest_id
where mt.month_year < m.created_at
```
#### Output:

<img width="54" alt="Screenshot 2024-03-10 at 12 41 38 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/11ae2a85-2836-47eb-b0ed-eaf0de472c8c">

#### A: Out of all records, there are 188 records where the `month_year` value precedes the `created_at` value. However, previously, we manually adjusted `month_year` to reflect the beginning of the month. Let's verify if these records align with the `created_at` month and year

```sql
select count(*)
from interest_map m
join interest_metrics mt on m.id = mt.interest_id
where date_format(created_at, '%Y-%m') >  month_year
```
#### Output:
<img width="54" alt="Screenshot 2024-03-10 at 12 45 32 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/55c63d50-cd1a-4cab-af26-d13ab5f822bd">

#### A: Since it returned `0` records that have `month_year` earlier than the `created_at`, these records should be considered valid data


## 2. Interest Analysis
### Q: Which interests have been present in all month_year dates in our dataset?
```sql

with cte as (
select mt.interest_id,  m.interest_name, count(distinct month_year) cnt
from interest_metrics mt
join interest_map m on m.id = mt.interest_id 
group by 1,2 )

select interest_id, interest_name 
from cte 
where cnt = (select count(distinct month_year) from interest_metrics);
```
#### Output: 

<img width="297" alt="Screenshot 2024-03-10 at 3 29 25 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/ce604987-6c53-442f-9303-9ae6ccac55d6">

```sql
with cte as (
select mt.interest_id,  m.interest_name, count(distinct month_year) cnt
from interest_metrics mt
join interest_map m on m.id = mt.interest_id 
group by 1,2 )

select count(distinct interest_id) 
from cte 
where cnt = (select count(distinct month_year) from interest_metrics)
```
#### Output:

<img width="142" alt="Screenshot 2024-03-10 at 3 30 50 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/e1980798-701e-4f97-bea3-21a8bca6ebbf">

#### `480` interests have been present in all month_year 

### Q: Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?

```sql
with cte as(
select interest_id, count(distinct month_year) cnt
from interest_metrics
group by 1), 
cte1 as(
select cnt as total_month, count(distinct interest_id) cnt 
from cte 
group by 1), 
cte2 as (
select total_month, round(sum(cnt)over(order by total_month desc)/sum(cnt)over()*100,2) pct
from cte1)

select * 
from cte2 
where pct>=90
```
#### Output:
<img width="137" alt="Screenshot 2024-03-10 at 7 23 36 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/ed91289e-5cb3-4a12-872b-16d2b393533c">

### Q: If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?

```sql
with cte as(
select interest_id, count(distinct month_year) total_months 
from interest_metrics 
group by 1
having total_months < 6
)
select sum(total_months) 
from cte 

```
#### Output: 

<img width="129" alt="Screenshot 2024-03-10 at 7 43 59 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/7add2ace-9db0-4fd0-88bb-2ead8a978d40">

### Q: Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.
-- to be updated
### Q: After removing these interests - how many unique interests are there for each month?

```sql
with cte as (
select  interest_id, count(distinct month_year) total_months 
from interest_metrics 
group by 1
having total_months < 6)

select month_year, count(distinct interest_id) cnt
from interest_metrics
where interest_id not in (select interest_id from cte)
group by 1
```
#### Output: 

<img width="146" alt="Screenshot 2024-03-10 at 7 49 49 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/3483094f-6a11-4617-95ed-170664b5a10b">

## 3.Segment Analysis
### Q: Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year

```sql
create view removed_id as (
with cte as (
select  interest_id, count(distinct month_year) total_months 
from interest_metrics 
group by 1
having total_months < 6)
select *
from interest_metrics
where interest_id not in (select interest_id from cte));
-- top 10 interests 
select month_year, i.interest_id, m.interest_name, round(max(composition) ,2) max_composition
from removed_id i
join interest_map m on i.interest_id = m.id
group by 1,2,3
order by 4 desc 
limit 10 
;
-- bottom 10 interest
select month_year, i.interest_id, m.interest_name, round(max(composition) ,2) max_composition
from removed_id i
join interest_map m on i.interest_id = m.id
group by 1,2,3
order by 4 asc
limit 10 
;

```
#### Outputs:

#### Top 10

<img width="492" alt="Screenshot 2024-03-10 at 8 58 08 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/97065ece-459a-439c-a569-0d5f9a0fd4b3">

#### Bottom 10

<img width="492" alt="Screenshot 2024-03-10 at 8 59 57 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/31479914-41b0-44c2-a05e-6f77e9d1392d">

### Q: Which 5 interests had the lowest average ranking value?
```sql

select i.interest_id, m.interest_name, round(avg(ranking),2) avg_ranking
from removed_id i
join interest_map m on i.interest_id = m.id
group by 1,2 
order by avg_ranking asc
limit 5;

```
#### Output: 

<img width="370" alt="Screenshot 2024-03-10 at 9 10 02 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/c91f97b8-ff03-44d3-9375-7ef50c8c6c46">

### Q: Which 5 interests had the largest standard deviation in their percentile_ranking value?

```sql

select i.interest_id, m.interest_name, round(stddev_samp(percentile_ranking),2) std_percentile_ranking
from removed_id i
join interest_map m on i.interest_id = m.id
group by 1,2
order by std_percentile_ranking desc
limit 5;

```
#### Output 

<img width="378" alt="Screenshot 2024-03-10 at 9 52 24 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/b08b5836-01a6-43bb-aa6d-6f40cb36a582">


### Q: For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?
```sql
with cte as (
select i.interest_id, m.interest_name, round(stddev_samp(percentile_ranking),2) std_percentile_ranking
from removed_id i
join interest_map m on i.interest_id = m.id
group by 1,2 
order by 3 desc
limit 5
), 
cte1 as (
select i.interest_id, m.interest_name, percentile_ranking, month_year, rank()over(partition by i.interest_id order by percentile_ranking desc) r
from interest_metrics i
join interest_map m on i.interest_id = m.id
where interest_id in (select interest_id from cte)
),
cte2 as (
select i.interest_id, m.interest_name, percentile_ranking, month_year, rank()over(partition by i.interest_id order by percentile_ranking asc) r
from interest_metrics i
join interest_map m on i.interest_id = m.id
where interest_id in (select interest_id from cte)
)
select a.interest_id, a.interest_name, a.percentile_ranking max_percentile_ranking, a.month_year max_month_year, b.percentile_ranking min_percentile_ranking, b.month_year min_month_year
from cte1 a 
join cte2 b on a.interest_id = b.interest_id and a.r = 1 and b.r=1

```
#### Output: 
<img width="794" alt="Screenshot 2024-03-10 at 10 37 55 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/3d973a21-698e-433f-9515-7d244d52ce40">

### Q: How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?

## 4. Index Analysis
### The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.
### Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.
```sql
alter table interest_metrics
add avg_composition decimal(10,2);

update interest_metrics
set avg_composition = round(composition/index_value,2) ;
select * from interest_metrics
```
### Q: What is the top 10 interests by the average composition 
```sql
with cte as (
select month_year, interest_id, m.interest_name, avg_composition, dense_rank()over(partition by month_year order by avg_composition desc) r
from interest_metrics i 
join interest_map m on i.interest_id = m.id
)
select month_year, interest_id, interest_name , avg_composition
from cte 
where r <= 10
```
#### Output: 
<img width="491" alt="Screenshot 2024-03-11 at 12 36 19 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/3fec2def-cfd3-480d-b51a-c5b286d7d48d">
for each month?

### Q: For all of these top 10 interests - which interest appears the most often?

``` sql
-- create a view table for top 10 interests for easier access to top 10 inteests list 
create view top_10_avg as(
with cte as (
select month_year, interest_id, m.interest_name, avg_composition, dense_rank()over(partition by month_year order by avg_composition desc) r
from interest_metrics i 
join interest_map m on i.interest_id = m.id
)
select interest_id, interest_name, count(*) cnt, dense_rank()over(order by count(*) desc) ranks
from top_10_avg
group by 1,2
order by 3 desc ; 

```
#### Output: 

<img width="399" alt="Screenshot 2024-03-11 at 12 39 17 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/25188e6a-f294-4d24-a192-99f7cbca45ba">


### Q: What is the average of the average composition for the top 10 interests for each month?
```sql
select month_year, round(avg(avg_composition),2) avg_of_avg_composition
from top_10_avg
group by 1
```

#### Output: 

<img width="264" alt="Screenshot 2024-03-11 at 12 43 56 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/81d40af0-f800-4b9a-abcd-04b309133e35">


### Q: What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output.
```sql
with cte as(
select i.month_year, m.interest_name, avg_composition as max_index_composition
from interest_metrics i 
join interest_map m on i.interest_id = m.id
where (i.month_year, avg_composition) in (select month_year, max(avg_composition) from interest_metrics group by 1)), 
cte1 as (
select month_year,
 interest_name,
 max_index_composition,
 round(avg(max_index_composition)over(order by month_year rows between 2 preceding and current row),2) 3_mo_rolling_avg, 
 concat(lag(interest_name)over(order by month_year),': ', lag(max_index_composition)over(order by month_year)) 1_mo_ago,
  concat(lag(interest_name,2)over(order by month_year),': ', lag(max_index_composition,2)over(order by month_year)) 2_mo_ago
from cte) 
select * 
from cte1 
where month_year between '2018-09-01' and '2019-08-01'
```
#### Output: 

<img width="944" alt="Screenshot 2024-03-11 at 1 04 24 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/eaf606c0-7001-4dc5-9c8e-d4a230bf7810">

### Q: Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?


