SELECT * 
FROM dbo.covid_deaths;
SELECT *
FROM dbo.covid_vaccinations

-- Selecting relevant data for exploratory data analysis
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1,2;

SELECT location, date, new_tests,total_vaccinations,new_vaccinations
FROM covid_vaccinations
ORDER BY 1,2;

-- Finding potential KPIs like total cases, total deaths, and total vaccines administered
SELECT MAX(total_vaccinations) AS total_vaccines
FROM covid_deaths cd
JOIN covid_vaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date;

SELECT SUM(max_total_cases) AS total_cases
FROM (
    SELECT MAX(total_cases) AS max_total_cases
    FROM covid_deaths
    WHERE continent IS NOT NULL
    GROUP BY location
) AS max_cases_per_location;

SELECT SUM(max_total_deaths) AS total_deaths
FROM (
    SELECT MAX(total_deaths) AS max_total_deaths
    FROM covid_deaths
    WHERE continent IS NOT NULL
    GROUP BY location
) AS max_cases_per_location;

-- Comparing total cases vs. total deaths (%) in United States
SELECT location, date, total_cases, total_deaths, 
       CASE 
           WHEN total_cases > 0 THEN (total_deaths / total_cases) * 100 
           ELSE 0 
       END AS death_percentage
FROM covid_deaths
WHERE location = 'United States'
AND continent IS NOT NULL
ORDER BY 1, 2;

--Comparing total cases vs. total deaths(%) in India
SELECT location,date,total_cases,total_deaths,
	CASE
		WHEN total_cases>0 THEN (total_deaths/ total_cases)*100
		ELSE 0
	END AS death_percentage
FROM covid_deaths
WHERE location='India'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Comparing total cases vs population (%) in United States
SELECT location, date, population, total_cases, (total_cases/ population)*100 AS infection_rate
FROM covid_deaths
WHERE location = 'United States'
	AND continent IS NOT NULL
ORDER BY 1,2

-- Comparing total cases vs population (%) in India
SELECT location, date, population, total_cases, (total_cases/ population)*100 AS infection_rate
FROM covid_deaths
WHERE location = 'India'
	AND continent IS NOT NULL
ORDER BY 1,2

-- Displaying countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) as highest_cases, MAX((total_cases/ population))*100 AS infection_rate
FROM covid_deaths
GROUP BY location, population
ORDER BY infection_rate DESC

-- Sorting countries by the highest death count per population
SELECT location, MAX(total_deaths) AS Total_Death_Count
FROM covid_deaths
GROUP BY location
ORDER BY Total_Death_Count DESC;

-- Daily new cases and deaths for USA
SELECT date, new_cases, new_deaths
FROM covid_deaths
WHERE location = 'United States'
ORDER BY date;

-- Calculating the death percentage from all cases
SELECT  
    SUM(TRY_CAST(new_cases AS NUMERIC)) AS total_cases, 
    SUM(TRY_CAST(new_deaths AS NUMERIC)) AS total_deaths, 
    CASE WHEN SUM(TRY_CAST(new_cases AS NUMERIC)) > 0 THEN (SUM(TRY_CAST(new_deaths AS NUMERIC)) / SUM(TRY_CAST(new_cases AS NUMERIC))) * 100 ELSE NULL END AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY total_cases, total_deaths;

-- Comparing total population with total vaccinations using a rolling count
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location
	ORDER BY cd.location, cd.date) AS rtotal_vaccinations
FROM covid_deaths cd
JOIN covid_vaccinations cv
ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3
