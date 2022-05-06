select * 
from ProjectPortfolio..coviddeaths
order by 3,4;

select *  
from ProjectPortfolio..covidvacc
order by 3,4;

-- selecting data to be used

select location, date, total_cases, new_cases, total_deaths  
from ProjectPortfolio.dbo.coviddeaths
order by 1,2;

-- looking t total cases vs total deaths

select location, date, total_cases, new_cases, total_deaths , (total_deaths/total_cases)*100 as death_percentage
from ProjectPortfolio.dbo.coviddeaths
where location like '%india%'
and continent is not null
order by 1,2;

--total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as percentage_covid_cases
from ProjectPortfolio.dbo.coviddeaths
--where location like '%india%'
order by 1,2;

--looking at countries with highest infection rate compared to population

select location,population,date, max(total_cases) as highest_infection_count, 
max(total_cases/population)*100 as percentage_population_infection
from ProjectPortfolio.dbo.coviddeaths
--where location like '%india%'
group by location,population,date
order by 4 desc;

select location,population, max(total_cases) as highest_infection_count, 
max(total_cases/population)*100 as percentage_population_infection
from ProjectPortfolio.dbo.coviddeaths
--where location like '%india%'
group by location,population
order by 4 desc;

--Showing countries with highest death counts per population 

select location, population, max(cast(total_deaths as int)) as Total_Death_Count
from ProjectPortfolio.dbo.coviddeaths
--where location like '%india%'
where continent is not null
group by location,population
order by 3 desc;

-- break down by continent

--Showing the continents with highest death count per populattion

/*select location, max(cast(total_deaths as int)) as Total_Death_Count
from ProjectPortfolio.dbo.coviddeaths
--where location like '%india%'
where continent is null and location not in('High income','Lower middle income','Low income','Upper middle income')
group by location
order by 2 desc;*/

select continent, max(cast(total_deaths as int)) as Total_Death_Count
from ProjectPortfolio.dbo.coviddeaths
--where location like '%india%'
where continent is not null
group by continent
order by 2 desc;

--Global Numbers

select sum(new_cases) as "total cases" , sum(cast(new_deaths as int)) as "total deaths", sum(cast(new_deaths as int))/sum(new_cases)*100 as "death percentage"
from ProjectPortfolio.dbo.coviddeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2;


--Looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as 
"Rolling people vaccination"
--,(Rolling people vaccination/population)*100
from ProjectPortfolio..coviddeaths dea
join ProjectPortfolio..covidvacc vacc
on dea.location=vacc.location
  and dea.date=vacc.date
  where dea.continent is not null
  order by 2,3


  -- USE CTE

  with PopvsVacc(continent, location, date, population, new_vaccinations, Rollingpeoplevaccination)
  as
  (
  select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as 
Rollingpeoplevaccination
--,(Rolling people vaccination/population)*100
from ProjectPortfolio..coviddeaths dea
join ProjectPortfolio..covidvacc vacc
on dea.location=vacc.location
  and dea.date=vacc.date
  where dea.continent is not null
 -- order by 2,3
  )
  select *,(Rollingpeoplevaccination/population)*100
  from PopvsVacc;

  -- TEMP TABLE

  drop table if exists #PercentPopulationVaccination
  Create Table #PercentPopulationVaccination
  (Continent nvarchar(255),
  Location nvarchar(225),
  Date datetime,
  Population numeric,
  New_Vaccination numeric,
  RollingpeopleVaccination numeric)

  Insert into #PercentPopulationVaccination
  select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as 
Rollingpeoplevaccinated
--,(Rolling people vaccination/population)*100
from ProjectPortfolio..coviddeaths dea
join ProjectPortfolio..covidvacc vacc
on dea.location=vacc.location
  and dea.date=vacc.date
 -- where dea.continent is not null
 -- order by 2,
  
   select *,(Rollingpeoplevaccination/population)*100 as vacc_percentage
  from #PercentPopulationVaccination


--Creating view

drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as
  select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as 
Rollingpeoplevaccinated
--,(Rolling people vaccination/population)*100
from ProjectPortfolio..coviddeaths dea
join ProjectPortfolio..covidvacc vacc
on dea.location=vacc.location
  and dea.date=vacc.date
 where dea.continent is not null
 -- order by 2,3

 select * 
 from PercentPopulationVaccinated