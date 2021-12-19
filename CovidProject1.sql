select * 
from PortafolioProject..Coviddeaths
where continent IS NOT NULL
order by 3,4;

--select * 
--from PortafolioProject..CovidVaccinations
--order by 3,4;

Select location, date, total_cases,new_cases,total_deaths, population
from PortafolioProject..coviddeaths
where continent IS NOT NULL
order by 1,2;

-- Total cases vs total deaths
-- Probability of dying of cornavirus in your country
Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortafolioProject..coviddeaths
where location like '%Mexico%' and continent IS NOT NULL
order by 1,2;

--Porcentage of population that got covid in Mexico
Select location, date,population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortafolioProject..coviddeaths
where location like '%Mexico%'
order by 1,2;

--Countries with Highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortafolioProject..coviddeaths
Group by location, population
order by PercentPopulationInfected desc;

-- Countries with Highest death count per population

Select location, MAX(cast (total_deaths as int)) as TotalDeathCount
from PortafolioProject..coviddeaths
where continent IS NOT NULL
Group by location
order by TotalDeathCount desc;

-- Continents by Highest death count per population

Select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
from PortafolioProject..coviddeaths
where continent is not null
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

Select date, SUM(new_cases)as totalCases,
SUM(cast(new_deaths as int)) as totalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage

from PortafolioProject..coviddeaths
--where location like '%Mexico%' 
where continent IS NOT NULL
Group by date
order by 1,2;

-- Total cases and total deaths around the world

Select SUM(new_cases)as totalCases,
SUM(cast(new_deaths as int)) as totalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage

from PortafolioProject..coviddeaths
--where location like '%Mexico%' 
where continent IS NOT NULL
order by 1,2;

use PortafolioProject;

-- Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.Location order by dea.location, dea.date) as SumOfPeopleVaccinated
from portafolioproject..Coviddeaths dea
Join portafolioproject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent IS NOT NULL
order by 2,3;

--Use CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortafolioProject..CovidDeaths dea
Join PortafolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortafolioProject..CovidDeaths dea
Join PortafolioProject..CovidVaccinations vac
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
From PortafolioProject..CovidDeaths dea
Join PortafolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 