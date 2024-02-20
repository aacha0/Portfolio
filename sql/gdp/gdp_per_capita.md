# Braintree Analytics Code Challenge
## Q1. Data Integrity Checking & Cleanup
### 1a: Alphabetically list all of the country codes in the continent_map table that appear more than once. Display any values where country_code is null as country_code = "FOO" and make this row appear first in the list, even though it should be alphabetically sorted to the middle. Provide the results of this query as your answer. 

````sql
USE GDP;
-- schema's name is 'GDP'
UPDATE continent_map
SET
    country_code = CASE country_code WHEN '' THEN NULL ELSE country_code END,
    continent_code = CASE continent_code WHEN '' THEN NULL ELSE continent_code END;
-- update empty string to be null value 

SELECT COALESCE(country_code, 'FOO') AS country_code -- use coalesce to replace null value as "FOO"
-- replace null values in country_code with 'FOO'
FROM continent_map 
GROUP BY country_code
HAVING COUNT(*) > 1
-- filter country codes that appear more than once 
ORDER BY MAX(CASE WHEN COALESCE(country_code, 'FOO') = 'FOO' THEN 0 ELSE 1 END) ASC, COUNT(*) DESC, country_code ASC;

````
### 1b. For all countries that have multiple rows in the continent_map table, delete all multiple records leaving only the 1 record per country. The record that you keep should be the first one when sorted by the continent_code alphabetically ascending. Provide the query/ies and explanation of step(s) that you follow to delete these records.

````sql
create table temp(
select *, row_number()over(partition by country_code order by continent_code asc) rn from continent_map) ;
-- create a table to 
-- use row_number() to order how many times each country_code has appeared and order it by continent_code alphabetically ascending
-- if rn> 1, then it means there's multiple entries

delete from  temp
where rn > 1;
-- delete values from table temp where those country_codes appear more than once

delete from continent_map; 
-- delete all records from continent_map, so we can reset the table

insert into continent_map
	select country_code, continent_code from temp;
-- insert the records from the temp table to continent_map table where I already deleted all duplicate values

drop table temp;
-- no longer need the table temp, so drop the table
````

### Q2. List the countries ranked 10-12 in each continent by the percent of year-over-year growth descending from 2011 to 2012. The percent of growth should be calculated as: ((2012 gdp - 2011 gdp) / 2011 gdp). The list should include the columns: rank, continent_name, country_code, country_name, growth_percent

````sql
 create view gdp_join as
    select a.country_code, c.country_name, e.continent_name, a.gdp_per_capita, a.year
   from per_capita a 
   join countries c on a.country_code = c.country_code 
   join continent_map d on d.country_code = a.country_code 
   join continents e on d.continent_code = e.continent_code; 
   -- create a view to store joined tables to avoid this process in future questions
   
   with cte as (
   select a.country_code, a.country_name, a.continent_name, a.gdp_per_capita as 'gdp2011', b.gdp_per_capita as 'gdp2012'
   from gdp_join a
   join gdp_join b on a.country_code = b.country_code and a.year = '2011' and b.year = '2012'),
   cte1 as (
   select *, round((gdp2012-gdp2011)/gdp2011*100,2) growth_percent, dense_rank()over(partition by continent_name order by (gdp2012-gdp2011)/gdp2011 desc) as r
   from cte)
   -- use cte to calculate growth percent and use dense_rank() to rank base on the growth percent by continent 
   -- use dense_rank() instead of rank() because I want to avoid skipping a rank 
   
   select r as 'rank', continent_name,country_code, country_name, concat(growth_percent, '%')  as growth_percent
   from cte1
   where r between 10 and 12;
   -- use where to filter rank between 10 and 12
````
### Output
![Screenshot 2024-02-19 at 4 11 34 PM](https://github.com/aacha0/Portfolio/assets/148589444/7597ce71-7fca-482e-9712-d3ad3685fc63)

### Q3. For the year 2012, create a 3 column, 1 row report showing the percent share of gdp_per_capita for the following regions: (i) Asia, (ii) Europe, (iii) the Rest of the World. Your result should look something like

````sql
select    
   concat(round(100*sum(case when continent_name = 'Asia' then gdp_per_capita else 0 end)/(select sum(gdp_per_capita) from gdp_join where year = 2012),2),'%') as 'Asia', 
   concat(round(100*sum(case when continent_name = 'Europe' then gdp_per_capita else 0 end)/(select sum(gdp_per_capita) from gdp_join where year = 2012),2),'%') as ' Europe', 
	concat(round(100*sum(case when continent_name not in ('Asia','Europe') then gdp_per_capita else 0 end)/(select sum(gdp_per_capita) from gdp_join where year = 2012),2),'%') as 'Rest of World'
-- use case when filtering data from Asia, Europe, and the rest of the world 
-- use concat to add a percentage sign after the number
-- use round to round up to two decimal places
-- use a subquery to calculate the sum of the 2012 world gdp 
   from gdp_join
   where year = 2012;
    
````
### Output
![Screenshot 2024-02-19 at 4 26 50 PM](https://github.com/aacha0/Portfolio/assets/148589444/e9353aae-21c0-4cd6-809d-dcecc1f51ceb)

### Q4a. What is the count of countries and sum of their related gdp_per_capita values for the year 2007 where the string 'an' (case insensitive) appears anywhere in the country name?

````sql
select  count(country_code) as cnt,concat('$',round(sum(gdp_per_capita),2)) total_gdp_per_capita
-- use concat to add a dollar sign in front of the sum of gdp per capita
-- use count to count the number of countries with 'an' in the name
from gdp_join
where year = 2007 and country_name regexp 'an';
-- use WHERE and REGEXP to filter data 
````
![Screenshot 2024-02-19 at 4 33 07 PM](https://github.com/aacha0/Portfolio/assets/148589444/06e4c219-d239-4f90-ade8-ef93a09aacc6)

### Q4b. Repeat question 4a, but this time make the query case sensitive.

````sql
select  count(country_code) as cnt,concat('$',round(sum(gdp_per_capita),2)) total_gdp_per_capita
from gdp_join
where year = 2007 and country_name like binary '%an%';
-- add BINARY after LIKE to make the filter case-sensitive

````
### Output
![Screenshot 2024-02-19 at 4 47 13 PM](https://github.com/aacha0/Portfolio/assets/148589444/495e242f-a9a6-4cf6-ba2e-8ffaac446896)
 
### Q5. Find the sum of gpd_per_capita by year and the count of countries for each year that have non-null gdp_per_capita where (i) the year is before 2012 and (ii) the country has a null gdp_per_capita in 2012. Your result should have the columns: year, country_count, total

````sql
with cte as(
select *
from gdp_join 
where (country_code) not in (select country_code from gdp_join where year= 2012)  
and (country_code) in (select country_code from gdp_join where year < 2012) )
-- use cte and subqueries to filter countries that have non-null data before 2012 and don't have 2012 records at the same time

select year, count(distinct country_code) ,  concat('$',round(sum(gdp_per_capita),2))
from cte 
group by 1;
-- use group by, count, and sum to aggregate data by year
````
### Output 
![Screenshot 2024-02-19 at 4 53 17 PM](https://github.com/aacha0/Portfolio/assets/148589444/3a8a5c44-2063-4a31-9007-ced5305f3a6a)

### Q6. All in a single query, execute all of the steps below and provide the results as your final answer:
#### a. create a single list of all per_capita records for year 2009 that includes columns:continent_name, country_code, gdp_per_capita
#### b. order this list by: continent_name ascending, characters 2 through 4 (inclusive) of the country_name descending
#### c. create a running total of gdp_per_capita by continent_name
#### d. return only the first record from the ordered list for which each continent's running total of gdp_per_capita meets or exceeds $70,000.00 with the following columns: continent_name, country_code, country_name , gdp_per_capita, running_total

````sql
with cte as(
 select continent_name, country_code, concat('$',round(gdp_per_capita,2)) as gdp_per_capita, sum(gdp_per_capita)over(partition by continent_name) as running_total,
 row_number()over(partition by continent_name order by continent_name asc, substring(country_name,2,4) desc) rn
 from gdp_join
 where year = 2009
 order by continent_name asc, substring(country_name,2,4) desc
 )
 -- create a cte to filter data from 2009, rank country based on continent_name and country_code's characters 2 through 4 (inclusive) of the country_name descending in each continent, and calculate running total by continent
    
select continent_name, t.country_code, country_name, gdp_per_capita, concat('$',round(running_total,2)) as runnign_total 
from cte t
join countries c on t.country_code = c.country_code
where running_total >= 70000 and rn = 1
-- use WHERE to filter data that have running_total  by continent greater or equal to 70000.00 and is the first record from each continent ;
````
### Output
![Screenshot 2024-02-19 at 4 57 48 PM](https://github.com/aacha0/Portfolio/assets/148589444/4fc77303-dc9b-4e8a-83e5-7e23ed1c7969)

### Q7. Find the country with the highest average gdp_per_capita for each continent for all years. Now compare your list to the following data set. Please describe any and all mistakes that you can find with the data set below. Include any code that you use to help detect these mistakes.

![Screenshot 2024-02-19 at 5 08 23 PM](https://github.com/aacha0/Portfolio/assets/148589444/3a19b2cb-512b-4534-a087-1b7b677e1b20)

````sql


create temporary table temp_highest_gdp(
ranking int,
continent_name varchar(50),
country_code varchar(50),
country_name varchar(50),
avg_gdp_per_capita decimal(10,2));
insert into temp_highest_gdp( ranking, continent_name, country_code, country_name, avg_gdp_per_capita)
values (1, 'Africa','SYC','Seychelles',	11348.66) , ( 1,	'Asia',	'KWT',	'Kuwait',	43192.49),
(1,'Europe','MCO','Monaco',152936.10),(1,'North America','BMU','Bermuda',	83788.48), (1,'Oceania','AUS','Australia',47070.39),(1,'South America','CHL','Chile',10781.71);
-- create a temporary table to insert the table that was given 

with cte as(
select dense_rank()over(partition by continent_name order by avg(gdp_per_capita) desc) as rn, 
continent_name, country_code, country_name, round(avg(gdp_per_capita),2) avg_gdp_per_capita
from gdp_join
group by 2,3,4),
cte1 as (
select * from cte
where rn = 1
order by continent_name 
)
-- use one cte to rank countries base on avgerage gdp_per_capita by continent
-- use second cte to filter the highest average gdp per capita by continent

select t.country_code, case when t.country_code<>c.country_code then 'wrong_code' else null end
from temp_highest_gdp t
join cte1 c
on t.continent_name = c.continent_name 
where t.avg_gdp_per_capita <> c.avg_gdp_per_capita or 
t.country_code<> c.country_code 
-- join the temporary table with the CTE to compare numbers 
-- returns data that either do not have matched average gdp per capita or wrong country code/country name 
-- can use left join instead if wanting to check which record does not have any mistake

````
### Output
#### correct results
![Screenshot 2024-02-19 at 5 24 50 PM](https://github.com/aacha0/Portfolio/assets/148589444/7aba1808-7a68-4d34-b6a1-1628d54bf6c7)
#### comparison 
![Screenshot 2024-02-19 at 5 23 21 PM](https://github.com/aacha0/Portfolio/assets/148589444/5e096fdf-2a9e-4f8c-832b-0725b53c05e2)



