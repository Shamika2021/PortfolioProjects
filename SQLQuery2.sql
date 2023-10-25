select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select * 
from PortfolioProject..CovidVaccinations
order by 3,4

--Select the data
select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Total cases vs Total deaths
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where Location like '%Sri Lanka%'
order by 1,2

--Total cases vs population
select Location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From PortfolioProject..CovidDeaths
where Location like '%Sri Lanka%'
order by 1,2

--Countries with highest infection rate with regards to population
select Location, population, Max(total_cases) as HighestTotalCases, Max((total_cases/population)*100) as PercentageCases
From PortfolioProject..CovidDeaths
group by Location, population
order by PercentageCases desc

--Countries with highest Mortality
select Location, Max(cast(total_deaths as int)) as HighestTotalDeaths
From PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by HighestTotalDeaths desc

--total deaths by continent
select Location, Max(cast(total_deaths as int)) as HighestTotalDeaths
From PortfolioProject..CovidDeaths
where continent is null
group by Location
order by HighestTotalDeaths desc

select continent, Max(cast(total_deaths as int)) as HighestTotalDeaths
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestTotalDeaths desc

--create a view
create view continentdeathcount as
select continent, Max(cast(total_deaths as int)) as HighestTotalDeaths
From PortfolioProject..CovidDeaths
where continent is not null
group by continent


--Global death count
select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Overall_deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--overall global death count
select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Overall_deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Covid Vaccination data
select *
from PortfolioProject..CovidVaccinations

--Total population vs vaccination
with PopvsVac (continent, location, date, population, new_vaccinations, Rollingvaccinatedcount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by
dea.location, dea.date) as Rollingvaccinatedcount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (Rollingvaccinatedcount/population)*100 as rollingvacpercentage
from PopvsVac

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingvaccinatedcount numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by
dea.location, dea.date) as Rollingvaccinatedcount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (Rollingvaccinatedcount/population)*100 as rollingvacpercentage
from #percentpopulationvaccinated

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by
dea.location, dea.date) as Rollingvaccinatedcount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
