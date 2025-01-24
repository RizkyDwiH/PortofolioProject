select *
from PortofolioProject..CovidDeaths
where continent is not null
order by 3, 4

--select *
--from PortofolioProject..CovidVaccinations
--order by 3, 4

--select data we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
where continent is not null
order by 1, 2

--Looking at Total Cases vs Total Deaths
--show likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from PortofolioProject..CovidDeaths
where location = 'China'
 where continent is not null
order by 1, 2

--Looking at Total Cases vs Population
--Show what percentage population got covid

select location, date, population, total_cases, (total_cases/population)* 100 as PercentedPopulationInfected
from PortofolioProject..CovidDeaths
--where location = 'China'
order by 1, 2

--Looking at countries with highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))* 100 as PercentedPopulationInfected
from PortofolioProject..CovidDeaths
--where location = 'China'
group by location, population
order by PercentedPopulationInfected desc


--Showing countries with highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathsCount
from PortofolioProject..CovidDeaths
--where location = 'China'
where continent is not null
group by location
order by TotalDeathsCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continent with the highest deaths count per population

select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from PortofolioProject..CovidDeaths
--where location = 'China'
where continent is not null
group by  continent
order by TotalDeathsCount desc


-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
--where location = 'China'
where continent is not null
--group by date
order by 1, 2


--Looking at Total Population vs Total Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by  2, 3


--USE CTE

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by  dea.location order by  dea.location,
  dea.Date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by  2, 3
)
select *, ( RollingPeopleVaccinated / population) *100
from popvsvac

--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by  dea.location order by  dea.location,
  dea.Date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by  2, 3

select *, ( RollingPeopleVaccinated / population) *100
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations

drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by  dea.location order by  dea.location,
  dea.Date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by  2, 3

select *
from PercentPopulationVaccinated