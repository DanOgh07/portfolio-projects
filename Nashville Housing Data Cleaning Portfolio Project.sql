USE housing_data;

LOAD DATA LOCAL INFILE '/Users/DELL/Desktop/Projects/PortfolioProjects/Nashville_Housing_Data_for_Data_Cleaning.csv'
INTO TABLE nashville_housing_data
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- DATA CLEANING

SELECT 
    *
FROM
    nashville_housing_data;
    
-- Standardise Date Fromat
SELECT 
    SaleDate, CONVERT(SaleDate, DATE)
FROM
    nashville_housing_data;
    
ALTER TABLE nashville_housing_data
ADD COLUMN SaleDateConverted DATE;
    
UPDATE nashville_housing_data
SET SaleDateConverted = CONVERT(SaleDate, DATE);

ALTER TABLE nashville_housing_data
DROP COLUMN SaleDate,
RENAME COLUMN SaleDateConverted TO SaleDate;

-- Populate Property Address Column

SELECT 
    PropertyAddress
FROM
    nashville_housing_data
WHERE PropertyAddress = "";

SELECT 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    CASE
		WHEN a.PropertyAddress = '' THEN b.PropertyAddress
        ELSE a.PropertyAddress
	END AS PropertyAddress
FROM
    nashville_housing_data a
        JOIN
    nashville_housing_data b ON a.ParcelID = b.ParcelID
        AND a.UniqueID != b.UniqueID
WHERE
    a.PropertyAddress = '';
    
UPDATE nashville_housing_data a
        JOIN
    nashville_housing_data b ON a.ParcelID = b.ParcelID
        AND a.UniqueID != b.UniqueID 
SET 
    a.PropertyAddress = b.PropertyAddress
WHERE
    a.PropertyAddress = '';
    
-- Splitting Property Address into Individual Columns - House No. + Street, City
SELECT SUBSTRING(PropertyAddress, 1, POSITION("," IN PropertyAddress) - 1) AS Address,
		SUBSTRING(PropertyAddress, POSITION("," IN PropertyAddress) + 1, LENGTH(PropertyAddress)) AS City
FROM nashville_housing_data;

ALTER TABLE nashville_housing_data
ADD COLUMN PropertySplitAddress TEXT,
ADD COLUMN PropertyCity TEXT;
    
UPDATE nashville_housing_data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, POSITION("," IN PropertyAddress) - 1),
	PropertyCity = SUBSTRING(PropertyAddress, POSITION("," IN PropertyAddress) + 1, LENGTH(PropertyAddress));

ALTER TABLE nashville_housing_data
DROP COLUMN PropertyAddress,
RENAME COLUMN PropertySplitAddress TO PropertyAddress;


-- Populating Owner Address Column will not be useful, because some Owners would have wanted to stay anonymous
-- Splitting Owner Address into Individual Columns - House No. + Street, City, State

SELECT 
   SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ",", 1), ",", -1) AS Owner_Address,
   SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ",", 2), ",", -1) AS OwnerCity,
   SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ",", 3), ",", -1) AS OwnerState
FROM
    nashville_housing_data;
    
ALTER TABLE nashville_housing_data
ADD COLUMN Owner_Address TEXT,
ADD COLUMN OwnerCity TEXT,
ADD COLUMN OwnerState TEXT;

UPDATE nashville_housing_data
SET Owner_Address = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ",", 1), ",", -1),
	OwnerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ",", 2), ",", -1),
    OwnerState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ",", 3), ",", -1);

ALTER TABLE nashville_housing_data
DROP COLUMN OwnerAddress,
RENAME COLUMN Owner_Address TO OwnerAddress;

-- Change "Y" to "Yes" and "N" to "No" in the SoldAsVacant column (Standardisation)

SELECT DISTINCT
    (SoldAsVacant), COUNT(SoldAsVacant) AS frequency
FROM
    nashville_housing_data
GROUP BY SoldAsVacant
ORDER BY frequency;

SELECT
	SoldAsVacant,
	CASE SoldAsVacant
		WHEN 'Y' THEN 'Yes'
        WHEN 'N' THEN 'No'
        ELSE SoldAsVacant
	END AS SoldAsVacant
FROM
	nashville_housing_data;
    
UPDATE nashville_housing_data
SET SoldAsVacant = CASE SoldAsVacant
		WHEN 'Y' THEN 'Yes'
        WHEN 'N' THEN 'No'
        ELSE SoldAsVacant
		END;
        
-- REMOVE DUPLICATES (Rank, Order Rank, Row Number) -- Row Number to identify duplicate rows

WITH RowNumCTE AS (
    SELECT
        UniqueID,
        ROW_NUMBER() OVER (
            PARTITION BY 
                ParcelID,
                SalePrice,
                LegalReference,
                SaleDate,
                PropertyAddress
            ORDER BY UniqueID
        ) AS row_num
    FROM nashville_housing_data
)
-- SELECT * FROM RowNumCTE
-- WHERE row_num > 1;
DELETE t
FROM nashville_housing_data t
JOIN RowNumCTE ON t.UniqueID = RowNumCTE.UniqueID
WHERE RowNumCTE.row_num > 1;


-- Drop Unused Columns (already dropped SaleDate, PropertyAddress & OwnerAddress)
ALTER TABLE nashville_housing_data
DROP COLUMN TaxDistrict;












    
