

--Considering only 2023 data

SELECT * INTO PortfolioProject..CovidDeaths23
  FROM PortfolioProject..CovidDeaths 
  WHERE cast(date as date) >= '2023-01-01' 
    and cast(date as date) <= '2023-12-31'


SELECT * INTO PortfolioProject..CovidVaccinations23
  FROM PortfolioProject..CovidVaccinations 
  WHERE cast(date as date) >= '2023-01-01' 
    and cast(date as date) <= '2023-12-31'

--Looking at the total cases vs population

select location, date, total_cases, population, new_cases,
       (total_cases/ population)* 100 as PercentInfected
	from PortfolioProject..CovidDeaths
	where location like '%Palestine%' and cast(date as date) >= '2022-12-01' and cast(date as date) <= '2022-12-31'
	


--Finding Total number of countries
select count(distinct location) from CovidDeaths where continent is not null



/* Looking at Countries with Highest Death Rate 
  compared to Population
  */

select location, population, max(cast(total_deaths as int)) maximumdeaths
	from PortfolioProject..CovidDeaths
	where continent is not null
	group by location, population
	order by maximumdeaths desc


--Global Numbers

with temp_table as (
select * from PortfolioProject..CovidDeaths
	where cast(date as date) >= '2023-05-01' and cast(date as date) <= '2023-05-31')
Select date, sum(new_cases) global_new_cases, 
             sum(cast(new_deaths as int)) global_new_deaths,
     sum(cast(new_deaths as int)) / nullif(sum(new_cases),0)*100  DeathPercentage
	From temp_table--PortfolioProject..CovidDeaths
	where continent is not null
	group by date
	order by 1,2


--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths23 dea 
join PortfolioProject..CovidVaccinations23 vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null AND dea.location = 'India'
order by 2,3

--Rolling Vaccinations

select dea.continent, dea.location, dea.date, datename(dw,dea.date) as day_of_week,
       dea.population, vac.new_vaccinations, --vac.total_vaccinations,
	   sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
from PortfolioProject..CovidDeaths23 dea 
join PortfolioProject..CovidVaccinations23 vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null AND dea.location = 'India'
order by 2,3

-- Finding out which day of the week in 2023 had the highest numbers of vaccinations in India

WITH TEMP AS
(
select dea.continent, dea.location, dea.date, datename(dw,dea.date) as day_of_week,
       dea.population, vac.new_vaccinations, --vac.total_vaccinations,
	   sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
from PortfolioProject..CovidDeaths23 dea 
join PortfolioProject..CovidVaccinations23 vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null AND dea.location = 'India'
)
SELECT location, day_of_week, avg(cast(new_vaccinations as int)) FROM TEMP
GROUP BY day_of_week, location

-- Finding out which month in 2023 had the highest numbers of vaccinations in India

select dea.location, datepart(m,dea.date) as month_name,
        sum(cast(vac.new_vaccinations as int)) as vaccinations_by_month
from PortfolioProject..CovidDeaths23 dea 
join PortfolioProject..CovidVaccinations23 vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null AND dea.location = 'India'
group by datepart(m,dea.date), dea.location



