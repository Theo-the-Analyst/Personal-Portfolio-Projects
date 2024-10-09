-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022


-- Data Cleaning is a process whereby data is cleaned up to get it into a more usable format
-- Where you fix a lot of issues that be present in the raw data so that when you start creating visualizations and start using it in your products, that the data is actually useful and there are not a lot of issues with it
-- First of all, I will create a database, then import a dataset, then I am going to clean the data
-- There are various steps I am going to take in order to clean this data
-- Create New Database: Go up to the left-hand corner and click on 'create a new schema in the connected server'
-- A tab opens up. Here, you have to name the database. In this case, I am going to name this database 'world_layoffs'
-- So, you can already tell that I am working with a layoffs dataset
-- Next, click 'Apply'. It takes you to another tab session. Click 'Apply' again. It takes you to another tab session. Click 'Finish' and that creates our world_layoffs database
-- You can see this at the left-hand side under Schemas
-- When you select the new database just created, you will notice there are no tables in it yet
-- Now, this is where the dataset comes in
-- Right-click on 'Tables' and select 'Table Data import wizard'
-- A window tab displays where you can select the file you want to import via clicking on 'Browse'
-- Select the layoffs dataset saved on your computer and then click 'Next'
-- Next thing is to select destination. I can see that the name I gave the database is there already. I can also check the box that says 'Drop table if exists' just in case. Then click 'Next'
-- Next is to configure import settings. This is where the data shows up and categorised with their respective data types
-- Now, MySQL automatically assigns the data type based off of the data in this columns. This, we would take a look at later
-- Now, there is one thing to notice here though. There is a date column in this dataset and if you look at the data type, you will notice it's classified as a text because of the format it is in, in the dataset
-- But, we're oing to import this as the raw data, and not change anything in the import settings because we are assuming this is how it came with the data.
-- Although, this is something you might want to a data type like datetime but we'll just import this as the raw data for now
-- Go ahead and click 'Next'. It comes to the import data tab, click 'Next'. It starts importing. This might take a while.
-- When it finishes, click 'Next'. The import results will show up, then click 'Finish'. And that's it!
-- You can get rid of the space you used to create the new database if you want.
-- Refresh the Schemas, and you can see that the dataset has been successfully added
-- Double-click on world_layoffs to keep it selected so you don't have to keep calling it in your query each time.
-- To display the table or dataset;

SELECT *
FROM layoffs;

-- So, let's take a proper look at this data we're going to be working with...
-- This dataset is layoffs from around the world starting from 2022-2023
-- It has the different companies that did the layoffs, the location of where they are, what industries they are part of, how many in total were laid off, the percentage they laid off, the date, the stage which refers to the stage the company's in (whether it's a Series B, Unknown, Post-IPO, etc,.), the countries, and then the funds raised in millions
-- So, there is a lot of information in this data
-- And after cleaning, in the next project, we are going to do an exploratory analysis on the cleaned data and try to find trends, patterns, and the likes
-- In order to clean this data, we are going to go through multiple steps;

-- 1. Remove Duplicates (if there are any)
-- 2. Standardize the Data: This just means correcting misspellings or any issues that aren't meant to be present in the data, to give the data a uniform look
-- 3. Take out Null Values or Blank Values (if necessary, because there are cases where you shouldn't erase)   
-- 4. Remove Any Columns and Rows that are not necessary (there are instances that you shouldn't)

-- Now, in the real workplace, often times, you have processes that automatically import data from different data sources. If you remove a column from the raw dataset, that's a huge problem
-- So, what I am going to do, which is something I'd actually do in my real work, is that I am going to create some type of staging table of the raw data where my workings can be done
-- So, in essence, I am going to create another table;

CREATE TABLE layoffs_staging;
-- And I literally just want to copy all the data from the raw dataset and paste it into the new table I'm about to create

CREATE TABLE layoffs_staging
LIKE layoffs;

-- You run this above, and then refresh the schemas to see the table that has just been created, added there
-- Then;

SELECT *
FROM layoffs_staging; 

-- So now, you have all of the columns added to the staging table.
-- All you have to do now is insertthe data into it 

INSERT layoffs_staging
SELECT *
FROM lay_offs;

-- Run this above and then run the staging table again;

SELECT *
FROM layoffs_staging; 

-- The data has been added successfully
-- So now, we have these two different tables. And why did we do this?
-- It is because we are about to change a whole lot in the staging dataset a lot
-- If you make a mistake, you want to make sure you have the raw dataset available and intact without any change
-- And this commonly happens
-- So, you shouldn't work on the raw dataset, it isn't best practice at all
-- In essence, we created the staging table to be able to work on this data and change things, instead of working on the raw dataset itself

-- Now, we start with the steps
-- First thing you want to do is to ensure that all duplicates are removed
-- So make sure there are no duplicates in the data, and if so, to get rid of it
-- In SSMS, something similar was done but in that server, there was an extra column before the beginning of the data that gave a unique id number for each row which made it so easy to remove duplicates
-- But here, there is no identifying factor that is going to be easy for that
-- Therefore, removing duplicates here on MySQL is not gonna be easy but we'll work through that every step of the way
-- So what we can do is something like a row number and we'll match it against all of the columns here and then we can see if there are any duplicates
 

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

-- Call the staging table, and what we can do is a row number and do partition by every single one of the columns  
-- We can try the partition for some of them first to see if it works
-- Now, date is being done with a back tick (``) because date is a keyword in MySQL
-- Run the partition by and see if it works
-- Now, the row number has been added and these mostly are unique values, but we want to be able to filter on this
-- So, we can filter on when the row number is greater than 2
-- If it has 2 and above, it means there's an issue. It means there's a duplicate  
-- So what we can do is to take the previous query, and put it in a Subquery or CTE
-- I will go with a CTE for this

WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- If you run this, you can see that the returned results are the duplicates in the table because all of the data here has a row number greater than 1.
-- But, you might want to crosscheck that and be sure they are the duplicates
-- Start by picking one to three of them and check through individually
-- Take Oda for instance;

SELECT *
FROM layoffs_staging
WHERE company = 'Oda';

-- Running this, I noticed that the data said to be duplicates with Oda are not actually duplicates. 
-- So, it is wonderful that I checked
-- So, since it's this way, I think it's wise to do the partition by over every single column
-- It is good or okay to make mistakes and figure out things as you work
 
WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- If you notice, Oda is no longer there. So, I was right about checking it and confirming that Oda wasn't a duplicate 
-- A duplicate has to be the same all through a particular row under their respective columns
-- I still want to check to be sure that I am now on track with the duplicates
-- Let's check Casper

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- When I run this, I could see that there are three results, and just two are duplicates. The last one is not a duplicate.
-- So I would have to make sure I remove just the duplicates
-- So we run the duplicate cte again to see the duplicates, and now, the previous partition by query appears to be working perfectly
-- Now, I need to identify these exact rows that are the duplicates
-- Of course, I wouldn't want to delete both of them from the table cos that would be bad
-- When we looked at Casper, we noticed that there is one we want to keep and one we want to take out
-- To do things like removing a duplicate, can be a lil bit tricky in MySQL than it is in Microsoft Sql Server
-- In Microsoft Sql Server for instance, you can just call in the numbers representing the duplicates in the CTE created, and then delete them
-- Like this;

WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

-- But, if you run this on MySQL, it gives an error 'The target table duplicate_cte of the DELETE is not updatable'
-- In essence, you can't update a CTE. In this case, the DELETE is an update statement
-- So what we are going to do is take the duplicate_cte, probably put it into a staging2 database and then we can delete it because we can filter on the row_num and delete those which are equal to 2
-- So, it is essentially like creating some type of table, and then deleting the actual columns
-- Simply put, creating out a table that has this extra rows, and then deleting it where the rows are equal
-- Now, we will create the table for this purpose. I can simply do this by 
-- 1. going to tables under world_layoffs
-- 2. Right-click on layoffs_staging, and click Copy to clipboard
-- 3. Then select create statement
-- 4. Ctrl + V to paste it here
-- So what we are going to do is to edit the name of the table to layoffs_staging2
-- You can see that this is a create table statement having all columns and their assigned data types
-- Although, we want to add another column to this query (row_num = INT)


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
        
-- Run this, and this works perfectly
-- Call the table

SELECT *
FROM layoffs_staging2;

-- This table has been successfully created with the different column headings
-- Now, to insert values into this table;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- This worked. Now, call the table;

SELECT *
FROM layoffs_staging2;

-- I basically added the entire columns into a new table but added row_number
-- So now, we can filter off that;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;

-- And there we go, our duplicates displayed again
-- I recommend writing the select statement just so you see what you want to delete first
-- Now to delete this, all we have to just write is;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- This worked. That's if you don't have safe updates on

SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;

-- And here, you can see that everything has been deleted
-- If we call the whole table now;

SELECT *
FROM layoffs_staging2;

-- And this looks much better
-- Now, the row_num is a column we probably won't need eventually
-- At the end, we would remove all the unnecessary columns


-- 2. Standardizing data

-- This means finding issues in your data and then fixing it
-- So, if you notice in this data, there are some visible spaces at the beginning of some of those company names i am already seeing
-- We can easily do a Trim on them
-- You can easily view the error for a particular column by running a Distinct staement

SELECT DISTINCT (company)
FROM layoffs_staging2;

-- You will see the result
-- Then, we can run a Trim

SELECT DISTINCT (TRIM(company))
FROM layoffs_staging2; 

SELECT company, TRIM(company)
FROM layoffs_staging2; 

-- Here, you get to see the before and after columns of standardizing the company column
-- So next is to update the table
-- Remember, for you to be able to update or delete, you need to have the safe updates box on MySQL unchecked
-- Go to Edit >> Preference >> SQL Editor >> go to the bottom >> ensure safe updates box is unchecked >> restart MySQL (if needed)

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Recall that Trim takes away the white spaces off the right hand side or off the left hand side as well
-- This shows it has been updated successfully
-- Run;

SELECT company, TRIM(company)
FROM layoffs_staging2; 

-- And great!
-- Next thing I want to look at is the Industry

SELECT DISTINCT industry
FROM layoffs_staging2;

-- If you run this, you will notice there are tons of different industries present
-- We are doing Distinct just so it can return unique names and not multiple of the same name
-- You can also order by 1 to view them alphaetically or in an orderly manner

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;
-- There is a Null and a blank which is not proper, but we will take a look at that later
-- Moving forward, when you look at the industries 'crypto', 'cryptocurrency', 'cryptocurrency', these are probably supposed to be under one category because they are supposedly the same thing
-- Why this change is necessary is because when we start doing the exploratory data analysis, when visualizing it, these would all be on their own rows and unique, which we don't want
-- What we want is for them to be all grouped together, so we can accurately look at the data 
-- We move forward to looking at the others to see if there are any more corrections to make
   
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- When we run this, we notice that about 95% of them are termed Crypto
-- Only a few are termed CryptoCurrency. So it is good we change all of them to be Crypto
-- So what we can do is;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
-- And this worked
-- To check;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';
-- As we scroll through, you'll notice they have been changed all to the same thing

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- It has been updated. Looking more wonderful now
-- Now, let's look at the whole table

SELECT *
FROM layoffs_staging2;

-- We have looked at company and industry. Let's take a look at location.
-- It is advisable to look at most of these columms because there could be tiny issues that you can't see until you actually check them out individually
-- Let's look at it in an orderly manner to see if there's a problem anywhere

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1; 
-- Here looks good
-- Let's look at another column, country

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;
-- We found one issue here where there were United States twice but someone put a period after one of them
-- We need to fix this
-- They are all meant to be United States and United States.
-- So;

SELECT DISTINCT country, TRIM(country)
FROM layoffs_staging2
ORDER BY 1;

-- Now, just doing the TRIM won't fix it but here is whaat you can do is something called Trailing which means coming at the end
-- So what's trailing? The period from country

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

-- And yeah, that fixed it!
-- Now, we can update this by;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%' ; 

-- To check;
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;
-- And yeah, we have gotten what we wanted

SELECT *
FROM layoffs_staging2;

-- If we are trying to do time series, exploratory data analysis, visualizations later on, the date column needs to be changed
-- Currently, it is in a text data format. This is not good if we are trying to do time series and all that 
-- We might want to change it to a date data format. And how can we change this?
-- First, let's look at the date

SELECT `date`
FROM layoffs_staging2;
-- Now, let's change this to the format that we want which is month, day, year
-- And how can we do this?
-- With something very useful that works perfectly for this which is the Strint-to-date key
-- STR_TO_DATE literally helps us go from a string which is a text format to a date format
-- All we need to do now is to place through two parameters which is the date column and the format in which we want the date to be in
-- In order to format this properly, you have to use a percent sign

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- If you notice, the month and day are represented with lower cases as their upper cases mean a different thing, while the year is represented with an upper case
-- What we are doing here is formatting it into the way that we want it but at the same time converting it to an actual date column or format
-- So, when we run this above, it worked. It is taking in the format that it was in, and converting it into the date format that you find in MySQL
-- So we can update the date column now

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y') ;
-- And it looks like it worked
-- Then check;
  
SELECT `date`
FROM layoffs_staging2; 

-- There are some Nulls present which we would at later
-- We can refresh the schema and check if the data type has been changed
-- No, it didn't. It is still written as a text format but on our table, it is in a date format
-- Now it is really important to know that trying to convert it ro a date format won't work. It will give an error
-- But what we can do is that we can change it to a date column by altering the table. This should never be done on the raw data, very important


ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Run this and see if it works
-- Then go and refresh the schema
-- And yeah, you will notice it has been changed to a date format which is perfect

SELECT *
FROM layoffs_staging2;


-- 3. Take out Null Values or Blank Values (if necessary, because there are cases where you shouldn't erase)

-- Normally, in a dataset, you are going to have Null values and blank spaces
-- So we would have to think about what we'd do with those. Whether we are going to make it all Nulls, blanks, or populate the data
-- The null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- So there isn't anything I want to change with the null values


-- 4. Remove Any Columns and Rows that are not necessary (there are instances that you shouldn't)

-- So, let's see how we can go about this. We will start off with the total_laid_off
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- This shows result for all total laid off that are Null and all percentage laid offs that are NULL as well
-- Now, these Null values from both columns might actually be fairly useless
-- Before that though, I remember that in industry, there were some missing values and I want us to take a look at that

SELECT DISTINCT industry
FROM layoffs_staging2;
-- It has a Null and a blank
-- `Let's see the entire data where industry IS NULL and blank
-- You can decide to change all blank spaces to be NULL first


UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- You can see there are about 4 items
-- What we might want to do is to see if any of these have one that is populated
-- Let's take a look at Airbnb for example

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- From the result, it looks like we have one that's populated
-- So, for example, all the 4 items, whether they have them or not, we are going to try to populate them
-- If the other three had multiple layoffs, the blank spaces should be populated with the information from the ones that they have that are not blank  
-- For example, if we look at Airbnb, one of the results has the Travel industry. So we can populate the blank one with Travel
-- We want this data to be same because if we are trying to look at what industries were impacted the most, the one with the blank space won't be in our output because it is blank
-- So we want to update it to be travel as well to be able to represent the data properly
-- What we can do is to try to do a JOIN
-- We will try running it in a Select statement and then change it to an Update statement if it works



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

-- So here, you can see where each of the industries are having blank values and where there are no blank values as well
-- What this is going to do is look for the same companies where it has a blank value as well as a non-blank value
-- And if so, update the blank value with the non-blank value
-- Now let's write the Update statement


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

-- And this worked perfectly
-- It looks like just Bally's still has a Null value. Let's look at that quickly

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';
-- Okay. There's only one row. There wasn't another row with a non-null value like the others


-- Let's look at our table again
SELECT *
FROM layoffs_staging2;

-- So I think the cleaning and populating of Null values is done because we can't be able to populate things like total laid off, percentage laid off and funds per million
-- Now for the other rows and columns that are not necessary..
-- What we are trying to do with this data in the future is not only to look at companies and locations that had layoffs but 
 

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- I don't think that these Null values under total and parcentage laid off are useful because they can't be populated
-- So we can just get rid of them
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

-- And this is it!
-- Our finalised clean data
-- In the next project, we are going to be doing an exploratory data analysis on this cleaned data
-- We are going to be finding trends and patterns, running complex queries, etc
-- Cleaning data is never a straightforward one
-- You might make mistakes or have to figure out some new stuff yourself   