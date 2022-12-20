Select * from PortfolioProject..CovidDeaths
Where location is not null
order by 3,4

--Select * from PortfolioProject..CovidVaccinations
--order by 3,4

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Show percentage of population got covid

Select location,date,population,total_cases,(total_deaths/population)*100 AS PercentageOfPopulation from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Look at countries with highest population


Select location,population,Max(total_cases) AS HighestInfection,Max(total_deaths/population)*100 AS PercentageOfPopulation from PortfolioProject..CovidDeaths
--where location like '%states%'
Where location is not null
Group by location,population
Order by PercentageOfPopulation desc


--Showing Countries with highest deaths per population
Select location,Max(cast(Total_Deaths as int)) as TotalDeathCount from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc


--Break things by continent
Select continent,Max(cast(Total_Deaths as int)) as TotalDeathCount from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Continents with the highest death count per population
Select continent,Max(cast(Total_Deaths as int)) as TotalDeathCount from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 YOU CAN USE CALCULATED FXN HERE need to use CTE 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3 

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 