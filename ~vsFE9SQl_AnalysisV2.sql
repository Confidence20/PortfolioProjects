
Select *
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccination
--order by 3,4

-- Next, Select Data that you will be working on 

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
order by 1,2


-- Looking at Total number of cases versus Total number of Deaths recorded
--This shows the percentage likelihood of dying if you contracted the virus

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%nigeria%'
order by 1,2


-- Looking for Total number of cases Versus Population
-- This shows what percentage of population got covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where location like '%nigeria%'
order by 1,2


--Looking at country with highest infection rate comapred to population
Select location, population, MAX(total_cases) as HighInfectionCount, Max((total_cases/population))*100 as 
DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
Group by Location, Population
order by 1,2


-- this one show by continent the total death counts
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



--This is showing countries with the Highest Death Count per population
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
Where continent is null
Group by location
order by TotalDeathCount desc




--Global Numbers
Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null
--Group by date
order by 1,2



--looking at total Population  vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths  dea
join PortfolioProject..CovidVaccination  vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3



-- USE CTE(COmmon Table Expression) Regularl used for will use sub-queries to join the records or filter the records from a sub-query


with PopVsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as
 (`
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths  dea
join PortfolioProject..CovidVaccination  vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac





----Tempoarary Table  (TEMP Table)


DROP Table if exists #PercentagePopulationVaccinated
create Table   #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths  dea
join PortfolioProject..CovidVaccination  vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated


--creating view to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths  dea
join PortfolioProject..CovidVaccination  vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
