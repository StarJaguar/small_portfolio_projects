SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at the Total Cases vs Population
-- Show what percentage of population contracted Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to population

SELECT location, population, MAX(total_deaths) AS HighestInfectionCount, MAX((total_deaths/tot)*100) AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectionPercentage DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Let's break things down by continent
-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- More accurate from the table

SELECT location, MAX(cast(Total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global NUMBERS per day

SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2
-- Global totals
SELECT SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccineCount
FROM PortfolioProject..CovidDeaths AS dea
	JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- using cte

WITH PopvsVac(Continent, location, date, population, new_vaccinations, RollingVaccineCount)
 as
 (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccineCount
	FROM PortfolioProject..CovidDeaths AS dea
	JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
 )
SELECT *, (RollingVaccineCount/population)*100 AS PercentagePeopleVaccinated
FROM PopvsVac

-- Temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingVaccineCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccineCount
	FROM PortfolioProject..CovidDeaths AS dea
	JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL

SELECT *, (RollingVaccineCount/population)*100 AS PercentagePeopleVaccinated
FROM #PercentPopulationVaccinated


-- Create View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccineCount
	FROM PortfolioProject..CovidDeaths AS dea
		JOIN PortfolioProject..CovidVaccinations AS vac
		ON dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent IS NOT NULL