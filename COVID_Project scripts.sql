select *
from PortfolioProject..CovidDeaths
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


select location , date, total_cases , new_cases , total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


select location , date, total_cases ,  total_deaths, (total_deaths/total_cases)*100 as DeathRate
from PortfolioProject..CovidDeaths
where location like '%germany%'
order by 1,2


select location , date, population, total_cases ,  (total_cases/population)*100 as infectionRate
from PortfolioProject..CovidDeaths
where location like '%germany%'
order by 1,2


select location , population, max(total_cases) as HighestInfCount ,  max((total_cases/population)*100) as HighestInfRate
from PortfolioProject..CovidDeaths
--where location like '%germany%'
group by location, population
order by 4 desc


select location, max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%germany%'
where continent is not null 
group by location
order by 2 desc


select continent, max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%germany%'
where continent is not null 
group by continent
order by 2 desc


select  date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathRate
from PortfolioProject..CovidDeaths
--where location like '%germany%'
where continent is not null
group by date
order by 1,2


with peopVac (continent,location,date,population,newVacc,#peopleVaccinUntilThisDay)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , sum(convert (int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date)  as #peopleVaccinUntilThisDay
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3 
)
select *, (#peopleVaccinUntilThisDay/population) *100 as peopleVaccinRate
from peopVac
order by 2,3
--where location like '%albania%'


drop table if exists #peopleVaccinRate 
create table #peopleVaccinRate
(continent nvarchar(255),
location nvarchar(2555),
date datetime,
population numeric,
new_vaccination numeric,
#peopleVaccinUntilThisDay numeric) 


insert into #peopleVaccinRate
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , sum(convert (int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date)  as #peopleVaccinUntilThisDay
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3 

select *, (#peopleVaccinUntilThisDay/population) *100 as peopleVaccinRate
from #peopleVaccinRate
order by 2,3



-- views for later Data Visualisations 


create view peopleVaccinRateView as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , sum(convert (int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date)  as #peopleVaccinUntilThisDay
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3


select *
from peopleVaccinRateView
