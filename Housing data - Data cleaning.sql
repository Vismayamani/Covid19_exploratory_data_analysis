--Data cleaning project

--Standardize date format
SELECT CAST(SaleDate AS datetime)
FROM [dbo].[Nashville Housing Data for Data Cleaning]

SELECT SaleDate, Convert(Date,SaleDate)
FROM [dbo].[Nashville Housing Data for Data Cleaning]

--Populate property address data
SELECT *
FROM [dbo].[Nashville Housing Data for Data Cleaning]
WHERE PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [dbo].[Nashville Housing Data for Data Cleaning] a
JOIN [dbo].[Nashville Housing Data for Data Cleaning] b
ON a.ParcelID=b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [dbo].[Nashville Housing Data for Data Cleaning] a
JOIN [dbo].[Nashville Housing Data for Data Cleaning] b
ON a.ParcelID=b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

--Breaking out address into individual column(Addres,City,State)

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as Address
FROM [dbo].[Nashville Housing Data for Data Cleaning]

ALTER TABLE 
[dbo].[Nashville Housing Data for Data Cleaning]
ADD PropertySplitAddress Nvarchar(255);

UPDATE [dbo].[Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE 
[dbo].[Nashville Housing Data for Data Cleaning]
ADD PropertySplitCity Nvarchar(255);

UPDATE [dbo].[Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

SELECT * FROM [dbo].[Nashville Housing Data for Data Cleaning]

SELECT OwnerAddress
FROM [dbo].[Nashville Housing Data for Data Cleaning]

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [dbo].[Nashville Housing Data for Data Cleaning]

ALTER TABLE 
[dbo].[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [dbo].[Nashville Housing Data for Data Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE 
[dbo].[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitCity Nvarchar(255);

UPDATE [dbo].[Nashville Housing Data for Data Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE 
[dbo].[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitState Nvarchar(255);

UPDATE [dbo].[Nashville Housing Data for Data Cleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * FROM [dbo].[Nashville Housing Data for Data Cleaning]

--Change Y and N to Yes and NO in"Sold in vacant" field

SELECT DISTINCT SoldAsVacant
FROM [dbo].[Nashville Housing Data for Data Cleaning]

SELECT CAST(SoldAsVacant AS VARCHAR(2))

, CASE WHEN CAST(SoldAsVacant AS VARCHAR(2)) = 1 THEN CAST('Yes' as bit)
     WHEN CAST(SoldAsVacant AS VARCHAR(2)) = 0 THEN CAST('No' as bit)
	 ELSE SoldAsVacant
	 END
FROM [dbo].[Nashville Housing Data for Data Cleaning]

--Remove dupliactes

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress,SalePrice,SaleDate, LegalReference
ORDER BY UniqueID) row_numb
FROM [dbo].[Nashville Housing Data for Data Cleaning]
)

SELECT * FROM RowNumCTE
WHERE row_numb=2

--Delete unused column
SELECT * FROM [dbo].[Nashville Housing Data for Data Cleaning]
ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress,SaleDate