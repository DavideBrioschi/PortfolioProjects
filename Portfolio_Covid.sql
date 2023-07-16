select *
from CovidDeaths
where continent is not null
order by 3,4

-- Select Data that we are going to using now (today 15/07/23)

select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Italy 
-- -> 0,73%

select Location, date, total_cases, total_deaths, cast(total_deaths as float)/cast(total_cases as float)*100 as DeathPercentage
from CovidDeaths
Where Location = 'Italy'
order by 1,2

-- Looking at Total Cases vs Population
-- Show what percentuage of population got Covid in Italy
-- -> 43,8%

select Location, date, population, total_cases, cast(total_cases as float)/cast(population as float)*100 as PercentPopulationInfected
from CovidDeaths
Where Location = 'Italy'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
-- -> CYPRUS = 73,7%

select Location, population, max(total_cases) as HighestInfectionCount, max(cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
from CovidDeaths
where continent is not null
group by Location, Population
order by 4 desc

-- Showing Country with Highest Death Count per Population 
-- -> United States = 1.127.152

select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
-- -> Europe

select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null and Location not in ('High income','Upper middle income','Low income')
group by Location
order by TotalDeathCount desc

-- GLOBAL NUMBERS
-- -> Worst day 24/01/2021 (TotalDeaths)

select date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths AS int)) as TotalDeaths, SUM(CAST(new_deaths AS int)) / NULLIF(SUM(new_cases), 0) as DeathPercentuage
from CovidDeaths
Where continent is not null 
Group by date
order by TotalDeaths desc

-- -> Total Cases 767.987.798 - Total Death 6.957.132 - Death Percentuage 0.009% Today

select SUM(new_cases) as TotalCases, SUM(CAST(new_deaths AS int)) as TotalDeaths, SUM(CAST(new_deaths AS int)) / NULLIF(SUM(new_cases), 0) as DeathPercentuage
from CovidDeaths
Where continent is not null 
order by 1,2

----------------------------------
-- Looking at Total Population vs Vaccinations
-- > Italy 89 today

Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as new_vaccination
From CovidDeaths dea
join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.Location = 'italy'
order by 3

-- > USE CTE
-- > RollingPeopleVaccined = Population -> 13/07/21 (1'Vaccination?)

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccined)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(ISNULL(CONVERT(bigint, vac.new_vaccinations), 0)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccined 
From CovidDeaths dea
join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.Location = 'italy'
-- order by 2,3
)
Select *, (RollingPeopleVaccined/population)*100 AS Percentual
from PopvsVac

-- TEMP TABLE (global)
-- -> Higher vaccinations in Cuba

drop table if exist #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(ISNULL(CONVERT(bigint, vac.new_vaccinations), 0)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccined 
From CovidDeaths dea
join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.Location = 'italy'
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as Percentual
from #PercentPopulationVaccinated
order by Percentual desc

-- Creatin View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(ISNULL(CONVERT(bigint, vac.new_vaccinations), 0)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccined 
From CovidDeaths dea
join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.Location = 'italy'
--order by 2,3

Select *
from PercentPopulationVaccinated