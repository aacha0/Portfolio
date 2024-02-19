# Braintree Analytics Code Challenge
##Q1. Data Integrity Checking & Cleanup
### 1a: Alphabetically list all of the country codes in the continent_map table that appear more than once.\n Display any values where country_code is null as country_code = "FOO" and make this row appear first in the list, \n even though it should be alphabetically sorted to the middle. Provide the results of this query as your answer. 

````sql
USE paypal;
-- update the empty strings to be NULL values 
UPDATE continent_map
SET
    country_code = CASE country_code WHEN '' THEN NULL ELSE country_code END,
    continent_code = CASE continent_code WHEN '' THEN NULL ELSE continent_code END;


SELECT COALESCE(country_code, 'FOO') AS country_code -- use coalesce to replace null value as "FOO"
FROM continent_map 
GROUP BY country_code
HAVING COUNT(*) > 1 -- filter country codes appear more than once 
ORDER BY MAX(CASE WHEN COALESCE(country_code, 'FOO') = 'FOO' THEN 0 ELSE 1 END) ASC, COUNT(*) DESC, country_code ASC;
````
