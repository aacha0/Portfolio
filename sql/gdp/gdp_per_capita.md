# Braintree Analytics Code Challenge
##Q1. Data Integrity Checking & Cleanup
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
### Answers
![Screenshot 2024-02-19 at 4 11 34 PM](https://github.com/aacha0/Portfolio/assets/148589444/7597ce71-7fca-482e-9712-d3ad3685fc63)
