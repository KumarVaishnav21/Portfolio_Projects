
Select * 
from Portfolio_Projects..['World-covid-deaths(transformed-$']
where continent is not null
order by 3, 4;

--Select * from Portfolio_Projects..['Covid-vaccination(transformed-d$']
--order by 3, 4;

-- select data that we are using

select 
	location, date, total_cases, New_cases, total_deaths, population
from Portfolio_Projects..['World-covid-deaths(transformed-$']
order by 1,2;

-- Looking at total_cases vs total_Deaths
-- shows likelihood of dying if you contract in your country

select 
	location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percetage
from Portfolio_Projects..['World-covid-deaths(transformed-$']
order by 1,2;

select 
	location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percetage
from Portfolio_Projects..['World-covid-deaths(transformed-$']
where location like '%states%'
order by 1,2;

select 
	location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percetage
from Portfolio_Projects..['World-covid-deaths(transformed-$']
where location like '%india%'
order by 1,2;

-- Looking at Total_cases vs poulation
-- shows what percentage of population got covid

select 
	location, date, total_cases, population, round((total_cases/population)*100,2) as death_percetage
from Portfolio_Projects..['World-covid-deaths(transformed-$']
where location like '%india%'
order by 1,2;

select 
	location, date, total_cases, population, round((total_cases/population)*100,2) as Infected_population_percetage
from Portfolio_Projects..['World-covid-deaths(transformed-$']
where location like '%states%'
order by 1,2;


-- looking countries with highest infection rate compared to Population

select 
	location, max(total_cases) as Highest_Infection_count, population, max((total_cases/population))*100 as Infected_population_percetage
from Portfolio_Projects..['World-covid-deaths(transformed-$']
-- where location like '%india%'
group by location, population
order by Infected_population_percetage desc;


-- Showing Countries with highest death count per population

select 
	location, max(cast(total_deaths as int)) as Totaldeathcount
from Portfolio_Projects..['World-covid-deaths(transformed-$']
-- where location like '%india%'
where continent is not null
group by location
order by Totaldeathcount desc;

-- let's break things down by continent

select 
	location, max(cast(total_deaths as int)) as Totaldeathcount
from Portfolio_Projects..['World-covid-deaths(transformed-$']
-- where location like '%india%'
where continent is null
group by location
order by Totaldeathcount desc;

select distinct location from Portfolio_Projects..['World-covid-deaths(transformed-$']
order by location asc;

--  Showing continents with highest death counts per population

select 
	continent, max(cast(total_deaths as int)) as Totaldeathcount
from Portfolio_Projects..['World-covid-deaths(transformed-$']
-- where location like '%india%'
where continent is not null
group by continent
order by Totaldeathcount desc;



--  Global numbers

select 
	date, sum(new_cases) as total_case,
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from Portfolio_Projects..['World-covid-deaths(transformed-$']
where continent is not null
group by date
order by 1,2;


select 
	sum(new_cases) as total_case,
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from Portfolio_Projects..['World-covid-deaths(transformed-$']
where continent is not null
-- group by date
order by 1,2;


select * from Portfolio_Projects..['Covid-vaccination(transformed-d$'];

--Loking at total population vs Vaccination

select * from 
	Portfolio_Projects..['World-covid-deaths(transformed-$'] dea
join
	Portfolio_Projects..['Covid-vaccination(transformed-d$'] vac
	on dea.location = vac.location
	and dea.date = vac.date ;

select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from 
	Portfolio_Projects..['World-covid-deaths(transformed-$'] dea
join
	Portfolio_Projects..['Covid-vaccination(transformed-d$'] vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
order by 2, 3;


-- USE CTE

with Pop_vs_Vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from 
	Portfolio_Projects..['World-covid-deaths(transformed-$'] dea
join
	Portfolio_Projects..['Covid-vaccination(transformed-d$'] vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
-- order by 2, 3
)
select *, (rolling_people_vaccinated/population)*100
from Pop_vs_Vac;


-- Temp table
 drop table if exists #percent_popu_vaccinated
 create table #percent_popu_vaccinated
 (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rolling_people_vaccinated numeric
)

Insert into #percent_popu_vaccinated
select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from 
	Portfolio_Projects..['World-covid-deaths(transformed-$'] dea
join
	Portfolio_Projects..['Covid-vaccination(transformed-d$'] vac
	on dea.location = vac.location
	and dea.date = vac.date 
-- where dea.continent is not null 
-- order by 2, 3

select *, (rolling_people_vaccinated/population)*100
from #percent_popu_vaccinated;


-- creating view to store data for later visualization


create view percent_poeple_vaccinated as 
select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from 
	Portfolio_Projects..['World-covid-deaths(transformed-$'] dea
join
	Portfolio_Projects..['Covid-vaccination(transformed-d$'] vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
-- order by 2, 3


select * from percent_poeple_vaccinated;