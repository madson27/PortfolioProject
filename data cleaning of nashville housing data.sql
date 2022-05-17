select * 
from [portfolio project ]..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- standardize the date format 

select saledate , convert(date, saledate)
from [portfolio project ]..NashvilleHousing

update NashvilleHousing
set saledate = convert(date, saledate)

-- this does not seems to work so we can alter the table 

alter table NashvilleHousing
add SaleDateConverted date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

select SaleDateConverted 
from [portfolio project ]..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select * 
from [portfolio project ]..NashvilleHousing

select  *
from [portfolio project ]..NashvilleHousing
where PropertyAddress is null

-- so we have some property adress which are null and we need to populate it 

select  *
from [portfolio project ]..NashvilleHousing
order by ParcelId

-- looking through this we find that where property adress is null the address csna be populated by the same parcel id and the next address of it, so thats why we need to self join and update the address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [portfolio project ]..NashvilleHousing a
join [portfolio project ]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

update a 
set  a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [portfolio project ]..NashvilleHousing a
join [portfolio project ]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- no more null values left in property address 

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from [portfolio project ]..NashvilleHousing

-- we have ',' as a delimiter here hence we will be using substring to split this property address into more useful columns

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
from [portfolio project ]..NashvilleHousing

''' substring( string, start, length) 
 charindex helps us find the index of a particular character 
 charindex(char, string) '''

 -- SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) means i am finding the index of , in property address and the using substring to get the first part of it 

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--------------------------------------------------------------------------------------------------------------------------

select OwnerAddress
from [portfolio project ]..NashvilleHousing

-- parsename works for . rather than , so we will first replace , with . and then use parsename on it 
--  PARSENAME ('object_name' , object_piece ) where object_piece 
--Is the object part to return. object_piece is of type int, and can have these values:
-- 1 = Object name
-- 2 = Schema name
-- 3 = Database name
-- 4 = Server name

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) -- and further on 
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) -- 2 is second to last
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) -- 1 is the name at the last of string
From [portfolio project ]..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From [portfolio project ]..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [portfolio project ]..NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [portfolio project ]..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
with cte as (
Select *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) row_num
From [portfolio project ]..NashvilleHousing
)

select *
from cte
where row_num > 1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From [portfolio project ]..NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate