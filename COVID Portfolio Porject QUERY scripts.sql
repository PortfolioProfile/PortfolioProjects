--CONTINENT is Null i.e. Continents not countries
select Location,continent, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Canada'
WHERE continent is null
order by 1,2

--CONTINENT is NOT null i.e. Specific countries
select Location,continent, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Canada'
WHERE continent is not null
order by 1,2



--Likelihood of dying from Covid in UK
select Location, date, total_cases, total_deaths, (CONVERT(FLOAT, ISNULL(total_deaths, 0)) / NULLIF(CONVERT(FLOAT, total_cases), 0)*100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
and location like '%Kingdom%'
order by 1,2


--Total cases vs Population
--% of UK Population having Covid
SELECT location, date,population, total_cases, (total_cases/population)*100  AS PercentagePerCases
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
and location like '%Kingdom'
order by 1,2


--Country with highest infection rate vs population
SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100  AS PercentageOfInfections
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kingdom'
WHERE continent is not null
GROUP BY Location, population
order by PercentageOfInfections desc

--Country with highest deaths vs population
SELECT location, MAX(cast( total_deaths as int)) AS TotalLocationDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kingdom'
WHERE continent is not null
GROUP BY Location
order by TotalLocationDeathCount desc


--Countinent with highest deaths vs population
SELECT location, MAX(cast( total_deaths as int)) AS TotalContinentDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kingdom'
WHERE continent is null
AND location NOT IN ('High income', 'Upper middle income', 'Lower middle income', 'European Union', 'Low income')
GROUP BY location
order by TotalContinentDeathCount desc


--GLOBAL New cases of covid per day
SELECT 
SUM(new_cases) AS TotalCases,
SUM(new_deaths) AS TotalDeaths,
COALESCE(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0), 0) AS NewCasesPerDay
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
order by 1,2


--TOTAL Population vs Vaccination
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS TotalPeopleVaccinatedDaily
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVacinations CV
ON CD.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null
order by 2,3


--CTE Version
WITH PopulationVSVaccination (Continent,location,date,population, new_vaccinations, TotalPeopleVaccinatedDaily)
AS
(SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS TotalPeopleVaccinatedDaily
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVacinations CV
ON CD.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null
)
SELECT *, (TotalPeopleVaccinatedDaily/population)* 100 AS PercentageVaccinated
FROM PopulationVSVaccination


--TEMP TABLE Version
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalPeopleVaccinatedDaily numeric)

INSERT INTO #PercentPopulationVaccinated

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS TotalPeopleVaccinatedDaily
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVacinations CV
ON CD.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null

--Percentage of People populated rolling daily
SELECT *, (TotalPeopleVaccinatedDaily/population)* 100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated


