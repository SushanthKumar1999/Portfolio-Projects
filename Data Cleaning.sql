-- Cleaning Data in Sql

select *
from ProjectPortfolio.dbo.Nashville_housing
------------------------------------------------------------
--Standardize date Format

select SaleDate,CONVERT(date,SaleDate) 
from ProjectPortfolio.dbo.Nashville_housing

UPDATE  Nashville_housing
SET SaleDate=CONVERT(date,SaleDate)

ALTER TABLE Nashville_housing
add Sale_Date date;

UPDATE  Nashville_housing
SET Sale_Date=CONVERT(date,SaleDate)

select Sale_Date,CONVERT(date,SaleDate) 
from ProjectPortfolio.dbo.Nashville_housing

------------------------------------------------------------------------------------
/*
Populate property address data
*/
select * 
from ProjectPortfolio.dbo.Nashville_housing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from ProjectPortfolio.dbo.Nashville_housing a
join ProjectPortfolio.dbo.Nashville_housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from ProjectPortfolio.dbo.Nashville_housing a
join ProjectPortfolio.dbo.Nashville_housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null
-------------------------------------------------------------------------------------------------------
 --Break address into individual Columns(Address,City,State)
  
select PropertyAddress 
from ProjectPortfolio.dbo.Nashville_housing

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as city
from ProjectPortfolio.dbo.Nashville_housing

ALTER TABLE Nashville_housing
add PropertysplitAddress nvarchar(255);

UPDATE  Nashville_housing
SET PropertysplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Nashville_housing
add PropertysplitCity nvarchar(255);

UPDATE  Nashville_housing
SET PropertysplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select * 
from  ProjectPortfolio.dbo.Nashville_housing

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from ProjectPortfolio.dbo.Nashville_housing

ALTER TABLE ProjectPortfolio.dbo.Nashville_housing
add OwnersplitAddress nvarchar(250)

UPDATE ProjectPortfolio.dbo.Nashville_housing
SET OwnersplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE ProjectPortfolio.dbo.Nashville_housing
add OwnersplitCity nvarchar(250);

UPDATE  ProjectPortfolio.dbo.Nashville_housing
SET OwnersplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE ProjectPortfolio.dbo.Nashville_housing
add OwnersplitState nvarchar(250);

UPDATE ProjectPortfolio.dbo.Nashville_housing
SET OwnersplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from ProjectPortfolio.dbo.Nashville_housing

--------------------------------------------------------------------------------------------------
/*
Change Y and N to Yes and No in Sold Vs Vacant Column
*/

select distinct SoldAsVacant,count(SoldAsVacant)
from ProjectPortfolio.dbo.Nashville_housing
group by SoldAsVacant
order by 2

select SoldAsVacant ,CASE WHEN SoldAsVacant='Y' then 'Yes'
WHEN SoldAsVacant='N' then 'No'
ELSE SoldAsVacant
END
from ProjectPortfolio.dbo.Nashville_housing

update ProjectPortfolio.dbo.Nashville_housing
set SoldAsVacant=(CASE WHEN SoldAsVacant='Y' then 'Yes'
WHEN SoldAsVacant='N' then 'No'
ELSE SoldAsVacant
END)

-------------------------------------------------------------------------------------------------

--Remove Duplicates
with row_num
as(
select *,
ROW_NUMBER() over (partition by ParcelID,
                   PropertyAddress,
                   SalePrice,
                   SaleDate,
                   LegalReference
                   order by UniqueID) as row_num
from ProjectPortfolio.dbo.Nashville_housing
)
DELETE 
from row_num
where row_num>1


with row_num
as(
select *,
ROW_NUMBER() over (partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference order by UniqueID) as row_num
from ProjectPortfolio.dbo.Nashville_housing
)
SELECT * 
from row_num
where row_num>1

------------------------------------------------------------------------------------------------
--Delete Unused Columns

select *
from ProjectPortfolio.dbo.Nashville_housing

ALTER TABLE ProjectPortfolio.dbo.Nashville_housing 
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE ProjectPortfolio.dbo.Nashville_housing 
DROP COLUMN SaleDate






