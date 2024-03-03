Select *
From Covid_Portfolio_Project..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From Covid_Portfolio_Project..Covid_Vaccinations$
--order by 3,4

-- Select the data that we're going to be using  

Select Location, date, total_cases, new_cases, total_deaths, population
From Covid_Portfolio_Project..CovidDeaths$
Where continent is not null
order by 1,2

-- Looking at Total cases vs Total Deaths
-- Shows likelyhood of dying if you contract covid in your country
Select 
Location, 
date, 
total_cases, 
total_deaths,
(total_deaths/total_cases) *100 as Death_Percentage
From Covid_Portfolio_Project..CovidDeaths$
Where location like 'United States%'
  and continent is not null
order by 1,2

-- Looking at the total Cases vs Population
-- Shows what percentage of population got covid

Select 
Location, 
date,
population,
total_cases, 
(total_cases/population) *100 as Percentage_of_Population_Infected
From Covid_Portfolio_Project..CovidDeaths$
Where continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population 

Select 
Location, 
population,
MAX(total_cases) as Highest_Infection_Count, 
MAX((total_cases/population)) *100 as Percentage_of_Population_Infected
From Covid_Portfolio_Project..CovidDeaths$
Where continent is not null
Group by location, population
order by Percentage_of_Population_Infected desc


-- Showing the countries with Highest Death Count per Population


Select 
Location, 
MAX(Cast(Total_deaths as int)) as Total_Death_Count
From Covid_Portfolio_Project..CovidDeaths$
Where continent is not null
Group by location
order by Total_Death_Count desc

 
-- LET'S BREAK THINGS DOWN BY CONTINENT
 
Select 
continent, 
MAX(Cast(Total_deaths as int)) as Total_Death_Count
From 
    Covid_Portfolio_Project..CovidDeaths$
Where 
     continent is not null
Group by continent
order by Total_Death_Count desc


-- GLOBAL NUMBERS 

Select
   date,
   Sum(new_cases) as total_cases,
   Sum(cast(new_deaths as int)) as total_deaths,
   Sum(cast(new_deaths as int))/Sum(new_cases) * 100 as Death_Percentage
From Covid_Portfolio_Project..CovidDeaths$
where continent is not null
Group by date
order by 1,2

--Looking at total population vs vaccination

Select 
  dea.continent, 
  dea.location, 
  dea.date,
  dea.population,
  vac.new_vaccinations,
  sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated 
From Covid_Portfolio_Project..CovidDeaths$ as dea
Join
 Covid_Portfolio_Project..CovidVaccinations$ as vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 order by 1,2,3


 -- Use CT

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, rolling_people_vaccinate)
  as(
  Select 
  dea.continent, 
  dea.location, 
  dea.date,
  dea.population,
  vac.new_vaccinations,
  sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated 
From Covid_Portfolio_Project..CovidDeaths$ as dea
Join
 Covid_Portfolio_Project..CovidVaccinations$ as vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 --order by 1,2,3
 )
Select* , (rolling_people_vaccinate/population) * 100
From PopvsVac


-- Temp Table

Drop Table If Exists #Percentage_Population_Vaccinated
Create Table #Percentage_Population_Vaccinated
(Continent nvarchar(255),
 Location nvarchar(255),
 date datetime,
 Population numeric,
 new_vaccinations numeric,
 rolling_people_vaccinated numeric)
 Insert Into #Percentage_Population_Vaccinated
 Select 
  dea.continent, 
  dea.location, 
  dea.date,
  dea.population,
  vac.new_vaccinations,
  sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated 
From Covid_Portfolio_Project..CovidDeaths$ as dea
Join
 Covid_Portfolio_Project..CovidVaccinations$ as vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 --order by 1,2,3
Select* , (rolling_people_vaccinated/population) * 100
From #Percentage_Population_Vaccinated
 


-- Creating View to store data for later Visualizations

Create View Percentage_Population_Vaccinated as
 Select 
  dea.continent, 
  dea.location, 
  dea.date,
  dea.population,
  vac.new_vaccinations,
  sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated 
From Covid_Portfolio_Project..CovidDeaths$ as dea
Join
 Covid_Portfolio_Project..CovidVaccinations$ as vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 --order by 1,2,3

 Select * 
 From Percentage_Population_Vaccinated

