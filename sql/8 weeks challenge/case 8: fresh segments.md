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
### Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month

```sql
alter table interest_metrics
drop column month_year ;

alter table interest_metrics 
add month_year date;

update interest_metrics
set month_year = cast(concat(year,'-',month,'-01') as date);
select * from interest_metrics
```

### What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?

```sql
select month_year, count(*) cnt
from interest_metrics
group by 1
order by 1
```
#### Output: 
<img width="117" alt="Screenshot 2024-03-09 at 11 38 17 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/51c49521-a762-4ad8-b001-85fef2056d02">

### What do you think we should do with these null values in the fresh_segments.interest_metrics

```sql
delete from interest_metrics
where month_year is null;
```
#### Since we want specific monthly data, we can delete the data that do not have a month_year record. 

### How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? ### What about the other way around?

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

### Summarise the id values in the fresh_segments.interest_map by its total record count in this table

```sql
select id, interest_name ,count(mt.interest_id) cnt
from interest_map m
join interest_metrics mt on m.id = mt.interest_id
group by 1,2
order by 3 desc
```
#### Output: 
<img width="229" alt="Screenshot 2024-03-10 at 12 25 33 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/28fc89e8-0cc7-48a0-ae19-cfb4592b0185">

### What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

```sql
select *
from interest_map m
join interest_metrics mt on m.id = mt.interest_id
where mt.interest_id = 21246

```
#### Output: 
<img width="971" alt="Screenshot 2024-03-10 at 12 36 34 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/fc223293-7e8e-4a13-bc69-b1505bbf6ee9">

#### We should use `INNER JOIN` to join tables to perform analysis

### Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?

```sql
select count(*)
from interest_map m
join interest_metrics mt on m.id = mt.interest_id
where mt.month_year < m.created_at
```
#### Output:

<img width="54" alt="Screenshot 2024-03-10 at 12 41 38 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/11ae2a85-2836-47eb-b0ed-eaf0de472c8c">

#### Out of all records, there are 188 records where the `month_year` value precedes the `created_at` value. However, previously, we manually adjusted `month_year` to reflect the beginning of the month. Let's verify if these records align with the `created_at` month and year

```sql
select count(*)
from interest_map m
join interest_metrics mt on m.id = mt.interest_id
where date_format(created_at, '%Y-%m') >  month_year
```
#### Output:
<img width="54" alt="Screenshot 2024-03-10 at 12 45 32 AM" src="https://github.com/aacha0/Portfolio/assets/148589444/55c63d50-cd1a-4cab-af26-d13ab5f822bd">

#### Since it returned `0` records that have `month_year` earlier than the `created_at`, these records should be considered valid data
