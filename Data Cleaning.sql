Select *
FROM Projects.dbo.NashvileHousing



-- Standardize Date Format

Select SaleDateConverted,CONVERT(Date, SaleDate)
FROM Projects.dbo.NashvileHousing

Update NashvileHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvileHousing
Add SaleDateConverted Date;

Update NashvileHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



--Populate Property Address data

Select *
FROM Projects.dbo.NashvileHousing
--WHERE PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Projects.dbo.NashvileHousing a
JOIN Projects.dbo.NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null



update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Projects.dbo.NashvileHousing a
JOIN Projects.dbo.NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
FROM Projects.dbo.NashvileHousing
--WHERE PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

FROM Projects.dbo.NashvileHousing


ALTER TABLE NashvileHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 


ALTER TABLE NashvileHousing
Add PropertySplitCity  Nvarchar(255);

Update NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *

FROM Projects.dbo.NashvileHousing




Select OwnerAddress
FROM Projects.dbo.NashvileHousing

ALTER TABLE NashvileHousing
drop column OnwerSplitCity



Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Projects.dbo.NashvileHousing


ALTER TABLE NashvileHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvileHousing
Add OwnerSplitCity  Nvarchar(255);

Update NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvileHousing
Add OwnerSplitState Nvarchar(255);

Update NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



Select *

FROM Projects.dbo.NashvileHousing







-- Change Y and N to Yes and No "Sold as Vacant" field


Select DISTINCT(SoldAsVacant), Count(SoldASVacant)
FROM Projects.dbo.NashvileHousing
Group by SoldASVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant 
	   END
From Projects.dbo.NashvileHousing



Update Projects.dbo.NashvileHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant 
	   END







-- Remove Duplicates

WITH RowNumCTE AS(
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


From Projects.dbo.NashvileHousing
--order by ParcelID
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress











-- Delete Unused Columns


Select *
FROM Projects.dbo.NashvileHousing

ALTER TABLE Projects.dbo.NashvileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Projects.dbo.NashvileHousing
DROP COLUMN SaleDate