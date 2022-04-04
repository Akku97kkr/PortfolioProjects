Select *
from PortfolioProject..CovidDeaths
order by 3,4

/*Select *
from PortfolioProject..CovidVaccinations
order by 3,4*/

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

--Looking at the total cases vs total deaths
--avg percentage of death in India
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths
where location like '%India%'
order by 1,2

--Looking at Total cases vs population
--Shows what percentage of population got covid
select location, date, total_cases, total_deaths, Population, (total_cases/population)*100 as Covid_positive
from CovidDeaths
where location like '%India%'
order by 1,2

--Looking at countries with highest infection rate
select location, Population, max(total_cases) as highestInfectionCount, max((total_cases/population))*100 as Covid_positive
from CovidDeaths
--where location like '%India%'
group by location, population
order by Covid_positive desc

--Showing the countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%India%'
where continent is not null
group by location
order by TotalDeathCount desc


--Showing the continents with highest death count
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%India%'
where continent is not null
group by continent
order by TotalDeathCount desc

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%India%'
where continent is null
group by location
order by TotalDeathCount desc


-- Global numbers
select sum(new_cases) as Totalcases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2


--From table CovidVaccinations

select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as TotalNewVacc
--, (TotalNewVacc/population)*100
from CovidDeaths death
join CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by 2,3

-- Troubleshooting the error: Select continent, location, new_vaccinations, sum(cast(new_vaccinations as bigint)) over (Partition by location) from CovidVaccinations order by 1


--Use CTE

with popvsvacc (continent, Location, Date, Population, New_Vaccinations, TotalNewVacc)
as
(
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as TotalNewVacc
--, (TotalNewVacc/population)*100
from CovidDeaths death
join CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
--order by 2,3
)

select *, (TotalNewVacc/Population)*100 as TotalVaccPercentage from popvsvacc

--Use Temp table
Drop Table if exists #Totalvaccpercentage
create table #Totalvaccpercentage (continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_Vaccinations numeric, TotalNewVacc numeric)

insert into #Totalvaccpercentage
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as TotalNewVacc
--, (TotalNewVacc/population)*100
from CovidDeaths death
join CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
--order by 2,3

Select * from #Totalvaccpercentage

--Creating view to store data for later visualizations
create view Totalvaccpercentage as
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as TotalNewVacc
--, (TotalNewVacc/population)*100
from CovidDeaths death
join CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
--order by 2,3