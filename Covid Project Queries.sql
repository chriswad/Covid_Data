Select *
From PortfolioProjectCovid..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProjectCovid..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectCovid..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths

Select Location, date, cast(total_cases as int), cast(total_deaths as int), (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths$
order by 1,2

--How do I fix the below error? Change data type to integer? Try_convert? cast?
--Msg 8117, Level 16, State 1, Line 18
--Operand data type nvarchar is invalid for divide operator.



--Looking at Total Cases vs Population
--Shows what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PopulationWithCovid
From PortfolioProjectCovid..CovidDeaths$
Where location = 'United States'
order by 1,2


--Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationWithCovid
From PortfolioProjectCovid..CovidDeaths$
--Where location = 'United States'
Group by Location, Population
order by PopulationWithCovid desc


--Showing countries with highest death count per population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid..CovidDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc


--Breakdown by continent

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(New_deaths)/SUM(New_Cases))*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths$
Where continent is not null 
--Group by date
order by 1,2 


--Looking at Total Population vs Vaccinations

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinaitions, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths$ dea
Join PortfolioProjectCovid..CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths$ dea
Join PortfolioProjectCovid..CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View #PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths$ dea
Join PortfolioProjectCovid..CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From #PercentPopulationVaccinated
