-- Queries used for Tableau Project 

-- 1.
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--2.
SELECT location, SUM(CAST(new_deaths as int)) AS totaldeathcount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY totaldeathcount DESC

--3.
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_pop_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY percent_pop_infected DESC

--4
SELECT location, population, date, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_pop_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY percent_pop_infected DESC