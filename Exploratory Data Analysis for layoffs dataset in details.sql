-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

-- Normally, when you want to start EDA on a particular dataset, you would have an idea of what you are looking for, but only sometimes
-- Also, sometimes when running an exploratory analysis on the data, you might notice some errors that you then have to clean before continuing the analysis
-- So even if a data cleaning has been done, sometimes, it can be a case of exploring and cleaning the data at the same time
-- In this case here, I don't have any ideas or agenda as to what exactly I am looking for
-- We are just going to be exploring the entire data and see what we find
-- We will start off with the basic stuff and then gradually move on to the more advanced stuff

-- We are going to be working with the total_laid_off and the percentage_laid_off
-- Mostly the total_laid_off. The percentage_laid_off is not super helpful because we don't know how large the company is
-- We don't have a column that says here are the total number of employees each company has
-- First, let's look at the maximum total laid off and the maximum percentage laid off

-- EASIER QUERIES
 
SELECT MAX(total_laid_off)
FROM layoffs_staging2;

SELECT MIN(total_laid_off)
FROM layoffs_staging2;

-- So in one day, there was someone (company) out there who had the maximum total_laid_off of 12,000 people (that is, laid off 12,000 people)
-- And the minimum total laid off were just 3 people
-- Also, we can look at the maximum and minimum percentage laid off


SELECT MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT MIN(percentage_laid_off)
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT MIN(total_laid_off), MIN(percentage_laid_off)
FROM layoffs_staging2;

-- And for the maximum percentage laid off, a 100% of the company was laid off
-- You can already tell what the minimum would be (0)
-- Now, let's look at various companies to see their layoffs

SELECT *
FROM layoffs_staging2;


SELECT company, industry
FROM layoffs_staging2
WHERE industry = 'Data';

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

-- It looks like these are mostly startups who all went out of business during this time

-- We can also take a look at the funds raised per millions column to see companies that had a ton of fundings
-- If we order by funds_raised_millions we can see how big some of these companies were

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
;

-- BritishVolt looks like an EV company, Quibi! I recognize that company - wow raised like 2 billion dollars and went under - ouch

-- SOMEWHAT TOUGHER AND MOSTLY USING GROUP BY--------------------------------------------------------------

-- Now, let's go for a group by statement
-- We want to look at companies and the sum of their total laid off through all the years recorded here

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Next, l would like to look at the date ranges real quick
-- We'll look at the maximum and minimum

SELECT MAX(`date`), MIN(`date`)
FROM layoffs_staging2;

-- So it looks like this started in 2020, on the 11th of March right when the COVID-19 started
-- And recorded these layoffs from then up to like three years later in 2023 on the 6th of March
-- So, just in these three years, these data we are looking at, are like records of the layoffs within those periods
-- Yeah. So, we can still look at a few other things like the industry for instance;
-- What industry got hit the most and had the highest layoffs during this time?

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Let's look at the whole table again to see what we've looked at and what else we can look at
-- Let's look at the countries column

SELECT *
FROM layoffs_staging2;


SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- United states had by far the most total layoffs compared to other countries
-- We can look at the date column where we can look at it by year


SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `date`
ORDER BY 1 DESC;

-- This will give a result showing the dates individually and this is not what we want
-- So we can try using the Year function to give us a round total for each of the years

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- You can see the analysis from this result

-- We can also look at the stage column

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- We can try to look at the percentage laid off but I don't think there's much we can get out of it
-- This might really be a god column to look at because percentages refer to a percent of the company
-- We have no idea how large any of these companies are

SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Thus, percentage laid off is not so relevant
-- It is the total laid off that's somewhat relevant

-- In short form;

-- Companies with the biggest single Layoff

SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging
ORDER BY 2 DESC
LIMIT 5;

-- now that's just on a single day

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;



-- By location
SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- this is the total in the past 3 years or in the dataset

-- By country
SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- By date
SELECT YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 ASC;

-- By Industry
SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- By stage
SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;




-- TOUGHER QUERIES--------------- ---------------------------------------------------------------------------------------------------------------------

-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year. It's a little more difficult.
-- Now one thing that I am really interested in is looking at the progression of layoffs
-- You can call this a rolling sum -- so start at the very earliest of layoffs and do a rolling sum until the very last of the layoffs
-- I want to look at a rolling total of layoffs based off the date column according to the Year 
-- We can do this based off the month as well but it won't make much sense. Here,

SELECT *
FROM layoffs_staging2;


-- Rolling Total of Layoffs Per Month

SELECT SUBSTRING(`date`, 6, 2) AS `MONTH`
FROM layoffs_staging2;

-- So this brought out all the month figures from all the years
-- How do we know which month is for what year? This is why just the month alone can't work
-- Now if we group on this and do something like;

SELECT SUBSTRING(`date`, 6, 2) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`;

-- It only shows us the month and the rolling sum
-- So we want to ensure that each month is also attached to their respective years

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


WITH Company_Year AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *
FROM Company_Year;

-- To change the column names...

WITH Company_Year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *
FROM Company_Year;

-- This looks better visually
-- Now, I want to partition these by the years and then rank it by the total laid off in a certain year
-- So in essence, we want to look at which company laid off the most per year
-- The highest in a certain year will be ranked number 1 for that year and then the next, number 2 for that year and so on

WITH Company_Year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC)
FROM Company_Year
WHERE years IS NOT NULL;

-- So from this already, you can see the first to 10th highest. You can choose to filter on what you want to see
-- I can also filter on this to return results for all companies with the highest for each year

WITH Company_Year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC
;

-- Now, I want to really filter on this to return results for just about the top 5 companies
-- What we can do is to add in another cte for this into the already existing cte. Like this...


WITH Company_Year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

-- This is really interesting to look at
-- Looking at a year by year snapshot of total laid offs for different companies or industries or whatever you wish to change it to


