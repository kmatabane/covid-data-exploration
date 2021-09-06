SELECT *
FROM CovidDeaths
WHERE continent IS NOT null
ORDER BY 3, 4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3, 4

--Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


-- Looking at the total cases vs total deaths
-- Shows the chance of dying if infected by Covid in South Africa
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM CovidDeaths
WHERE location LIKE '%south africa%'
ORDER BY 1,2


-- Looking at the total cases vs population
-- Shows the proportion of the population that's infected
SELECT location, date, total_cases, population, (total_cases/population)*100 as infected_percentage
FROM CovidDeaths
WHERE location LIKE '%south africa%'
ORDER BY 1,2


-- Looking at infection rate vs population per country

SELECT location,population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as infected_percentage
FROM CovidDeaths
--WHERE location LIKE '%south africa%'
GROUP BY location, population
ORDER BY infected_percentage DESC


-- Looking at countries with highest death rate

SELECT location,population, MAX(CAST(total_deaths as int)) as death_count
FROM CovidDeaths
--WHERE location LIKE '%south africa%'
WHERE continent IS NOT null
GROUP BY location, population
ORDER BY death_count DESC


-- Showing the continents with the hightest death counts

SELECT continent, MAX(CAST(total_deaths as int)) as death_count
FROM CovidDeaths
--WHERE location LIKE '%south africa%'
WHERE continent IS NOT null
GROUP BY continent
ORDER BY death_count DESC


-- Global numbers 

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage--, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM CovidDeaths
--WHERE location LIKE '%south africa%'
WHERE continent IS NOT null
--GROUP BY date
ORDER BY 1,2


-- Total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as cumulative_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2, 3


-- Use CTE

WITH PopVac (continent, location, date, population, new_vaccinations, cumulative_vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as cumulative_vaccination
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2, 3
)
SELECT *, (cumulative_vaccinations/population)*100
FROM PopVac


-- Temp Table

DROP TABLE IF EXISTS #PercentPopVaccinated
Create TABLE #PercentPopVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulative_vaccinations numeric
)
INSERT INTO #PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as cumulative_vaccination
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2, 3

SELECT *, (cumulative_vaccinations/population)*100
FROM #PercentPopVaccinated



-- Create View to store data for later visualisations

CREATE VIEW PercentPopVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as cumulative_vaccination
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2, 3

SELECT *
FROM PercentPopVaccinated