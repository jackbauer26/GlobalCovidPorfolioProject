select * from portfolio..CovidDeathGlobal2$
where continent is not null
order by 3,4;

--select * from portfolio..CovidDeathGlobal2$
--order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population from 
portfolio..CovidDeathGlobal2$ 
where continent is not null
order by 1,2;

select location, date, total_cases, total_deaths, round(((total_deaths/total_cases)*100),2) Death_Percentage from 
portfolio..CovidDeathGlobal2$ 
where location = 'Nigeria' 
order by 1,2;

select location, date, total_cases, population, round(((total_cases/population)*100),2) Popul_Contract_Perct from 
portfolio..CovidDeathGlobal2$ 
-- where location = 'Nigeria' 
where continent is not null
order by Popul_Contract_Perct DESC;

select location, MAX(total_cases) Highest_Infection_Count, round((max((total_cases/population))*100),2) Max_Popul_Contract_Perct from 
portfolio..CovidDeathGlobal2$ 
-- where location = 'Nigeria' 
where continent is not null
group by location, population
order by Max_Popul_Contract_Perct DESC;

select location, MAX(cast(total_deaths as int)) Highest_Death_Count from 
portfolio..CovidDeathGlobal2$ 
-- where location = 'Nigeria' 
where continent is not null
group by location
order by Highest_Death_Count DESC;

select location, MAX(cast(total_deaths as int)) Highest_Death_Count from 
portfolio..CovidDeathGlobal2$ 
-- where location = 'Nigeria' 
where continent is null
group by location
order by Highest_Death_Count DESC;

--Perform basic selection and aggregation

select continent, MAX(cast(total_deaths as int)) Highest_Death_Count from 
portfolio..CovidDeathGlobal2$ 
-- where location = 'Nigeria' 
where continent is not null
group by continent
order by Highest_Death_Count DESC;


-- Select and perform aggregation operation and filtering where applicable
-- with a group by clause

select date, SUM(new_cases) Total_Cases, SUM(CAST(new_deaths AS float)) Total_New_Death , 
(SUM(CAST(new_deaths AS float))/sum(new_cases))*100 Death_Percentage 
from portfolio..CovidDeathGlobal2$ 
-- where location = 'Nigeria' 
where continent is not null and date <> '2021-06-01 00:00:00.000'
group by date
order by 1,2;


-- Select and perform aggregation operation and filtering where applicable

select SUM(new_cases) Total_Cases, SUM(CAST(new_deaths AS float)) Total_New_Death , 
(SUM(CAST(new_deaths AS float))/sum(new_cases))*100 Death_Percentage 
from portfolio..CovidDeathGlobal2$ 
-- where location = 'Nigeria' 
where continent is not null and date <> '2021-06-01 00:00:00.000'
-- group by date
order by 1,2;


-- Perform an inner join operation on the two available tables

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over  (partition by dea.location order by dea.location, dea.date) Year_to_Date_Count
from portfolio..CovidDeathGlobal2$ dea
inner join portfolio..vaccination$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;


-- Create a CTE to calculate rolling percentage value

WITH popvsvac (continent, location, date, population, new_vaccination, Year_to_Date_Count) 
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over  (partition by dea.location order by dea.location, dea.date) Year_to_Date_Count
from portfolio..CovidDeathGlobal2$ dea
inner join portfolio..vaccination$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null)
--order by 1,2,3)
select *, concat(round((Year_to_Date_Count/population)*100,2),'%') as YTD_Percent from popvsvac
where Year_to_Date_Count is not null;


-- Create a view table to select data from the 2 tables

create view percPoplationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over  (partition by dea.location order by dea.location, dea.date) Year_to_Date_Count
from portfolio..CovidDeathGlobal2$ dea
inner join portfolio..vaccination$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null;