select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 
3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 
--3,4

-- Get rid of columns and data that I will not be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


-- Total Cases vs. Total Deaths
--Likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population contracted Covid

select location, date, total_cases, population, 
(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2 


-- Countries with Highest Infection Rates vs. Population

select location, population, max(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
-- Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- Where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT


-- Continents with Highest Death Count per Population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- Where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc
 

-- Total Cases vs. Total Deaths
--Likelihood of dying if you contract covid in your continent

select continent, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population contracted Covid

select continent, date, total_cases, population, (total_cases/population)*100 
as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
order by 1,2 


-- Continents with Highest Infection Rates vs. Population

select continent, population, max(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
-- Where location like '%states%'
group by continent, population
order by PercentPopulationInfected desc


-- GLOBAL NUMBERS


select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2



-- VACCINATIONS DATA --

select * 
from PortfolioProject..CovidVaccinations$

-- Joining Both Tables
-- Total Population vs. Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, 
RollingPeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--- TEMP TABLE


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for Visualizations 

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
 from PercentPopulationVaccinated
