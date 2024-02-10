
--SELECT *
--FROM PortfolioProject.dbo.CovidDeaths$
--WHERE continent is NOT NULL
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations$
--ORDER BY 3,4

--Select data that we are going to be using

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject.dbo.CovidDeaths$
--ORDER BY 1, 2

--Looking at total cases vs. total deaths

--Shows likelihood of dying if you contract Covid in your country

--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location LIKE '%states%'
--ORDER BY 1, 2

--Looking at total cases vs. population
--Shows percentage of population got Covid

--SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
--FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location LIKE '%states%'
--ORDER BY 1, 2

--Looking at countries with highest infection rate compared to population

--SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
--FROM PortfolioProject.dbo.CovidDeaths$
----WHERE location LIKE '%states%'
--GROUP BY location, population
--ORDER BY PercentPopulationInfected DESC

--Showing countries with highest death count per population

--LET'S BREAK THINGS DOWN BY CONTINENT

--SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM PortfolioProject.dbo.CovidDeaths$
--WHERE continent is NOT NULL
--GROUP BY continent
--ORDER BY TotalDeathCount DESC

--SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM PortfolioProject.dbo.CovidDeaths$
--WHERE continent is NULL
--GROUP BY location
--ORDER BY TotalDeathCount DESC

--Showing the continents with the highest death counts

--SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM PortfolioProject.dbo.CovidDeaths$
--WHERE continent is NOT NULL
--GROUP BY continent
--ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

--SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
--FROM PortfolioProject.dbo.CovidDeaths$
----WHERE location LIKE '%states%'
--WHERE continent is NOT NULL
--GROUP BY date
--ORDER BY 1, 2

--Looking at total population vs vaccinations

--SELECT * 
--FROM PortfolioProject.dbo.CovidDeaths$ as death
--	JOIN PortfolioProject.dbo.CovidVaccinations$ as vaccinations
--	ON death.location = vaccinations.location
--	AND death.date = vaccinations.date

--SELECT death.continent, death.location, death.date, death.population, vaccinations.new_vaccinations, 
--SUM(CONVERT(int, vaccinations.new_vaccinations)) OVER (Partition by death.location ORDER BY death.location, death.date) as RollingPeopleVaccianted, 
--(RollingPeopleVaccianted/population)*100
--FROM PortfolioProject.dbo.CovidDeaths$ as death
--	JOIN PortfolioProject.dbo.CovidVaccinations$ as vaccinations
--	ON death.location = vaccinations.location
--	AND death.date = vaccinations.date
--WHERE death.continent is NOT NULL
--ORDER BY 2, 3

--USE CTE

--WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
--as
--(
--SELECT death.continent, death.location, death.date, death.population, vaccinations.new_vaccinations, 
--SUM(CONVERT(int, vaccinations.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
----(RollingPeopleVaccinated/population)*100
--FROM PortfolioProject.dbo.CovidDeaths$ as death
--	JOIN PortfolioProject.dbo.CovidVaccinations$ as vaccinations
--	ON death.location = vaccinations.location
--	AND death.date = vaccinations.date
--WHERE death.continent is NOT NULL
----ORDER BY 2, 3
--)
--SELECT *, (RollingPeopleVaccinated/population)*100
--FROM PopvsVac

--Temp Table


--DROP TABLE IF exists #PercentPopulationVaccinated
--CREATE TABLE #PercentPopulationVaccinated
--(
--Continent nvarchar(255),
--Location nvarchar(255),
--Date datetime,
--Population numeric,
--New_vaccinations numeric,
--RollingPeopleVaccinated numeric
--)

--INSERT INTO #PercentPopulationVaccinated
--SELECT death.continent, death.location, death.date, death.population, vaccinations.new_vaccinations, 
--SUM(CONVERT(int, vaccinations.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
----(RollingPeopleVaccinated/population)*100
--FROM PortfolioProject.dbo.CovidDeaths$ as death
--	JOIN PortfolioProject.dbo.CovidVaccinations$ as vaccinations
--	ON death.location = vaccinations.location
--	AND death.date = vaccinations.date
----WHERE death.continent is NOT NULL
----ORDER BY 2, 3

--SELECT *, (RollingPeopleVaccinated/population)*100
--FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations

CREATE view PercentPopulationVaccinated as 
SELECT death.continent, death.location, death.date, death.population, vaccinations.new_vaccinations, 
SUM(CONVERT(int, vaccinations.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths$ as death
	JOIN PortfolioProject.dbo.CovidVaccinations$ as vaccinations
	ON death.location = vaccinations.location
	AND death.date = vaccinations.date
WHERE death.continent is NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated