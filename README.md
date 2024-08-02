# Data Cleaning with SQL: Healthcare Dataset
## Project Overview
This project showcases my work on data cleaning using SQL, focusing on a healthcare dataset. The primary goal was to ensure data quality and consistency by removing duplicates, standardizing data formats, handling blank and null values, and converting column types as necessary.

## Objectives
**Remove Duplicates**: Identify and eliminate duplicate records to ensure each entry is unique.

**Standardize Dataset**: Ensure consistency in data formatting across the dataset.

**Column Type Conversion**: Change column types where necessary to align with the data's nature and improve query performance.

**Handle Blank and Null Values**: Identify and appropriately handle blank and null values to maintain data integrity.

## Datasets Used
The project utilized a healthcare dataset which included patient information, medical records, Insurance provider, hospital and doctor's data and several other things. The dataset contained various inconsistencies and redundant records that needed to be addressed.

## SQL Techniques
**1. Removing Duplicate Entries**

Using Common Table Expressions (CTEs) to identify and remove duplicates:

```
WITH duplicate_cte AS (
SELECT *, ROW_NUMBER() OVER(
  PARTITION BY `Name`,Age,Gender,`Blood Type`,`Medical Condition`,`Date of Admission`,
  Doctor,Hospital,`Insurance Provider`,`Billing Amount`,`Room Number`,`Admission Type`,
  `Discharge Date`,Medication,`Test Results`) AS row_num
FROM healthcare_staging
)

SELECT *
FROM duplicate_cte
WHERE row_num > 1;
```

**2. Standardizing Data Formats**
Utilizing string functions to ensure proper case and consistent formats:

```
UPDATE healthcare_staging2
SET `Name` = CONCAT(
UPPER(SUBSTRING(`Name`,1,1)),
LOWER(SUBSTRING(`Name`,2,LOCATE(' ',`Name`) - 1)),
" ",
UPPER(SUBSTRING(`Name`,LOCATE(' ',`Name`) + 1,1)),
LOWER(SUBSTRING(`Name`, LOCATE(' ',`Name`) + 2)));


SELECT DISTINCT `Insurance Provider`
FROM healthcare_staging2;

-- Updating other things such as Insurance provider
UPDATE healthcare_staging2
SET `Insurance Provider` = "United Health Care"
WHERE `Insurance Provider` = "UnitedHealthcare";

```
**3. Changing Column Types**
Altering column types for better data integrity and query performance:

```
UPDATE healthcare_staging2
SET `Discharge Date` = STR_TO_DATE(`Discharge Date`,"%Y-%m-%d");

-- After setting values to datetime we need to alter the column type
ALTER TABLE healthcare_staging2
MODIFY COLUMN `Discharge Date` DATE;
```

**4. Handling Blank and Null Values**
Identifying and handling blank and null values to maintain data quality:

```
SELECT * FROM healthcare_staging2 
WHERE `Name` IS NULL OR `Name`="";

SELECT SUM(ISNULL(`Date of Admission`))
FROM healthcare_staging2;
```

## Results

**Data Consistency**: The dataset was standardized, ensuring consistency in date formats and text fields.

**Data Integrity**: Duplicate records were removed, and all blank and null values were appropriately handled.

**Improved Query Performance**: Column types were optimized, resulting in better performance for data queries.

## Conclusion

This project demonstrates the importance of data cleaning in maintaining the quality and integrity of datasets. By using SQL for data cleaning tasks, I was able to transform a messy healthcare dataset into a structured and reliable source of information. The techniques and queries showcased in this project can be applied to similar datasets to ensure data quality and consistency.

## Future Work

Implementing more advanced data validation rules.
Automating data cleaning processes using stored procedures and triggers.
Exploring the integration of data cleaning tasks within ETL pipelines.

## Acknowledgements
Special thanks to the creators of the healthcare dataset for providing a valuable resource for this data cleaning exercise.

Feel free to reach out if you have any questions or suggestions. Contributions and feedback are welcome!

### Author: Khushal Vanani
### Contact: khushalvanani9@gmail.com

