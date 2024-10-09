-- Data Cleaning

SELECT *
FROM layoffs;

-- 1. Remove Duplicates (if there are any)
-- 2. Standardize the Data: This just means correcting misspellings or any issues that aren't meant to be present in the data, to give the data a uniform look
-- 3. Take out Null Values or Blank Values (if necessary, because there are cases where you shouldn't erase)   
-- 4. Remove Any Columns and Rows that are not necessary (there are instances that you shouldn't)

CREATE TABLE layoffs_staging
LIKE layoffs;  

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM lay_offs;

SELECT *
FROM layoffs_staging;


SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;


WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Oda';


 WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


SELECT *
FROM layoffs_staging2;


SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;

SELECT *
FROM layoffs_staging2;


-- 2. Standardizing data

SELECT DISTINCT (company)
FROM layoffs_staging2;

SELECT DISTINCT (TRIM(company))
FROM layoffs_staging2; 

SELECT company, TRIM(company)
FROM layoffs_staging2; 

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT company, TRIM(company)
FROM layoffs_staging2;


SELECT industry
FROM layoffs_staging2; 

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

   
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';


UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';


SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;


SELECT *
FROM layoffs_staging2;


SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1; 


SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;


SELECT DISTINCT country, TRIM(country)
FROM layoffs_staging2
ORDER BY 1;


SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;


UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%' ; 


SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;


SELECT *
FROM layoffs_staging2;


SELECT `date`
FROM layoffs_staging2;


SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y') ;

  
SELECT `date`
FROM layoffs_staging2; 


ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


SELECT *
FROM layoffs_staging2;


-- 3. Take out Null Values or Blank Values (if necessary, because there are cases where you shouldn't erase)

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;



SELECT DISTINCT industry
FROM layoffs_staging2;



UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';



SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';



SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;



SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;



UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';



SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';



-- Let's look at our table again
SELECT *
FROM layoffs_staging2;


 

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;



-- Delete Useless data we can't really use


DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Let's see our table again

SELECT *
FROM layoffs_staging2;

-- Take out the row_num column as well. We don't need it anymore


ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Run this and then run the table again, and that should be gone

SELECT * 
FROM layoffs_staging2;
