
select * from [Portfolio Project]..['CovidDeaths_File-1$']
order by 3,4


--select * from [Portfolio Project]..['CovidVaccinations_File-2$']
--order by 3,4

--selecting data that will be used

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..['CovidDeaths_File-1$']
order by 1,2

--Location wise death % due to covid (deaths vs cases)
--

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
from [Portfolio Project]..['CovidDeaths_File-1$']
--where location = 'India'
order by 1,2

--cases vs population
--% of population infected with covid

select location, date, total_cases, population,(total_cases/population)*100 as infection_percentage
from [Portfolio Project]..['CovidDeaths_File-1$']
where location = 'India'
order by 1,2

--countries with highest infection rate compared to population

select location, MAX(total_cases), population,MAX((total_cases/population))*100 as Highest_infection_percentage
from [Portfolio Project]..['CovidDeaths_File-1$']
--where location = 'India'
Group by location, population
order by 1,2

--Counties with highest death count vs population

select location, MAX(cast(total_deaths as int)) as max_total_deaths
from [Portfolio Project]..['CovidDeaths_File-1$']
--where location = 'India'
where continent is not null
Group by location
order by max_total_deaths desc

--continent wise look

select location, MAX(cast(total_deaths as int)) as max_total_deaths
from [Portfolio Project]..['CovidDeaths_File-1$']
--where location = 'India'
where continent is null    --there are values where location itself is a continent
Group by location
order by max_total_deaths desc

--continents with highest death count
select continent, MAX(cast(total_deaths as int)) as highest_deaths
from [Portfolio Project]..['CovidDeaths_File-1$']
where continent is not null
group by continent
order by highest_deaths desc

--Global data
select date, SUM(new_cases)
from [Portfolio Project]..['CovidDeaths_File-1$']
where continent is not null
group by date
order by 1,2

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_cases)/SUM(cast(new_deaths as int)) as global_death_percentage
from [Portfolio Project]..['CovidDeaths_File-1$']
where continent is not null
group by date
order by 1,2

--Covid vaccinations table join for total populations Vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations  ,
SUM(cast(vac.new_vaccinations as integer )) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as roolingCount_vaccinations
from
[Portfolio Project]..['CovidDeaths_File-1$'] as dea
 join [Portfolio Project]..['CovidVaccinations_File-2$'] as vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 1,2,3

 --using CTE
 with popvsvac (continent, location, date, population, new_vaccinations, rollingCount_vaccinations)
 as
 (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations  ,
SUM(cast(vac.new_vaccinations as integer )) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingCount_vaccinations
from
[Portfolio Project]..['CovidDeaths_File-1$'] as dea
 join [Portfolio Project]..['CovidVaccinations_File-2$'] as vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
-- order by 2,3
)
select *, (rollingCount_vaccinations/population)*100 from popvsvac

--TEMP Table
drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated

(Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
rollingCount_vaccinations numeric,
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations  ,
SUM(cast(vac.new_vaccinations as integer )) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingCount_vaccinations
from
[Portfolio Project]..['CovidDeaths_File-1$'] as dea
 join [Portfolio Project]..['CovidVaccinations_File-2$'] as vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null

 --creating view to show data for visualizing later using tableau

 create view PercentPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations  ,
SUM(cast(vac.new_vaccinations as integer )) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingCount_vaccinations
from
[Portfolio Project]..['CovidDeaths_File-1$'] as dea
 join [Portfolio Project]..['CovidVaccinations_File-2$'] as vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3

 select * from PercentPopulationVaccinated
