
#region differences 
 select  distinct a.region, (b.region_sum  - a.region_sum) difference, round((b.region_sum  - a.region_sum)/a.region_sum *100,2) percentage_diff
 from comparison a 
 join comparison b 
 on a.region = b.region
 where a.new_packaging = 'before' and b.new_packaging = 'after'
 order by difference ;

 #age band differences 
 select  distinct a.age_band, b.age_band_sum-a.age_band_sum difference,round((b.age_band_sum-a.age_band_sum)/b.age_band_sum*100,2) percentage_difference
 from comparison a 
 join comparison b 
 on a.age_band = b.age_band
 where a.new_packaging = 'before' and b.new_packaging = 'after'
 order by difference ;

 #platform differences
select  distinct a.platform, b.platform_sum-a.platform_sum difference, round((b.platform_sum-a.platform_sum)/b.platform_sum*100,2) percentage_difference
 from comparison a 
 join comparison b 
 on a.platform = b.platform
 where a.new_packaging = 'before' and b.new_packaging = 'after'
 order by difference ;
 
#demographic differences
select   distinct a.demographic, b.demographic_sum-a.demographic_sum as difference, round((b.demographic_sum-a.demographic_sum)/b.demographic_sum*100,2) percentage_difference
 from comparison a 
 join comparison b 
 on a.demographic = b.demographic
 and a.new_packaging = 'before' and b.new_packaging = 'after'
 order by difference ;
 
 #customer type differences
select  distinct a.customer_type, b.customer_type_sum-a.customer_type_sum as difference, round((b.customer_type_sum-a.customer_type_sum)/b.customer_type_sum*100,2) percentage_difference
 from comparison a 
 join comparison b 
 on a.customer_type = b.customer_type
 and a.new_packaging = 'before' and b.new_packaging = 'after'
 order by difference ;
 