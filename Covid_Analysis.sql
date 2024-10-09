Use portfolio_project;

---------------------- Data Cleaning ----------------

select count(*) from coviddeaths limit 10;

select distinct continent from coviddeaths;

SELECT * FROM coviddeaths
WHERE continent is not null;
-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY Location, date;

UPDATE coviddeaths
SET continent = NULL
WHERE total_deaths = '';

UPDATE coviddeaths
SET total_deaths = NULL
WHERE total_deaths = '';


---------------------- Analysis ----------------

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in each conutry

SELECT Location, date, total_cases, total_deaths, CONCAT(ROUND(total_deaths / total_cases * 100, 2), '%') as death_percentage
FROM coviddeaths
where location = 'India'
ORDER BY Location, year(date);

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, population, total_cases, CONCAT(ROUND(total_cases / population * 100, 2), '%') as population_percentage
FROM coviddeaths
-- where location = 'India'
ORDER BY Location, year(date);

-- Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as highest_infection_count, CONCAT(ROUND(MAX(total_cases / population) * 100, 2), '%') as population_infected_percentage
FROM coviddeaths
-- where location = 'India'
GROUP BY Location, population
ORDER BY population_infected_percentage DESC;

-- Showing countries with the highest death count per population

SELECT Location, MAX(CAST(total_deaths AS SIGNED)) as highest_death_count
FROM coviddeaths
-- WHERE continent is not null
GROUP BY Location
ORDER BY highest_death_count DESC;

-- Lets break things down by continent
-- Showing continent with the highest death counts

SELECT continent, MAX(CAST(total_deaths AS SIGNED)) as highest_death_count
FROM coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY highest_death_count DESC;

SELECT continent, location, MAX(CAST(total_deaths AS SIGNED)) as highest_death_count
FROM coviddeaths
WHERE continent is not null
GROUP BY continent, location
ORDER BY continent, location, highest_death_count DESC;

-- Global numbers

SELECT date, total_cases, total_deaths, CONCAT(ROUND(total_deaths / total_cases * 100, 2), '%') as death_percentage
FROM coviddeaths
-- where location = 'India'
GROUP BY date
ORDER BY year(date);

SELECT date, SUM(new_cases) as total_new_cases, SUM(CAST(new_deaths AS SIGNED)) as total_new_deaths, CONCAT(ROUND(SUM(new_deaths) / SUM(CAST(new_cases AS SIGNED)) * 100, 2), '%') as death_percentage
FROM coviddeaths
-- where location = 'India'
GROUP BY date
ORDER BY year(date), total_new_cases;

SELECT SUM(new_cases) as total_new_cases, SUM(CAST(new_deaths AS SIGNED)) as total_new_deaths, CONCAT(ROUND(SUM(new_deaths) / SUM(CAST(new_cases AS SIGNED)) * 100, 2), '%') as death_percentage
FROM coviddeaths
-- GROUP BY date
ORDER BY year(date), total_new_cases;

-- Joining Covid deaths and Covid Vaccinations
-- Looking at total population vd vaccinations

SELECT * FROM covidvaccinations LIMIT 10;
SELECT * FROM coviddeaths LIMIT 10;

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS SIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS running_total_vaccinations
FROM coviddeaths cd
JOIN covidvaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY cd.location, cd.date;

-- Use CTE

WITH PopvsVac
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS SIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS running_total_vaccinations
FROM coviddeaths cd
JOIN covidvaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
-- ORDER BY cd.location, cd.date
)

SELECT * FROM PopvsVac;

-- Store in a view

CREATE VIEW percent_population_vaccinated 
AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS SIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS running_total_vaccinations
FROM coviddeaths cd
JOIN covidvaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;
-- ORDER BY cd.location, cd.date

SELECT * FROM percent_population_vaccinated




