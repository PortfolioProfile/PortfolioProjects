--CREATE VIEWS FOR VISUALIZATION

CREATE VIEW UKDeathPercentage as
--Likelihood of dying from Covid in UK
select Location, date, total_cases, total_deaths, (CONVERT(FLOAT, ISNULL(total_deaths, 0)) / NULLIF(CONVERT(FLOAT, total_cases), 0)*100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
and location like '%Kingdom%'


