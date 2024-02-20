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



