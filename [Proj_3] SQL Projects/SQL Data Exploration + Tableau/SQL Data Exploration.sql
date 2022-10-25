-- Checking if the database is loaded correctly
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4
-- ORDER BY 1,2,3,4 means your query orders by the the ordinal numbers of the columns. 
-- It is not recommended in practice, thus specifying the column names is better.

-- Selecting relevant columns to look at
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at the total cases vs total deaths ('fatality rate')
-- This shows the likelihood of dying when you contract COVID in your country.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS fatility_rate
FROM PortfolioProject..CovidDeaths
WHERE location like 'malaysia'
ORDER BY 1,2

-- Looking at the total cases vs the population
-- This shows the proportion of the population that contracted COVID over the reported period.
SELECT location, date, total_cases, population, (total_cases/population)*100 AS percent_cases
FROM PortfolioProject..CovidDeaths
WHERE location like 'malaysia'
ORDER BY 1,2

-- Looking at countries with the highest Infection Rate compared to the population
SELECT location, MAX(total_cases) AS infection_count, population, MAX((total_cases/population))*100 AS percent_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY percent_infected DESC

-- Looking at countries with highest death count per population
-- Using CAST() because the data didnt't cumulate to total
SELECT location, MAX(CAST(total_deaths AS int)) AS death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_count DESC

-- Looking at the breakdowns of COVID by continents
SELECT location, MAX(CAST(total_deaths AS int)) AS death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY death_count DESC

-- Looking at the global numbers for COVID-related deaths
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS fatility_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

-- Looking at the global numbers for COVID-related deaths (grouped by date)
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS fatility_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total population vs Vacinations
-- Shows percentage of population that has received COVID vaccine at least once
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

-- Using common table expressions (CTE) to perform calculation on PARTITION BY in previous query
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
