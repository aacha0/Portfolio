-- cleaning data in sql queries
select *
from housing 

-- standarize date formate
update housing
set saledate = str_to_date(saledate,"%M %d,%Y");

select saledate
from housing

-- populate property address data
update housing
set propertyaddress = null where propertyaddress=''


select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress,coalesce(a.propertyaddress,b.propertyaddress)
from housing a
join housing b
	on a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid 
where a.propertyaddress is null

update housing a -- idk what happened even though most of my codes had errors but somehow updated the table 
join housing b
	on a.parcelid = b.parcelid
    and a.uniqueid <> b.uniqueid
set a.propertyaddress =  coalesce(a.propertyaddress,b.propertyaddress)

-- breaking out address into individual columns (address, city, state)

select propertyaddress
from housing 

alter table housing 
add address nvarchar(255);

update housing 
set address = substring_index(propertyaddress, ",",1 ) 

alter table housing
add city nvarchar(255);


select
	propertyaddress,
	substring_index(propertyaddress, ",",1 ) as address, --  the video used substring+charindex
    substring_index(propertyaddress, ",",-1) as city 
from housing

select * from housing 

-- parse name: mysql doesn't have parsename function 
-- split owneraddress with substring_index 
select owneraddress 
from housing

select 
substring_index(owneraddress,",",1) as owneraddress_address, 
substring_index(substring_index(owneraddress,",",2),",",-1) as owneraddress_city,
substring_index(owneraddress,",",-1) as owneraddress_state
from housing 

alter table housing 
add OwnerSplitAddress nvarchar(255);

update housing 
set OwnerSplitAddress = substring_index(owneraddress,",",1)


alter table housing
add OwnerCity nvarchar(255);

update housing
set OwnerCity = substring_index(substring_index(owneraddress,",",2),",",-1)

alter table housing 
add OwnerState nvarchar(255);

update housing
set OwnerState = substring_index(owneraddress,",",-1)

-- change y  and n to yes and no in "Sold as Vacant" field

select  distinct soldasvacant, count(soldasvacant) 
from housing 
group by soldasvacant
order by 2

select soldasvacant, 
	case when soldasvacant = "Y" then "Yes"
		when soldasvacant = "N" then "No"
		Else soldasvacant
    END
from housing;
update housing
set soldasvacant = 
case 
    when trim(soldasvacant) = "Y" then "Yes"
	when trim(soldasvacant) = "N" then "No"
    else soldasvacant 
END;
-- remove duplicates 
-- mySQL does not allow to update or delete CTE
with RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From housing 
)

-- DELETE
-- FROM housing p1
-- WHERE EXISTS (SELECT 1 FROM housing p2
             -- WHERE p2.ParcelID = p1.ParcelID AND
                   --  p2.PropertyAddress = p1.PropertyAddress AND
                  --  p2.SalePrice = p1.SalePrice AND
                   -- p2.SaleDate = p1.SaleDate AND
                   -- p2.LegalReference = p1.LegalReference AND
                  --  p2.UniqueID < p1.UniqueID);
                  
-- delete unused columns 
-- in mysql, you have to specify "drop column" for every column. you cannot just do it all in once 
select * from housing 
alter table housing
drop column taxdistrict, 
drop column propertyaddress

