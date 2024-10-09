-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

-- EASIER QUERIES
 
SELECT MAX(total_laid_off)
FROM layoffs_staging2;

SELECT MIN(total_laid_off)
FROM layoffs_staging2;


SELECT MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT MIN(percentage_laid_off)
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT MIN(total_laid_off), MIN(percentage_laid_off)
FROM layoffs_staging2;



SELECT *
FROM layoffs_staging2;

-- To see companies where there was a 100% laid off 

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY 3;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC
;


SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
;

-- SOMEWHAT TOUGHER AND MOSTLY USING GROUP BY--------------------------------------------------------------

-- Now, let's go for a group by statement
-- We want to look at companies and the sum of their total laid off through all the years recorded here

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT MAX(`date`), MIN(`date`)
FROM layoffs_staging2;



SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Let's look at the whole table again

SELECT *
FROM layoffs_staging2;


SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `date`
ORDER BY 1 DESC;


SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;



SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 1 DESC;


SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- TOUGHER QUERIES--------------- -------------------------------------------------------------------------------------

-- Rolling Total of Layoffs

SELECT *
FROM layoffs_staging2;


SELECT SUBSTRING(`date`, 6,2) AS `MONTH`
FROM layoffs_staging2;

SELECT SUBSTRING(`date`, 6,2) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`;



SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`;



SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;



WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;



WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total; 




SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;



SELECT company, `date`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, `date`;



SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC; 



SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC; 



WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *
FROM Company_Year;



WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC)
FROM Company_Year;

-- Take out the NULL values

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking_List
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking_List;




WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking_List
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking_List <= 5
;
