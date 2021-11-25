SELECT *
FROM PortfolioProject..['covid-deaths']
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..['covid-vaccinations']
--ORDER BY 3,4

--total deaths vs total cases ratio/ death chances
SELECT location, date, population, total_cases, new_cases, total_deaths, ((total_deaths/total_cases)*100) as DeathPercentage
FROM PortfolioProject..['covid-deaths']
where location = 'India'
order by 1,2


--total cases vs population
-- shows what percentage population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..['covid-deaths']
--where location like '%india%'
order by 1,2

--infection percentage
SELECT location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..['covid-deaths']
group by location, population
order by PercentagePopulationInfected desc 

--Showing countries death count per population
SELECT location, date, population, total_deaths, (total_deaths/population)*100 as DeathperPopulation
FROM PortfolioProject..['covid-deaths']
--where location like '%india%'
order by 1,2

--showing countries max death count
SELECT location, max(cast(total_deaths as int)) as max_deaths
FROM PortfolioProject..['covid-deaths']
--where location like '%india
where continent is not null
group by location
order by max_deaths desc


SELECT continent, max(cast(total_deaths as int)) as max_deaths
FROM PortfolioProject..['covid-deaths']
--where location like '%india
where continent is not null
group by continent
order by max_deaths desc

SELECT location, max(cast(total_deaths as int)) as max_deaths
FROM PortfolioProject..['covid-deaths']
--where location like '%india
where continent is null
group by location
order by max_deaths desc

--Global cases

Select date, sum(new_cases)
from PortfolioProject..['covid-deaths']
where continent is not null
group by date
order by 1,2 

Select sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..['covid-deaths']
where continent is not null
--group by date
order by 1,2 

--population vs vaccination

select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations
from PortfolioProject..['covid-deaths'] as dea
join PortfolioProject..['covid-vaccinations'] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location  order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject..['covid-deaths'] as dea
join PortfolioProject..['covid-vaccinations'] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as 
(
select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location  order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject..['covid-deaths'] as dea
join PortfolioProject..['covid-vaccinations'] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

select *
from PopvsVac

--creating temp table

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinations numeric
)
insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location  order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject..['covid-deaths'] as dea
join PortfolioProject..['covid-vaccinations'] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (RollingVaccinations/Population) *100
from #PercentagePopulationVaccinated


--creating views 

create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location  order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject..['covid-deaths'] as dea
join PortfolioProject..['covid-vaccinations'] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null