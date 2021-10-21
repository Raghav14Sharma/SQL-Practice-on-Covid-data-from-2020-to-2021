-- Data Selection
Select [location],[date],total_cases,new_cases,total_deaths,population
From PortfoliProject1..CovidDeaths$
order by 1,2
-- Total cases vs Total deaths percentage
Select [location],[date],total_cases,total_deaths,(total_deaths/total_cases)*100 as TotalDeathPercentage
From PortfoliProject1..CovidDeaths$
WHERE [location] like '%India%'
order by 1,2
-- Total cases vs population 
Select [location],[date],total_cases,population,(total_cases/population)*100 as InfectedPopulationPercentage
From PortfoliProject1..CovidDeaths$
WHERE [location] like '%India%'
order by 1,2
-- Country with highest infection rate vs population
Select [location],MAX(total_cases) as HighestInfectionCount,population,MAX((total_cases/population))*100 as InfectedPopulationPercentage
From PortfoliProject1..CovidDeaths$
GROUP by [location],population 
order by 4 DESC
-- Country with highest deaths per population
Select [location],MAX(cast(total_deaths as int)) as TotalDeathCount,population,MAX((total_deaths/population))*100 as DeathPercentage
From PortfoliProject1..CovidDeaths$
GROUP by [location],population 
order by 4 DESC
-- Continent with highest deaths per population
Select [continent],MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfoliProject1..CovidDeaths$
WHERE continent is not null
GROUP by [continent] 
order by 2 DESC
-- Golbal numbers grouped
Select [date],SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as TotalDeathPercentage
From PortfoliProject1..CovidDeaths$
WHERE continent is not null
GROUP by date
order by 1
-- Golbal numbers ungrouped
Select SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as TotalDeathPerNewCase
From PortfoliProject1..CovidDeaths$
WHERE continent is not null
order by 1,2
-- Total population vs total vaccination (Using JOIN)
SELECT dea.continent, dea.[location],dea.[date],dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION  by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfoliProject1..CovidDeaths$ dea
Join PortfoliProject1..CovidVaccinations$ vac
ON dea.[location] = vac.[location]
and dea.[date] = vac.[date] 
WHERE dea.continent is not null
Order by 2,3 
-- using  common table expression (CTE)
WITH PopVsVac (Continent,Location,Date,Population,NewVaccinations,RollingPeopleVaccinated)
as
(
   SELECT dea.continent, dea.[location],dea.[date],dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION  by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfoliProject1..CovidDeaths$ dea
Join PortfoliProject1..CovidVaccinations$ vac
ON dea.[location] = vac.[location]
and dea.[date] = vac.[date] 
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
FROM PopVsVac
WHERE [Location] = 'India'
-- creating a view
Create View PercentagePopulationVaccinated as 
 SELECT dea.continent, dea.[location],dea.[date],dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION  by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfoliProject1..CovidDeaths$ dea
Join PortfoliProject1..CovidVaccinations$ vac
ON dea.[location] = vac.[location]
and dea.[date] = vac.[date] 
WHERE dea.continent is not null