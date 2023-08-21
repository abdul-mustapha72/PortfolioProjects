--DATA PREVIEW
SELECT 
	*
FROM 
	CovidDeaths$
ORDER BY 
	3,4

SELECT 
	*
FROM 
	CovidVaccinations$
ORDER BY 
	3,4


-- SELECTION OF DATA FOR USAGE

SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM 
	portfolioproject1..CovidDeaths$
ORDER BY 1, 2

-- Looking at total cases vs total deaths
-- This query shows likelihood of death after contraction

SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 
AS 
	Death_Percentage
FROM 
	portfolioproject1..CovidDeaths$
--WHERE 
--	location='Nigeria'
ORDER BY 
	1, 2

-- Looking at total cases vs population
-- Shows percentage of infected population

SELECT 
	location, 
	date, 
	total_cases, 
	population, 
	(total_cases/population)*100 
AS 
	Percentage_Population_Infected
FROM 
	portfolioproject1..CovidDeaths$
--WHERE 
--	location='Nigeria'
ORDER BY 
	1, 2

-- Looking at countries with highest infection rate compared to population

SELECT 
	location, 
	MAX(total_cases) 
AS 
	Highest_Infection_Count, 
	population, 
	MAX((total_cases/population))*100 
AS 
	Percentage_Population_Infected
FROM 
	portfolioproject1..CovidDeaths$
-- WHERE location='Nigeria'
GROUP BY 
	location, 
	population
ORDER BY 
	4 
DESC

-- Showing countries with the highest death count per population

SELECT 
	location, 
	MAX(CAST(total_deaths as int)) 
AS 
	Total_death_count
FROM 
	portfolioproject1..CovidDeaths$
WHERE 
	continent is not null
GROUP BY 
	location
ORDER BY 
	2 
DESC

-- Showing continents with the highest death count per population

SELECT 
	continent, 
	MAX	(
	CAST(total_deaths AS int)
		) 
AS 
	Total_death_count

FROM 
	portfolioproject1..CovidDeaths$
WHERE 
	continent is not null
GROUP BY 
	continent
ORDER BY 
	2 
DESC


--GLOBAL NUMBERS

SELECT 
	date, 
	SUM(new_cases) 
AS 
	SumOfNewCases, 
	SUM(CAST(new_deaths as int)) 
AS 
	SumOfNewDeaths, 
	(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 
AS 
	Percentage_death

FROM 
	portfolioproject1..CovidDeaths$
--WHERE location='Nigeria'
WHERE 
	continent is not null 
--AND new_cases is not null
GROUP BY 
	date
ORDER BY 
	2, 3

-- Looking at Total Population vs vaccination

SELECT	
	Death.continent, 
	Death.location, 
	Death.date, 
	Death.population, 
	Vacc.new_vaccinations, 
SUM(CONVERT(int, Vacc.new_vaccinations)) 
OVER 
(PARTITION BY 
	Death.location 
ORDER BY 
	Death.location, Death.date) 
AS 
	RollingPeopleVaccinated
FROM 
	portfolioproject1..CovidDeaths$ Death
JOIN 
	portfolioproject1..CovidVaccinations$ Vacc
ON	
	Death.location = Vacc.location
AND 
	Death.date = Vacc.date
WHERE 
	Death.continent is not null
ORDER BY 
	2, 3

--USING CTE

WITH PopVsVac	
		(continent, 
		location,
		date, 
		population, 
		new_vaccinations, 
		RollingPeopleVaccinated)
	AS
	(
	SELECT	
		Death.continent, 
		Death.location, 
		Death.date, 
		Death.population, 
		Vacc.new_vaccinations, 
	SUM(CONVERT(int, Vacc.new_vaccinations)) 
	OVER 
	(PARTITION BY 
		Death.location 
	ORDER BY 
		Death.location, Death.date) 
		as RollingPeopleVaccinated
	FROM 
		portfolioproject1..CovidDeaths$ Death
	JOIN 
		portfolioproject1..CovidVaccinations$ Vacc
	ON 
		Death.location = Vacc.location
	AND 
		Death.date = Vacc.date 
	WHERE 
		Death.continent is not null
)
	SELECT 
		*,
		(RollingPeopleVaccinated/population)*100
	FROM	
		PopVsVac

-- Using a TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE
		#PercentPopulationVaccinated
	(
		Continent nvarchar(255),
		location nvarchar(255),
		Date datetime,
		Population numeric,
		new_vaccinations numeric,
		RollingPeopleVaccinated numeric
	)

INSERT INTO #PercentPopulationVaccinated

SELECT	
		Death.continent, 
		Death.location, 
		Death.date, 
		Death.population, 
		Vacc.new_vaccinations, 
	SUM(CONVERT(int, Vacc.new_vaccinations)) 
	OVER 
	(PARTITION BY 
		Death.location 
	ORDER BY 
		Death.location, Death.date) 
		as RollingPeopleVaccinated
	FROM 
		portfolioproject1..CovidDeaths$ Death
	JOIN 
		portfolioproject1..CovidVaccinations$ Vacc
	ON 
		Death.location = Vacc.location
	AND 
		Death.date = Vacc.date 
	WHERE 
		Death.continent is not null
	
SELECT 
	*,
	(RollingPeopleVaccinated/population)*100
FROM	
	#PercentPopulationVaccinated

-- CREATING VIEW FOR LATER VISUALIZATION

CREATE VIEW 
	PercentPopulationVaccinated
AS
	SELECT	
		Death.continent, 
		Death.location, 
		Death.date, 
		Death.population, 
		Vacc.new_vaccinations, 
	SUM(CONVERT(int, Vacc.new_vaccinations)) 
	OVER 
	(PARTITION BY 
		Death.location 
	ORDER BY 
		Death.location, Death.date) 
		as RollingPeopleVaccinated
	FROM 
		portfolioproject1..CovidDeaths$ Death
	JOIN 
		portfolioproject1..CovidVaccinations$ Vacc
	ON 
		Death.location = Vacc.location
	AND 
		Death.date = Vacc.date 
	WHERE 
		Death.continent is not null
	
SELECT 
	*
FROM 
	PercentPopulationVaccinated