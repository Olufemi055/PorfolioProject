select *
from PortfolioProject..['covid deaths$']
where continent is not null
order by 3,4



select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['covid deaths$']
order by 1,2

-- looking at total cases vs total deaths


select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
from PortfolioProject..['covid deaths$']
where location like '%state%'
and continent is not null
order by 1,2

-- looking at toal cases vs population

select Location, date, total_cases, population, (total_cases/population)*100 AS percentpoplationinfected
from PortfolioProject..['covid deaths$']
where location like '%Nigeria%'
order by 1,2

-- countries with highest infection rate compared to population

select Location, population, MAX(total_cases) as HighestinfectionCount, MAX((total_cases/population))*100 AS 
percentpoplationinfected
from PortfolioProject..['covid deaths$']
where location like '%state%' 
Group by location, population
order by percentpoplationinfected desc


-- showing countries with highest  death count per population

select Location, MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..['covid deaths$']
--where location like '%state%' 
where continent is not null
Group by location
order by totaldeathcount desc

-- LETS BREAK THINGS DOWN BY CONTINENT

select continent, MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..['covid deaths$']
--where location like '%state%' 
where continent is not null
Group by continent
order by totaldeathcount desc



-- Global numbers
 
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
  (New_cases)*100 AS Deathpercentage
from PortfolioProject..['covid deaths$']
--where location like '%state%'
where continent is not null
-- group by date
order by 1,2 


-- looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
from PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccination$'] vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use CTE
with popvsvac (continent, Location, Date, Population, New_vaccination, RollingpeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
from PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccination$'] vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingpeopleVaccinated/Population)*100
from popvsvac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
from PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccination$'] vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingpeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
from PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccination$'] vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


 select *
from  PercentPopulationVaccinated