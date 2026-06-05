LOAD DATA LOCAL INFILE '/Users/DELL/Desktop/Projects/PortfolioProjects/CovidVaccinations.csv' INTO TABLE covid_vaccinations
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

/*
ALTER TABLE covid_vaccinations
MODIFY COLUMN date DATETIME,
MODIFY COLUMN new_vaccinations INT DEFAULT NULL,
MODIFY COLUMN total_vaccinations INT DEFAULT NULL;
*/

SELECT 
	d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_total_vaccinations
FROM covid_deaths d
JOIN covid_vaccinations v
USING (location, date)
WHERE d.continent != ""
ORDER BY d.location, d.date;

-- Total Population vs Vaccinations (CTE)
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_total_vaccinations)
AS
(
SELECT 
	d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_total_vaccinations
FROM covid_deaths d
JOIN covid_vaccinations v
USING (location, date)
WHERE d.continent != ""
)
SELECT
	*,
    (rolling_total_vaccinations/population) * 100 AS vaccination_rate
FROM pop_vs_vac;

-- TEMP TABLE
DROP TABLE IF EXISTS vaccination_rate;
CREATE TEMPORARY TABLE vaccination_rate
(
	continent TEXT,
    location TEXT,
    date DATETIME,
    population INT DEFAULT NULL,
    new_vaccinations INT DEFAULT NULL,
    rolling_total_vaccinations INT DEFAULT NULL
);
INSERT INTO vaccination_rate
SELECT 
	d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_total_vaccinations
FROM covid_deaths d
JOIN covid_vaccinations v
USING (location, date)
WHERE d.continent != ""
ORDER BY d.location, d.date;

SELECT
	*,
    (rolling_total_vaccinations/population) * 100 AS vaccination_rate
FROM vaccination_rate;


-- VIEWS FOR LATER VISUALISATIONS

-- Vaccination Rate
CREATE OR REPLACE VIEW v_vaccination_rate AS
SELECT 
	d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_total_vaccinations
FROM covid_deaths d
JOIN covid_vaccinations v
USING (location, date)
WHERE d.continent != "";

SELECT 
    *
FROM
    v_vaccination_rate;


