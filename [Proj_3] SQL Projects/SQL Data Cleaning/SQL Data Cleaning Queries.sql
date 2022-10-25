-- Cleaning Data in SQL Queries

SELECT * 
FROM PortfolioProject..NashvilleHousing

-- Removing the time from the SaleDate column
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- Different way of updating the columns of the database
ALTER TABLE NashvilleHousing
ADD SaleDateConv Date;

UPDATE NashvilleHousing
SET SaleDateConv = CONVERT(Date, SaleDate)

SELECT SaleDateConv
FROM PortfolioProject..NashvilleHousing

-- Dropping the SaleDate column
-- ALTER TABLE NashvilleHousing
-- DROP COLUMN SaleDate

-- Populate the null values from the PropertyAdress column
SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL
-- Because property address is not likely to change compared to other features in the table
-- Thus we can populate the null values given a reference point 

SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID
-- We can see here, ParcelID seems to be a unique ID for each PropertyAdress

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress  = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Separating the Property Address into individual features
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

-- SUBSTRING(string to extract from, start position, length of char to extract)
-- CHARINDEX(substring, string, start position)
SELECT
SUBSTRING(PropertyAddrss, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- Check
SELECT *
FROM PortfolioProject..NashvilleHousing

-- Doing something similar as above but slightly simpler for the OwnerAddress column
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Changing Y and N to 'Yes' and 'No' in the SoldAsVacant
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Identifying and removing duplicated entries (UNSOLVED)
-- It is not standard practice to delete data in the main dataframe, it is better to do it using CTE

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
				 ORDER BY UniqueID) row_num

FROM PortfolioProject..NashvilleHousing)

-- Checking for duplicates
SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE row_num > 1
ORDER BY PropertyAddress

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Delete Unused Columns
SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxiDsitrict, PropertyAddress, SaleDate