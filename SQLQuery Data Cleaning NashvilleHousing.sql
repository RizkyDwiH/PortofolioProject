/*

Cleaning Data in SQL Queries

*/


select *
from PortofolioProject.dbo.NashvilleHousing



-- Standardize Date Format

select  SaleDateConverted, Convert(Date, SaleDate)
from PortofolioProject.dbo.NashvilleHousing

update PortofolioProject.dbo.NashvilleHousing
set SaleDate = Convert(Date, SaleDate)

ALTER TABLE PortofolioProject.dbo.NashvilleHousing
add SaleDateConverted Date;

update PortofolioProject.dbo.NashvilleHousing
set SaleDateConverted = Convert(Date, SaleDate)



-- Populate Property Address data

select *
from PortofolioProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortofolioProject.dbo.NashvilleHousing a
join PortofolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortofolioProject.dbo.NashvilleHousing a
join PortofolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL



-- Breaking out Address into Individual Columns (Address, City, State), separate

select PropertyAddress
from PortofolioProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
--order by ParcelID


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)  + 1, len(PropertyAddress)) as Address
from PortofolioProject.dbo.NashvilleHousing


ALTER TABLE PortofolioProject.dbo.NashvilleHousing
add PropertySplitAddress NVARCHAR (255);

update PortofolioProject.dbo.NashvilleHousing
set PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 )


ALTER TABLE PortofolioProject.dbo.NashvilleHousing
add PropertySplitCity NVARCHAR (255);

update PortofolioProject.dbo.NashvilleHousing
set PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)  + 1, len(PropertyAddress))


select *
from PortofolioProject.dbo.NashvilleHousing



select OwnerAddress
from PortofolioProject.dbo.NashvilleHousing


select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3 )
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2 )
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1 )
from PortofolioProject.dbo.NashvilleHousing



ALTER TABLE PortofolioProject.dbo.NashvilleHousing
add OwnerSplitAddress NVARCHAR (255);

update PortofolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3 )



ALTER TABLE PortofolioProject.dbo.NashvilleHousing
add OwnerSplitCity NVARCHAR (255);

update PortofolioProject.dbo.NashvilleHousing
set OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2 )



ALTER TABLE PortofolioProject.dbo.NashvilleHousing
add OwnerSplitState NVARCHAR (255);

update PortofolioProject.dbo.NashvilleHousing
set OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1 )


select *
from PortofolioProject.dbo.NashvilleHousing



-- Change Y and N to Yes and No in "Sold as Vacant" field


select DISTINCT SoldAsVacant, count(SoldAsVacant)
from PortofolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
from PortofolioProject.dbo.NashvilleHousing


UPDATE PortofolioProject.dbo.NashvilleHousing
SET SoldAsVacant =  CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END



-- Remove Duplicates

WITH RowNumCTE as(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
				    UniqueID
					) row_num

from PortofolioProject.dbo.NashvilleHousing
--order by ParcelID
)

SELECT * 
from RowNumCTE
where row_num > 1
order by PropertyAddress



-- Delete Unused Columns


select *
from PortofolioProject.dbo.NashvilleHousing


ALTER TABLE PortofolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortofolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate


