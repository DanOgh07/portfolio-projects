LOAD DATA LOCAL INFILE '/Users/DELL/Desktop/Projects/PortfolioProjects/CovidDeaths.csv' INTO TABLE covid_deaths
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

/*
ALTER TABLE covid_deaths
MODIFY COLUMN date DATETIME,
MODIFY COLUMN new_deaths INT DEFAULT NULL,
MODIFY COLUMN total_deaths INT DEFAULT NULL;
*/

-- COUNTRIES
SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covid_deaths
ORDER BY location, date;

-- Total Cases vs Total Deaths
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS infec_death_rate
FROM
    covid_deaths
WHERE
    location = 'Nigeria'
        AND continent != ""
ORDER BY location , date;

-- Total Cases vs Population
SELECT 
    location,
    date,
    population
    total_cases,
    (total_cases/population) * 100 AS infection_rate
FROM
    covid_deaths
WHERE
	location = "Nigeria"
		AND continent != ""
ORDER BY location, date;

-- Countries with the Highest Infection Rate on a Particular Day
SELECT 
    location,
    population,
    MAX(total_cases) AS max_infection_count,
    MAX((total_cases/population)) * 100 AS infection_rate
FROM
    covid_deaths
GROUP BY location, population
ORDER BY infection_rate DESC;

-- Countries with the Highest Death Count
SELECT 
    location,
    MAX(total_deaths) AS total_death_count
FROM
    covid_deaths
WHERE continent != ""
GROUP BY location
ORDER BY total_death_count DESC;


-- CONTINENTS
SELECT 
	location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covid_deaths
WHERE continent = ""
ORDER BY location, date;

-- Total Cases vs Total Deaths
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS infec_death_rate
FROM
    covid_deaths
WHERE
    location = 'Africa'
        AND continent = ""
ORDER BY location, date;

-- Total Cases vs Population
SELECT 
    location,
    date,
    population
    total_cases,
    (total_cases/population) * 100 AS infection_rate
FROM
    covid_deaths
WHERE
	location = "Africa"
		AND continent = ""
ORDER BY location, date;

-- Continents with the Highest Infection Rate Recorded on a Particular Day
SELECT 
    location,
    population,
    MAX(total_cases) AS max_infection_count,
    MAX((total_cases / population)) * 100 AS infection_rate
FROM
    covid_deaths
WHERE
    continent = ""
GROUP BY location, population
ORDER BY infection_rate DESC;

-- Continents with the Highest Death Count
SELECT 
    location,
    MAX(total_deaths) AS total_death_count
FROM
    covid_deaths
WHERE continent = ""
GROUP BY location
ORDER BY total_death_count DESC;

-- WORLDWIDE
-- Cases and Deaths Daily
SELECT 
    date,
    SUM(new_cases) AS cases_today,
    SUM(new_deaths) AS deaths_today,
    (SUM(new_deaths)/SUM(new_cases)) * 100 AS case_to_death_ratio
FROM
    covid_deaths
WHERE continent != ""
GROUP BY date
ORDER BY case_to_death_ratio DESC;

-- Total Cases and Deaths Worldwide
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    (SUM(new_deaths)/SUM(new_cases)) * 100 AS case_to_death_ratio
FROM
    covid_deaths
WHERE continent != ""
ORDER BY case_to_death_ratio DESC;

-- VIEWS FOR LATER VISUALISATIONS

-- Continent Death Count
CREATE OR REPLACE VIEW v_death_count AS
SELECT 
    location,
    MAX(total_deaths) AS total_death_count
FROM
    covid_deaths
WHERE continent = ""
GROUP BY location;

SELECT
	*
FROM v_death_count;

-- Death Ratio Worldwide
CREATE OR REPLACE VIEW v_death_rate AS
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    (SUM(new_deaths)/SUM(new_cases)) * 100 AS case_to_death_ratio
FROM
    covid_deaths
WHERE continent != "";

SELECT
	*
FROM v_death_rate;






