# Mint Classics Inventory Analysis

Mint Classics Company, a retailer of classic model cars and other vehicles, is looking to close one of its storage facilities. To make a data-based business decision, the company wants suggestions and recommendations for reorganizing or reducing inventory while maintaining timely customer service. As a data analyst, you will use MySQL Workbench to familiarize yourself with the general business by examining the current data and isolating and identifying those parts of the data that could be useful in deciding how to reduce inventory.

## Table of Contents

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Data Cleaning and Preparation](#data-cleaning-and-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Table Merging](#table-merging)
- [Results and Findings](#results-and-findings)
- [Deliverables](#deliverables)

  
### Project Overview
---

Conducted exploratory analysis to investigate if there are any patterns or themes that may influence the reduction or reorganization of inventory in the Mint Classics storage facilities. Conducted a what-if analysis validating the effectiveness of a 5% inventory reduction. and provided analytic insights and data-driven recommendations. 

### Data Sources

* [Mint Classics Dataset](https://d3c33hcgiwev3.cloudfront.net/2oM-7bPhQAK0DX4vqIQ_JQ_596ae3ede6934608af481acc56cb18f1_mintclassicsDB.sql?Expires=1701993600&Signature=dShvrtGJLsQD2jDNaa~4YrY9RMnItBt9vtQaxiN6PeFpDNgNMmnV3eu8q6RRgu66Mo9YmvipbRfHsgXCuLKOvraKCq7vbGuQN664xB5X8ot0~N-txScgkRcM5d2OYhUdoKy1jy6RCkTKQNX1afuYxThRPKe-klWcSlNfuyCuuf0_&Key-Pair-Id=APKAJLTNE6QMUY6HBC5A)
* [EER](https://github.com/phelpsbp/Projects/blob/main/Mint%20Classics%20Inventory%20Analysis/EER.jpg)

### Tools

Tools Used:
* MySQL Workbench
---
## Data Cleaning and Preparation

In the initial data preparation phase, we performed the following tasks:
1. Import the Classic Model Car Relational Database.
2. Examine the database structure via the EER to build familiarity with the business process.

## Exploratory Data Analysis

EDA involved exploring the products currently in inventory to answer key questions, such as:

- Which individual products are the least ordered?
- Which individual products might be overstocked?
- Which product lines contribute to overstocking?
- Which warehouses have the highest and lowest inventory stocks?
- What the most expensive items in stock and does expense play a role in order frequency?
- Who are the top customers? Do their debt/credit ratios play a role?

## Data Analysis


### Order Frequencies

To start, let's look at the overall stock counts. Using the `mintclassics.products` and `mintclassics.orderdetails` tables, I'll take a look at which individual products have the highest inventory-to-order ratios.

```sql
SELECT
	productCode,
	productName,
	quantityInStock,
	totalOrdered,
	(quantityInStock - totalOrdered) As inventoryDifference
FROM
	( SELECT
		prd.productCode,
        prd.productName,
        prd.quantityInStock,
        SUM(ord.quantityOrdered) as totalOrdered
	FROM 
		mintclassics.products as prd
    LEFT JOIN 
		mintclassics.orderdetails as ord on prd.productCode = ord.productCode
	GROUP BY
		prd.productCode,
        prd.productName,
        prd.quantityInStock
	) as inventory_summary
WHERE 
	(quantityInStock - totalOrdered) > 0 
ORDER BY
	inventoryDifference DESC;
```

#### Total Cases vs. Population
```sql
select location, date, total_cases, population, 
(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2 
```

#### Infection Rates vs. Population

```sql
select location, population, max(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
-- Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc
```
#### Highest Death Counts
To calculate for maximum deaths, I converted `total_deaths` from nvarchar(255) to an interger using the `CAST` function.
```sql
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- Where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc
```

### COVID Data by Continent
I ran the same queries from examining the country data, but set the `SELECT` function to `continent` instead of `location`, and used `GROUP BY` to sort the data by continent instead of location (country).

## Table Merging
With the data obtained from the analysis, I'll be joining both datasets on `continent`, `location`, `date`, and `population`, as well as adding `new_vaccinations` to our new master dataset. 
```sql
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;
```

### CTE Table
To avoid getting the total sum of vaccinations and calculate a rolling count to represent vaccinations continuing over time, I partitioned by location **and** date. 
```sql
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, 
RollingPeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac
```
### Temp Table
The information resulted in an unorganized mess. To resolve this I tried commenting out "where `dea.continent` is not null" which resulted in an error due to the table already existing, whoops! Let's go ahead and use the `DROP TABLE` function to fix this. 
```sql
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated
```

## Results and Findings
### Global Numbers - Total Cases vs. Total Deaths
```sql
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2
```
![Screenshot 2023-11-28 170811](https://github.com/phelpsbp/Projects/assets/150976820/d57ef499-6bb8-49de-9c4a-8f193b1323cb)

### Continents with the Highest Death Counts
```sql
Select location, sum(cast(new_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is null
and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc
```
![Screenshot 2023-11-28 170830](https://github.com/phelpsbp/Projects/assets/150976820/a2899fce-8fc5-4674-9626-6c5d3932b3b3)

### Highest Infection Rates
```sql
select location, population, max(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
-- Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc
```
![Screenshot 2023-11-28 170902](https://github.com/phelpsbp/Projects/assets/150976820/72dde584-b52c-42e8-a3cc-f7ebaa2f210f)

### Highest Infection Rates by Country, Represented Over Time. 
```sql
select location, population, date, max(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
-- Where location like '%states%'
group by location, population, date
order by PercentPopulationInfected desc
```
![Screenshot 2023-11-28 171015](https://github.com/phelpsbp/Projects/assets/150976820/2fd630a5-8ba3-499f-9f1f-1966ed649849)
  
## Deliverables


The Full, interactive Tableau Dashboard can be viewed [here](https://public.tableau.com/app/profile/brittany.everette/viz/CovidDashboard_17001768757930/Dashboard1)
![Screenshot 2023-11-20 193802](https://github.com/phelpsbp/Projects/assets/150976820/f565cc5f-969d-422a-ae64-6387f5957573)




---
