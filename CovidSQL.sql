SELECT *
FROM coviddeaths
ORDER BY 3,4;

SELECT *
FROM covidvaccination
ORDER BY 3,4;

--Select Data that we are going to use--

SELECT c_location, c_date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,2;

-- Viewing Total Cases vs Total Deaths Percentage --
-- Shows likelihood of dying if contracted Covid 19 by Country --

SELECT c_location, c_date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE c_location LIKE 'United States'
ORDER BY 1,2;


-- Viewing Total Cases vs Population --
--Shows what percentage of the population has contract Covid 19 --

SELECT c_location, c_date, population, total_cases, (total_cases/population)*100 as ContractedPercentage
FROM coviddeaths
WHERE c_location LIKE 'United States'
ORDER BY 1,2;


-- Looking at Countries with Highest Infection Rate compared to Population --

SELECT c_location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentOfPopulationInfected
FROM coviddeaths
--WHERE c_location LIKE 'United States'
GROUP BY c_location, population
ORDER BY PercentOfPopulationInfected desc


-- Showing Countries with Highest Death Count per Population -- 

SELECT c_location, MAX(Total_deaths) as TotalDeathCount
FROM coviddeaths
--WHERE c_location LIKE 'United States'
WHERE continent is not null
GROUP BY c_location
ORDER BY TotalDeathCount desc


-- BREAK THINGS DOWN BY CONTINENT -- 
-- Showing the continent with Highest Death Count per Population --

SELECT continent, MAX(Total_deaths) as TotalDeathCount
FROM coviddeaths
--WHERE c_location LIKE 'United States'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

SELECT c_location, MAX(Total_deaths) as TotalDeathCount
FROM coviddeaths
--WHERE c_location LIKE 'United States'
WHERE continent is null
GROUP BY c_location
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS --

SELECT c_date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
--WHERE c_location LIKE 'United States'
WHERE continent is not null
GROUP BY c_date
ORDER BY 1,2

-- TOTAL GLOBAL NUMBERS --

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
--WHERE c_location LIKE 'United States'
WHERE continent is not null
--GROUP BY c_date
ORDER BY 1,2

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS --

SELECT dea.continent, dea.c_location, dea.c_date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.c_location ORDER BY dea.c_location, dea.c_date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccination vac
	ON dea.c_location = vac.c_location
	AND dea.c_date = vac.c_date
WHERE dea.continent is not null
ORDER BY 2,3

-- USING COMMON TABLE EXPRESSION "CTE" --

WITH PopVsVac (continent, c_location, c_date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.c_location, dea.c_date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.c_location ORDER BY dea.c_location, dea.c_date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccination vac
	ON dea.c_location = vac.c_location
	AND dea.c_date = vac.c_date
WHERE dea.continent is not null
ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac


-- TEMP TABLE --

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
continent varchar(255),
c_location varchar(255),
c_date date,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.c_location, dea.c_date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.c_location ORDER BY dea.c_location, dea.c_date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccination vac
	ON dea.c_location = vac.c_location
	AND dea.c_date = vac.c_date
WHERE dea.continent is not null
--ORDER BY 2,3
;
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageOfPeopleVaccinated
FROM PercentPopulationVaccinated


