-- Selecting data to get a view
SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM [dbo].[covid_deaths.csv]
WHERE continent is not null
ORDER BY 1,2

--Looking at total cases vs Total deaths
--shows likelyhood of dying if you contract covid in your country
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM [dbo].[covid_deaths.csv]
WHERE Location LIKE '%India%' AND
continent is not null
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of population got Covid
SELECT Location,date,total_cases,Population,(total_cases/population)*100 AS case_percentage
FROM [dbo].[covid_deaths.csv]
WHERE continent is not null
ORDER BY 1,2

--Looking at countries with highest infection rate compared with population
SELECT Location,MAX(total_cases) AS highest_infection_count,Population,ROUND(MAX((total_cases/population))*100,2) AS Percentpopulation_infected
FROM [dbo].[covid_deaths.csv]
WHERE continent is not null
GROUP BY Location,Population
ORDER BY Percentpopulation_infected DESC

--Showing countries with highest death count per population
SELECT Location,MAX(total_deaths) AS Total_death_count
FROM [dbo].[covid_deaths.csv]
WHERE continent is not null
GROUP BY Location
ORDER BY Total_death_count DESC

--Looking at highest death count by Continent
SELECT continent,MAX(total_deaths) AS Total_death_count
FROM [dbo].[covid_deaths.csv]
WHERE continent is not null
GROUP BY continent
ORDER BY Total_death_count DESC

--Global numbers

SELECT date, SUM(new_cases) AS total_cases,SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM [dbo].[covid_deaths.csv]
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Looking at Total population vs Vaccination

SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM [dbo].[covid_deaths.csv] dea
JOIN [dbo].[covid_vaccination$] vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null
order by 5 DESC

--with CTE

With PopvsVac (Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM [dbo].[covid_deaths.csv] dea
JOIN [dbo].[covid_vaccination$] vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null)
SELECT * FROM PopvsVac

--Create View to store data for later visualizations

CREATE VIEW PercentPeopleVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM [dbo].[covid_deaths.csv] dea
JOIN [dbo].[covid_vaccination$] vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null
--order by 5 DESC

SELECT * FROM PercentPeopleVaccinated