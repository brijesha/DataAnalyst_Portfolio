--select * from covid_vaccinations cv order by 3,4; 
--select data that we are going to use
select "location" ,"date" ,total_cases ,new_cases ,total_deaths ,population_density 
from covid_deaths cd 
order by 1,2 

select "location",sum(total_deaths) as sumof_total_deaths  
from covid_deaths cd
where iso_code not like 'OWID_%'
group by "location" 
having sum(total_deaths) is not null 
order by sumof_total_deaths desc 
limit 3


-- Looking Total cases vs Total death
select "location" ,"date" ,total_cases ,total_deaths, round((total_deaths/total_cases)*100) as death_perc 
from covid_deaths cd 
--where location like '%States%'
order by 1,2

-- Loking total cases vs population; shows what % of population got covid
select "location" ,"date" , population ,total_cases , (total_cases/population)*100 as population_infected_perc 
from covid_deaths cd 
--where location like '%States%'
order by 1,2

-- Looking for Countries have highes infection rate compared to population
select "location" , population ,max(total_cases) as highest_infection_counts , max((total_cases/population))*100 as population_infected_perc 
from covid_deaths cd 
where iso_code not like 'OWID_%' and total_cases is not null 
group by "location" ,population 
order by population_infected_perc desc 

-- Showing country highest death count per population
select "location" , max (total_cases) as highest_infection_counts,
	max(total_deaths) as highest_death_count 
from covid_deaths cd 
where iso_code not like 'OWID_%' and total_cases is not null and total_deaths is not null 
group by "location" 
order by highest_death_count desc 

-- by continent highest death
select continent , max(total_deaths) as total_death_count 
from covid_deaths cd 
where continent !=''
group by continent 
order by total_death_count desc

-- global number
select "date" ,sum(total_cases) as total_case ,sum(total_deaths) as total_deaths, 
	round((sum(total_deaths)/sum(total_cases))*100) as death_perc 
from covid_deaths cd 
where continent !=''
group by "date" 
order by 1,2

-- total population vs vaccine
with popvsVac(continent,location,date, population, new_vaccinations,rolling_people_vaccinated)
as
(
SELECT
  dea.continent,
  dea."location",
  dea."date",
  dea.population,
  (CASE
    WHEN vac.new_vaccinations = '' 
    THEN 0
    ELSE CAST(vac.new_vaccinations AS numeric) END) AS new_vaccinations,
  sum(CASE
    WHEN vac.new_vaccinations = '' 
    THEN 0
    ELSE CAST(vac.new_vaccinations AS numeric) END)
    OVER (
	    PARTITION BY dea."location"
	    ORDER BY dea."location", dea.date
	  ) AS rolling_people_vaccinated
	--rolling_people_vaccinated/population *100
FROM
  covid_deaths as dea
JOIN
  covid_vaccinations as vac
ON
  dea."location" = vac."location"
  AND dea."date" = vac."date"
WHERE
  dea.continent != ''
  )
  select *,(rolling_people_vaccinated/population)*100 as pop_vac_perc
  from popvsVac
  
  -- create view
  create view population_vaccinated_perc as
  with popvsVac(continent,location,date, population, new_vaccinations,rolling_people_vaccinated)
as
(
SELECT
  dea.continent,
  dea."location",
  dea."date",
  dea.population,
  (CASE
    WHEN vac.new_vaccinations = '' 
    THEN 0
    ELSE CAST(vac.new_vaccinations AS numeric) END) AS new_vaccinations,
  sum(CASE
    WHEN vac.new_vaccinations = '' 
    THEN 0
    ELSE CAST(vac.new_vaccinations AS numeric) END)
    OVER (
	    PARTITION BY dea."location"
	    ORDER BY dea."location", dea.date
	  ) AS rolling_people_vaccinated
	--rolling_people_vaccinated/population *100
FROM
  covid_deaths as dea
JOIN
  covid_vaccinations as vac
ON
  dea."location" = vac."location"
  AND dea."date" = vac."date"
WHERE
  dea.continent != ''
  )
  select *,(rolling_people_vaccinated/population)*100 as pop_vac_perc
  from popvsVac
  
  -- quering the view
  select location, date, rolling_people_vaccinated
  from population_vaccinated_perc
  
  -- tableau quaries
  -- 1.
  select sum(new_cases) as total_cases, 
  	sum(new_deaths) as total_deaths,
  	(sum(new_deaths)/sum(new_cases))*100 as death_perc
  from covid_deaths
  where continent !=''
  order by 1,2
  
-- 2. 
-- European Union is part of Europe

Select location, SUM(new_deaths) as Total_Death_Count
From covid_deaths
Where continent=''
and location not in ('World', 'European Union', 'International', 'High income','Upper middle income','Lower middle income','Low income')
Group by location
order by Total_Death_Count desc


-- 3.

Select Location, Population, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Population_Infected_Perc
From covid_deaths
Group by Location, Population
order by Population_Infected_Perc desc


-- 4.

Select Location, Population,date, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Population_Infected_Perc
From covid_deaths
where total_cases is not null
Group by Location, Population, date
order by Population_Infected_Perc desc

Select count(*)
From covid_deaths
where total_cases is not null
