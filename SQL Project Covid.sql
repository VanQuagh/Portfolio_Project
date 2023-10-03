
-- Use data from CovidDeaths

select location, date, convert(int,total_cases) as total_case, new_cases, convert(int,total_deaths) as total_deaths, population  from SQLProject..CovidDeaths
where total_cases IS NOT null
--and location like 'Vietnam'
order by 1, 2 

-- Looking at Total case and Total Deaths 
-- Show likelihood of dying if you contract convid-19 in your country
select location, date, total_cases, total_deaths,
(cast(total_deaths as float))/(cast(total_cases as float))*100 as DeathPercentage 
from SQLProject..CovidDeaths
where total_cases IS NOT null
and location like 'Vietnam'
order by 1, 2 

-- Looking at Total case vs Population, group by location 
-- Show that percentage of population got covid-19 (By country)
select location, population, max(cast(total_cases as int) as Highest_Infection, max(cast(total_cases as float)/population)*100 as Percent_population_infected
from SQLProject..CovidDeaths
where total_cases IS NOT null
group by location, population
order by Percent_population_infected desc

-- Showing Country with Highest Death Count per population 
select location, population, max(cast(total_deaths as int)) as total_death_count, max(cast(total_deaths as float)/population)*100 as deaths_percentage
from SQLProject..CovidDeaths
where total_cases IS NOT null and continent is not null
group by location, population
-- order by deaths_percentage desc

-- Beark down by continent 
select location, max(cast(total_deaths as int)) as total_death_count
from SQLProject..CovidDeaths
where continent is null
group by location
order by total_death_count desc 

-- Showing Continent with the highest death count per population 
select location, population, max(cast(total_deaths as int)) as total_death_count, max(cast(total_deaths as float))/population*100 as death_percentage 
from SQLProject..CovidDeaths
where continent is null
group by location, population
order by death_percentage desc 

-- Global number 
Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/nullif(sum(new_cases),0))*100 as death_percentage_byCase
from SQLProject..CovidDeaths
where continent is not null
order by 1,2



-- Use CovidVaccinations table: Total population vs total vaccinations
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	sum(cast(v.new_vaccinations as int)) OVER (partition by d.location order by d.location, d.date) as rolling_count
from SQLProject..CovidDeaths d
join SQLProject..CovidVaccinations v
	on d.location = v.location 
	and d.date = v.date 
where d.continent is not null
and d.location like 'Vietnam'
and d.population is not null
order by 1,2,3

-- Use CTE: Percentage of vaccines compared to population
With Pop_vs_Vac (continent, location, date, population,new_vaccinations, rolling_count)
as
(Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	sum(cast(v.new_vaccinations as float)) OVER (partition by d.location order by d.location, d.date) as rolling_count
from SQLProject..CovidDeaths d
join SQLProject..CovidVaccinations v
	on d.location = v.location 
	and d.date = v.date 
where d.continent is not null
and d.population is not null
--order by d.continent, d.location, d.date
) 
select location, max((rolling_count/population)*100) as percentage 
from Pop_vs_Vac
group by location 
order by location 



-- Temp TABLE
Create table #Percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric, 
rolling_count float)

Insert into #Percent_population_vaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	sum(cast(v.new_vaccinations as float)) OVER (partition by d.location order by d.location, d.date) as rolling_count
from SQLProject..CovidDeaths d
join SQLProject..CovidVaccinations v
	on d.location = v.location 
	and d.date = v.date 
where d.continent is not null
and d.population is not null
--order by d.continent, d.location, d.date

select * 
from #Percent_population_vaccinated


-- Creating View to store data for later Visualizations 
Create view Percent_population_vaccinated as 
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	sum(cast(v.new_vaccinations as float)) OVER (partition by d.location order by d.location, d.date) as rolling_count
from SQLProject..CovidDeaths d
join SQLProject..CovidVaccinations v
	on d.location = v.location 
	and d.date = v.date 
where d.continent is not null
and d.population is not null

select * from Percent_population_vaccinated