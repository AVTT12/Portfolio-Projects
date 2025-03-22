SELECT * 
FROM coviddeaths
WHERE COALESCE(continent, '') != ''
ORDER BY 3,4;

/*SELECT *
FROM covidvaccinations
ORDER BY 3,4

select data we are going to be using
*/

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE COALESCE(continent, '') != ''
ORDER BY 1,2;

# Looking at Total cases vs Total Deaths
# Shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) as DeathPercentage
FROM coviddeaths
Where location like '%states%' and COALESCE(continent, '') != ''
ORDER BY 1,2;


#Looking at Total Cases vs Population
#Shows what percentage of population got covid



SELECT Location, date, total_cases, Population, (total_cases/population)* 100 as PercentPopulationInfected
FROM coviddeaths
#Where location like '%states%'
WHERE COALESCE(continent, '') != ''
ORDER BY 1,2;


# Looking at countries with hightest infection rates compared to population

SELECT Location, Population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentPopulationInfected
FROM coviddeaths
#Where location like '%states%'
WHERE COALESCE(continent, '') != ''
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc;


#Showing the countries with the highest death count per population

SELECT Location, MAX(cast(Total_deaths AS SIGNED)) as TotalDeathCount
FROM coviddeaths
#Where location like '%states%'
WHERE COALESCE(continent, '') != ''
GROUP BY Location
ORDER BY TotalDeathCount desc;

#Lets break things down by continent

SELECT continent, MAX(cast(Total_deaths AS SIGNED)) as TotalDeathCount
FROM coviddeaths
#Where location like '%states%'
WHERE COALESCE(continent, '') != ''
GROUP BY continent
ORDER BY TotalDeathCount desc;


#Showing the continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths AS SIGNED)) as TotalDeathCount
FROM coviddeaths
#Where location like '%states%'
WHERE COALESCE(continent, '') != ''
GROUP BY continent
ORDER BY TotalDeathCount desc;


# Global Numbers
SELECT  SUM(new_cases)as total_cases, SUM(cast(new_deaths as SIGNED)) as total_deaths, SUM(cast(new_deaths as SIGNED))/SUM(new_cases) * 100 as DeathPercentage
FROM coviddeaths
#Where location like '%states%' 
Where COALESCE(continent, '') != ''
#Group By date
ORDER BY 1,2;

#looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as signed)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
#,(RollingPeopleVaccinated
FROM coviddeaths dea
Join covidvaccinations_clean vac
	On dea.location = vac.location
    and dea.date = vac.date
Where COALESCE(dea.continent, '') != '' 
order by 2,3;


# USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as signed)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
#,(RollingPeopleVaccinated
FROM coviddeaths dea
Join covidvaccinations_clean vac
	On dea.location = vac.location
    and dea.date = vac.date
Where COALESCE(dea.continent, '') != '' 
#order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac;


#TEMP TABLE
Drop Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);



Insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as signed)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
#,(RollingPeopleVaccinated
FROM coviddeaths dea
Join covidvaccinations_clean vac
	On dea.location = vac.location
    and dea.date = vac.date
Where COALESCE(dea.continent, '') != '' ;
#order by 2,3


SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac;



-- creating view to store data for later visualizations 
Drop Table if exists PercentPopulationVaccinated;
create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as signed)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
#,(RollingPeopleVaccinated
FROM coviddeaths dea
Join covidvaccinations_clean vac
	On dea.location = vac.location
    and dea.date = vac.date
Where COALESCE(dea.continent, '') != '' ;
-- order by 2,3

SELECT *
FROM PercentPopulationVaccinated




