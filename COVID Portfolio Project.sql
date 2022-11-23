Select *
From PortfolioProject..CovidDeaths$
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2


--Looking at Total case vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%india%'
order by 1,2


--Looking at Total case vs Population
--Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%india%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population , MAX(total_cases) as HightestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%india%'
Group by Location,Population
order by PercentPopulationInfected desc


--Showing Countries with Hightest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as totaldeathcount
From PortfolioProject..CovidDeaths$
--Where location like '%india%'
Where continent is not null
Group by Location
order by totaldeathcount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the Continent with Highest Death Count per population 

Select continent, MAX(cast(total_deaths as int)) as totaldeathcount
From PortfolioProject..CovidDeaths$
--Where location like '%india%'
Where continent is not null
Group by continent
order by totaldeathcount desc


--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%india%'
Where continent is not null
--Group by date
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location ,dea.date , dea.population, vac.new_vaccinations ,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
  order by 2,3


  --USE CTE


With PopvsVac (Continent, Loaction, Date , Population , New_Vaccinations , RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location ,dea.date , dea.population, vac.new_vaccinations ,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
 -- order by 2,3
 )
 Select * ,(RollingPeopleVaccinated/Population)*100
 From PopvsVac


 --TEMP TABLE

 DROP TABLE if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric,
 )


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location ,dea.date , dea.population, vac.new_vaccinations ,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
 -- order by 2,3

   Select * ,(RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location ,dea.date , dea.population, vac.new_vaccinations ,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
 -- order by 2,3

 
 Select *
 From PercentPopulationVaccinated