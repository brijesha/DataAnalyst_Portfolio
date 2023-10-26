select * from nashville_housing nh 

ALTER TABLE nashville_housing 
RENAME COLUMN "UniqueID " TO "UniqueID"


-- 1. 
-- standardsize date formate
select saledate , cast(saledate as Date)
from nashville_housing nh 

update nashville_housing 
set saledate = cast(saledate as Date)
---------------------------------------------------------

-- 2.
-- populate property address data
select *
from nashville_housing nh
where propertyaddress =''

select *
from nashville_housing nh 
--where propertyaddress =''
order by parcelid 

-- shelf join
update nashville_housing as a 
set propertyaddress = b.propertyaddress 
from nashville_housing as b
where a.parcelid = b.parcelid
	and a."UniqueID" <> b."UniqueID"
	and a.propertyaddress =''
--------------------------------------------------------------------------	

 -- 3.
-- breaking out column in to indivisual column (address, city, state)
select split_part(propertyaddress,',',1) as property_address, 
	split_part(propertyaddress,',',2) as property_city
from nashville_housing nh  

ALTER TABLE nashville_housing
ADD COLUMN property_address text

ALTER TABLE nashville_housing
ADD COLUMN property_city text

update nashville_housing 
set property_address = SPLIT_PART(propertyaddress , ',', 1),
    property_city = SPLIT_PART(propertyaddress, ',', 2)

    -- breaking owneraddress    
select split_part(owneraddress,',',1) as owner_address, 
	split_part(owneraddress,',',2) as owner_city,
	split_part(owneraddress,',',3) as owner_state
from nashville_housing nh  

ALTER TABLE nashville_housing
ADD COLUMN owner_address text

ALTER TABLE nashville_housing
ADD COLUMN owner_city text

ALTER TABLE nashville_housing
ADD COLUMN owner_state text

update nashville_housing 
set owner_address = SPLIT_PART(owneraddress, ',', 1),
    owner_city = SPLIT_PART(owneraddress, ',', 2),
    owner_state = SPLIT_PART(owneraddress, ',', 3)
    
select *
from nashville_housing nh 
----------------------------------------------------------------------

-- 4.
-- change Y and N to Yes and No in "solid as vacant" field
select distinct soldasvacant, 
	count(soldasvacant) 
from nashville_housing nh2
group by soldasvacant 
order by 2

select
	case when soldasvacant = 'Y' then 'Yes'
		when soldasvacant ='N' then 'No'
		else soldasvacant 
		end
from nashville_housing nh 

update nashville_housing  
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
		when soldasvacant ='N' then 'No'
		else soldasvacant 
		end
---------------------------------------------------------------------------

-- 5.
-- remove duplicates
WITH row_num_CTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY parcelid, 
            	propertyaddress, 
            	saledate, 
            	saleprice, 
            	legalreference
            ORDER BY "UniqueID"
        ) AS row_num
    FROM nashville_housing
)
delete 
FROM nashville_housing
WHERE ("UniqueID") IN (
		SELECT "UniqueID"
		    FROM row_num_CTE
		    WHERE row_num > 1
)
------------------------------------------------------

-- 6.
-- delete unused columns
alter table nashville_housing 
drop column propertyaddress, 
drop column owneraddress, 
drop column taxdistrict

select *
from nashville_housing nh 

