
-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  as percentage_of_death
from death
where location like "%states%"
order by 1,2 


-- looking at total cases vs population
-- percentage of population in United States got Covid 

select location, date, total_cases, population, (total_cases/population)*100  as percentage_of_cases
from death
where location like "%states%"
order by 1,2 


-- country with the highest infected population
select location, population, max(total_cases) as HighestInfectionCount,max( (total_cases/population)*100) as HighestPercentPopulationInfected
from death
group by location, population
order by HighestPercentPopulationInfected desc



-- country with highest death count per population

select location, max(cast(total_deaths as unsigned)) as TotalDeathCount
from death
where continent is not null
group by location
order by TotalDeathCount desc

-- let's break things down by continent
-- the continent with the highest death count per population
select location, max(cast(total_deaths as unsigned)) as TotalDeathCount
from death
where continent is null
group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS 

select sum(new_cases)as NewCases, sum(new_deaths ) as NewDeaths, sum(new_deaths )/sum(new_cases)*100 as DeathPercentge
from death
where continent is not null
-- group by date
order by 1,2

-- total poulation vs. vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From death dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Temp Table 
Drop temporary table if exists PercentPopulationVaccinated;
Create temporary table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(v.new_vaccinations ) over (partition by d.location order by d.date) as RollingPeopleVaccinated
from death d
join covidvaccinations v
on d.location = v.location and d.date=v.date



select (RollingPeopleVaccinated/Population)*100
from PercentPopulationVaccinated 



-- creating a view for future visualization
Create View PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(v.new_vaccinations ) over (partition by d.location order by d.date) as RollingPeopleVaccinated
from death d
join covidvaccinations v
on d.location = v.location and d.date=v.date
where d.continent is not nullpercentpopulationvaccinated






