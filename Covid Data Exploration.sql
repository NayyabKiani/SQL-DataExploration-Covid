Select* 
from covid_deaths..Coviddeaths 
where continent is not null
order by 3,4

--Select * 
--from covid_deaths..Covidvaccinations
--order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population 
from covid_deaths..Coviddeaths 
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood oof dying if you contract covid in your country.

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths..Coviddeaths 
Where location like '%United Kingdom%'
where continent is not null
order by 1,2


-- Looking at total cases vs population.
-- Shows what percentage of population got covid.

Select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from covid_deaths..Coviddeaths 
Where location like '%United Kingdom%'
order by 1,2


-- Looking at countries with highest infecction rate compared to population size.

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from covid_deaths..Coviddeaths 
--Where location like '%United Kingdom%'
where continent is not null
Group By Location, population
order by PercentagePopulationInfected desc

-- Showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from covid_deaths..Coviddeaths
--Where location like '%United Kingdom%'
where continent is not null
Group By Location
order by TotalDeathCount desc

-- SERPARATING DATA BY CONTINENT

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from covid_deaths..Coviddeaths
--Where location like '%United Kingdom%'
where continent is null
Group By location
order by TotalDeathCount desc


-- Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from covid_deaths..Coviddeaths
--Where location like '%United Kingdom%'
where continent is not null
Group By Continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from covid_deaths..Coviddeaths 
--Where location like '%United Kingdom%'
where continent is not null
--group by  date
order by 1,2


-- looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))over (Partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
from covid_deaths..Coviddeaths dea
Join covid_deaths..Covidvaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from covid_deaths..Coviddeaths dea
Join covid_deaths..Covidvaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select* (RollingPeopleVaccinated/population)*100
from PopvsVac

-- TEMP TABLE

drop table if exists #PercentagePeopleVaccinated
create table #PercentagePeopleVaccinated
(
continent nvarchar(225),
location nvarchar(255)
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from covid_deaths..Coviddeaths dea
Join covid_deaths..Covidvaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select* (RollingPeopleVaccinated/population)*100
from #PercentagePeopleVaccinated


-- creating view to store data for later visulaisations

Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from covid_deaths..Coviddeaths dea
Join covid_deaths..Covidvaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
--order by 2,3

Select* 
from #PercentagePeopleVaccinated