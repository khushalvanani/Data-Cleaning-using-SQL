USE healthcare;

SELECT * FROM healthcare_dataset;

-- This is raw data we should move to a different table on which we can perform removal of duplicaiton or any other procedure
CREATE TABLE healthcare_staging
LIKE healthcare_dataset;

INSERT healthcare_staging
SELECT * FROM healthcare_dataset;


-- 1. Removing Duplicate Data


-- To found duplicates used Window function and ROW_NUMBER function
WITH duplicate_cte AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY `Name`,Age,Gender,`Blood Type`,`Medical Condition`,`Date of Admission`,Doctor,Hospital,`Insurance Provider`,`Billing Amount`,`Room Number`,`Admission Type`,
`Discharge Date`,Medication,`Test Results`) AS row_num
FROM healthcare_staging
)
SELECT * FROM duplicate_cte
WHERE row_num > 1;

SELECT * FROM healthcare_staging;

-- Now creating other table where all the operations will be done such as removing, standardizing etc..
CREATE TABLE `healthcare_staging2` (
  `Name` text,
  `Age` int DEFAULT NULL,
  `Gender` text,
  `Blood Type` text,
  `Medical Condition` text,
  `Date of Admission` text,
  `Doctor` text,
  `Hospital` text,
  `Insurance Provider` text,
  `Billing Amount` double DEFAULT NULL,
  `Room Number` int DEFAULT NULL,
  `Admission Type` text,
  `Discharge Date` text,
  `Medication` text,
  `Test Results` text,
  row_num int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM healthcare_staging2 WHERE row_num > 1;

INSERT healthcare_staging2
SELECT *, ROW_NUMBER() OVER(PARTITION BY `Name`,Age,Gender,`Blood Type`,`Medical Condition`,`Date of Admission`,Doctor,Hospital,`Insurance Provider`,`Billing Amount`,`Room Number`,`Admission Type`,
`Discharge Date`,Medication,`Test Results`) AS row_num
FROM healthcare_staging;

-- My safe mode was on So I had to disable it, Sometimes its on so you cannot update your data
SET SQL_SAFE_UPDATES = 0;

-- Removing duplicate entries from the data
DELETE FROM healthcare_staging2 WHERE row_num > 1;

-- To check if really the data is removed
SELECT * FROM healthcare_staging2
WHERE LOWER(`Name`) = "abigail young";

-- 2. Standardizing the data

SELECT * FROM healthcare_staging2;
-- To check if any names have extra space at the end
SELECT `Name`
FROM healthcare_staging2
WHERE `Name` LIKE '% ';

SELECT DISTINCT `Name` FROM healthcare_staging2;

-- To check if same kind of entry was inputed or not: Example - Crypto and CryptoCurrecny and all. 

SELECT * FROM healthcare_staging2 WHERE Hospital = 'and Bennett Sons';

SELECT COUNT(DISTINCT Hospital) FROM healthcare_staging2 ORDER BY 1;

SELECT DISTINCT `Insurance Provider` FROM healthcare_staging2;

SELECT DISTINCT `Admission type` FROM healthcare_staging2;
SELECT DISTINCT `Test Results` FROM healthcare_staging2;
SELECT DISTINCT Medication FROM healthcare_staging2; 

-- To drop suffix at the end of the name (But I'm leaving them as it is, just looking at data without suffix)
SELECT DISTINCT `Name`, TRIM(TRAILING 'md' FROM `Name`) FROM healthcare_staging2;

SELECT `Name`
FROM healthcare_staging2
WHERE `Name` LIKE '% md'; -- MD means medical doctor so no need to remove it

-- If we wanna do time series in future date of admission needs to be changed. Because date is now a text column
-- We are changing date column from text to datetime

SELECT `Date of Admission` FROM healthcare_staging2;

SELECT `Date of Admission` , STR_TO_DATE(`Date of Admission`,'%Y-%m-%d')
FROM healthcare_staging2;

SELECT `Discharge Date` FROM healthcare_staging2;

SELECT `Discharge Date`, STR_TO_DATE(`Discharge Date`,"%Y-%m-%d") FROM healthcare_staging2;

UPDATE healthcare_staging2
SET `Discharge Date` = STR_TO_DATE(`Discharge Date`,"%Y-%m-%d");

-- After setting values to datetime we need to alter the column type
ALTER TABLE healthcare_staging2
MODIFY COLUMN `Discharge Date` DATE;

UPDATE healthcare_staging2
SET `Date of Admission` = STR_TO_DATE(`Date of Admission`,'%Y-%m-%d'); -- Now change Date column to datetime

ALTER TABLE healthcare_staging2
MODIFY COLUMN `Date of Admission` DATE;

-- Let's look at Name column, name is not standardized
SELECT * FROM healthcare_staging2;

SELECT `Name` FROM healthcare_staging2;

-- I looked at the data, there will always be a last name so this way is the best
-- To standardize it I used string functions to extract the first letter and convert it to upper and concatenated other letters as lower
SELECT CONCAT(
UPPER(SUBSTRING(`Name`,1,1)), LOWER(SUBSTRING(`Name`,2,LOCATE(' ',`Name`) - 1)),
" ",
UPPER(SUBSTRING(`Name`,LOCATE(' ',`Name`) + 1,1)),
LOWER(SUBSTRING(`Name`, LOCATE(' ',`Name`) + 2))
) 
FROM healthcare_staging2;

UPDATE healthcare_staging2
SET `Name` = CONCAT(
UPPER(SUBSTRING(`Name`,1,1)), LOWER(SUBSTRING(`Name`,2,LOCATE(' ',`Name`) - 1)),
" ",
UPPER(SUBSTRING(`Name`,LOCATE(' ',`Name`) + 1,1)),
LOWER(SUBSTRING(`Name`, LOCATE(' ',`Name`) + 2)));


SELECT DISTINCT `Insurance Provider` FROM healthcare_staging2;
-- Updating other things such as Insurance provider
UPDATE healthcare_staging2
SET `Insurance Provider` = "United Health Care"
WHERE `Insurance Provider` = "UnitedHealthcare";

SELECT DISTINCT Doctor FROM healthcare_staging2 ORDER BY 1;

SELECT ROUND(`Billing Amount`,3) FROM healthcare_staging2;

UPDATE healthcare_staging2
SET `Billing Amount` = ROUND(`Billing Amount`,3);

-- 3. Droping any necessary column
ALTER TABLE healthcare_staging2
DROP COLUMN row_num;

-- 4. Null and Blank values
SELECT * FROM healthcare_staging2 
WHERE `Name` IS NULL OR `Name`="";

SELECT * FROM healthcare_staging2 
WHERE Age IS NULL;

SELECT * FROM healthcare_staging2 
WHERE Gender IS NULL OR Gender = "";

SELECT * FROM healthcare_staging2 
WHERE `Blood Type` IS NULL OR `Blood Type` = "";

SELECT * FROM healthcare_staging2 
WHERE `Medical Condition` IS NULL OR `Medical Condition` = "";

SELECT SUM(ISNULL(`Date of Admission`)) FROM healthcare_staging2;

SELECT * FROM healthcare_staging2 
WHERE `Doctor` IS NULL OR `Doctor` = "";

SELECT * FROM healthcare_staging2 
WHERE `Hospital` IS NULL OR `Hospital` = "";

SELECT * FROM healthcare_staging2 
WHERE `Insurance Provider` IS NULL OR `Insurance Provider` = "";

SELECT * FROM healthcare_staging2 
WHERE `Billing Amount` IS NULL OR `Billing Amount` = "";

SELECT * FROM healthcare_staging2 
WHERE `Room Number` IS NULL;

SELECT * FROM healthcare_staging2 
WHERE `Admission Type` IS NULL OR `Admission Type` = "";

SELECT * FROM healthcare_staging2 
WHERE `Discharge Date` IS NULL;

SELECT * FROM healthcare_staging2 
WHERE `Medication` IS NULL OR `Medication` = "";

SELECT * FROM healthcare_staging2 
WHERE `Test Results` IS NULL OR `Test Results` = "";







