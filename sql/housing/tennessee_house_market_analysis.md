# Tennessee House Market 
##### Objective of this project: clean and format data 
## Step 1: Format date
````sql
-- standarize date formate
update housing
set saledate = str_to_date(saledate,"%M %d,%Y");

````

## Step 2: Update null values
````sql
-- replace empty cells in propertyaddress column to 'null'
update housing
set propertyaddress = null where propertyaddress=''

-- replace  null values in propertyaddress column with other property address if it has the same parceled
update housing a 
	on a.parcelid = b.parcelid
    and a.uniqueid <> b.uniqueid
set a.propertyaddress =  coalesce(a.propertyaddress,b.propertyaddress)
````

## Step 3: Split owner address to address, city, and sate

````sql
-- use substring_index to split the address from the format of "address,city,state" to "address","city","state" 
select 
substring_index(owneraddress,",",1) as owneraddress_address, 
substring_index(substring_index(owneraddress,",",2),",",-1) as owneraddress_city,
substring_index(owneraddress,",",-1) as owneraddress_state
from housing

-- create a  new column "OwnerSplitAddress"
alter table housing 
add OwnerSplitAddress nvarchar(255);

update housing 
set OwnerSplitAddress = substring_index(owneraddress,",",1)

-- create a new column "OwnerCity"
alter table housing
add OwnerCity nvarchar(255);

update housing
set OwnerCity = substring_index(substring_index(owneraddress,",",2),",",-1)

-- create a new column "OwnerState"
alter table housing 
add OwnerState nvarchar(255);

update housing
set OwnerState = substring_index(owneraddress,",",-1)

````
## Step 4: Update "Y" as "Yes" and "N" as "No"
````sql
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
````
## Step 5: Delete duplicates
````sql
with RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueID) row_num

From housing 
)

DELETE
FROM housing p1
WHERE EXISTS (SELECT 1 FROM housing p2
      WHERE p2.ParcelID = p1.ParcelID AND
       p2.PropertyAddress = p1.PropertyAddress AND
       p2.SalePrice = p1.SalePrice AND
       p2.SaleDate = p1.SaleDate AND
       p2.LegalReference = p1.LegalReference AND
       p2.UniqueID < p1.UniqueID);
                  


````
## Step 6: Delete unused columns 
````sql

alter table housing
drop column taxdistrict, 
drop column propertyaddress

````






















##### Data Source: <https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx>
##### Inspired by Alex the Analyst 
##### Tableau Dashboard: <https://public.tableau.com/views/TennesseeHouseMarketAnalysis/Dashboard1?:language=en-US&:sid=&:display_count=n&:origin=viz_share_link>
