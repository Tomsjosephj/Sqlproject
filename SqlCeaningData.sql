
-- Creating the database
create database myproject;

use myproject;
  
-- Creating the table Housingdata

CREATE TABLE HousingData (
    UniqueID INT,
    ParcelID VARCHAR(100),
    LandUse VARCHAR(100),
    PropertyAddress VARCHAR(255), 
    SaleDate Date,
    SalePrice int, 
    LegalReference VARCHAR(100),
    SoldAsVacant VARCHAR(10),
    OwnerName VARCHAR(255), 
    OwnerAddress VARCHAR(255), 
    Acreage decimal(2,1),
    TaxDistrict VARCHAR(255), 
    LandValue decimal(7,2),
    BuildingValue decimal(7,2), 
    TotalValue decimal(7,2), 
    YearBuilt int,
    Bedrooms int,
    FullBath int,
    HalfBath int
);

-- Loading the csv file to sql
LOAD DATA  INFILE "F:/Sqlfiles/Nashville Housing Data for Data Cleaning.csv"
INTO TABLE housingdata
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


-- Updating the Saledate column


update housingdata
set SaleDate=
concat(
-- Extracting days
case
  when length(substring_index(SUBSTRING_INDEX(SaleDate, ',',1)," ",-1))=1 then concat('0',substring_index(SUBSTRING_INDEX(SaleDate, ',',1)," ",-1))
  else  substring_index(SUBSTRING_INDEX(SaleDate, ',',1)," ",-1)
  end,
 
 "-",
 case
 substring_index(SaleDate,' ',1)
               WHEN 'January' THEN '01'
               WHEN 'Febrary' THEN '02'
               WHEN 'March' THEN '03'
               WHEN 'April' THEN '04'
               WHEN 'May' THEN '05'
               WHEN 'June' THEN '06'
               WHEN 'July' THEN '07'
               WHEN 'August' THEN '08'
               WHEN 'September' THEN '09'
               WHEN 'October' THEN '10'
               WHEN 'November' THEN '11'
               WHEN 'December' THEN '12'
	end,
    "-",
    substring_index(SaleDate," ",-1)
 
 );
Alter table housingdata
add DateConverted Date;

UPDATE housingdata
SET DateConverted = STR_TO_DATE(SaleDate, '%d-%m-%Y');


select * from housingdata;

-- seperatring address column

Select PropertyAddress
From housingdata
Where PropertyAddress is null;


-- Extracting Address from ownerAddress

Alter Table housingdata
add Address varchar(50);

update housingdata
set Address=
    substring_index(OwnerAddress,',',1);
    
-- Extracting city from ownerAddress
Alter Table housingdata
add State varchar(50);

update housingdata
set State=
     substring_index(substring_index(OwnerAddress,',',2),",",-1);

select * from housingdata;

-- Extracting State from ownerAddress

Alter Table housingdata
add State varchar(50);

update housingdata
set state=   substring_index(OwnerAddress,',',-1)
     ;

select * from housingdata;

ALTER TABLE housingdata
DROP COLUMN Adress;

-- change y to yes and n to no in soldasvaccant

ALTER TABLE housingdata
MODIFY COLUMN SoldAsVacant VARCHAR(10);

SELECT DISTINCT SoldAsVacant
FROM housingdata;

UPDATE housingdata
SET SoldAsVacant =
  CASE 
    WHEN SoldAsVacant = 'N' THEN 'N0'
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
  END;


-- Deleting duplicates

SELECT ParcelID,PropertyAddress,SalePrice,SaleDate, COUNT(*)
FROM housingdata
GROUP BY ParcelID,PropertyAddress,SalePrice,SaleDate
HAVING COUNT(*) > 1;

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

From housingdata
)select *
From RowNumCTE
Where row_num > 1



-- Deleting the unwanted columns

ALTER TABLE housingdata
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate,
DROP COLUMN TaxDistrict;

select * from housingdata






