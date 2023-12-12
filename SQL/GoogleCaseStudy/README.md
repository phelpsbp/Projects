* [Data Analysis](https://github.com/phelpsbp/Project-Files/blob/main/SQL/GoogleCaseStudy/Data%20Analysis)
* [Full Published Case Study](https://phelpsbp.github.io/cyclistic-case-study-project.html)
* [Power BI Dashboard](https://app.powerbi.com/view?r=eyJrIjoiNDY5Y2NkYWYtY2M0Zi00YTJkLWE5MjQtMTBhMmU5ZjA0NGNiIiwidCI6IjM1NWI3MWIwLWEyMDQtNGMyMC05NzQ3LTVlYTU3OTQyNzkxZCIsImMiOjJ9)


# Bike-Share Case Study

## Table of Contents

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Recommendations](#recommendations)

### Project Overview
---

This data analysis project aims to produce insights into customer trends for a bike-share compnay, Cyclistic. By analyzing historical bike trip data, we seek to produce professional data visualizations, along with recommendations for marketing strategies, aimed at converting casual riders to annual members for future revenue and growth.

![bar plot](https://github.com/Irene-arch/Documenting_Example/assets/56026296/5ebedeb8-65e4-4f09-a2a5-0699119f5ff7)


### Data Sources

The [data](https://divvy-tripdata.s3.amazonaws.com/index.html) is made available by Motivate International Inc. under this [license](https://divvybikes.com/data-license-agreement). This is a public data set and there is no personal user information being shared. 


### Tools

- Excel - Data Cleaning
- Google BigQuery - Data Analysis
- PowerBI - Dashboard

---
## Data Cleaning/Preparation

In the initial data preparation phase, we performed the following tasks:
#### Cleaning in Excel:
1. Checked for and removed duplicates and nulls. 
2. Removed spacing using the TRIM() function.
3. Changed time format in ride_length to 37:30:55.
4. Created new "day_of_week" column using the WEEKDAY() function and formatted it as a number with no decimals(1=Sunday, 7=Saturday).
5. Created "ride_month" with 1-12 representing January-December respectively.
6. Loaded each month's CSV file into Google Cloud as a bucket then imported them into BigQuery.

#### Preparation in BigQuery
1. Created a new dataset titled [alldata](https://github.com/phelpsbp/Project-Files/blob/main/SQL/GoogleCaseStudy/alldata.csv) using the UNION ALL function.
2. Created a new master dataset, [summary_table](https://github.com/phelpsbp/Project-Files/blob/main/SQL/GoogleCaseStudy/summary_table.csv), to get rid of unnecesary columns.
3. Made the following changes for a clearer understanding of column names:
   * rideable_type --> bike_type
   * member_casual --> customer_type
4. Used table aggregation using the WITH agg_table AS function to extract ride_duration in minutes through the DATETIME_DIFF function.
5. Replaced all numeric values in day_of_week and ride_month columns with their corresponding names using the CASE, WHEN function.

```sql
     WITH
          agg_table AS
          (SELECT
            * EXCEPT (day_of_week),
            DATETIME_DIFF(ended_at, started_at, minute) AS ride_duration,
            EXTRACT(month
            FROM
              started_at) AS ride_month,

       CASE
              WHEN day_of_week = 1 THEN "Sunday"
              WHEN day_of_week = 2 THEN "Monday"
              WHEN day_of_week = 3 THEN "Tuesday"
              WHEN day_of_week = 4 THEN "Wednesday"
              WHEN day_of_week = 5 THEN "Thursday"
              WHEN day_of_week = 6 THEN "Friday"
            ELSE
            "Saturday"
          END
            AS day_of_week
          FROM
            `capstone-403818.months_2021.alldata`),

       month_name as
          (select
            * EXCEPT (ride_month),
            CASE
              WHEN ride_month = 1 THEN "Jan"
              WHEN ride_month = 2 THEN "Feb"
              WHEN ride_month = 3 THEN "Mar"
              WHEN ride_month = 4 THEN "Apr"
              WHEN ride_month = 5 THEN "May"
              WHEN ride_month = 6 THEN "Jun"
              WHEN ride_month = 7 THEN "Jul"
              WHEN ride_month = 8 THEN "Aug"
              WHEN ride_month = 9 THEN "Sept"
              WHEN ride_month = 10 THEN "Oct"
              WHEN ride_month = 11 THEN "Nov"
              WHEN ride_month = 12 THEN "Dec"
          END
            AS month_name
          FROM
            `capstone-403818.VisualizationTables.summary_table`),
```

## Exploratory Data Analysis

EDA involved exploring the service usage data to answer key questions, such as:

- What are the overall bike usage trends?
- Which bikes are used most?
- When are the peak bike usage periods?
- Which bike stations are most frequented?

## Data Analysis

*Note: All data is grouped by customer type. There was a type within the data tables. "costumer_type" was corrected to "customer_type"*

### Examining the differences total trips taken 
#### Total Trips Overall: 

```sql
SELECT 
  costumer_type,
  COUNT(*) AS total_trips
FROM `capstone-403818.VisualizationTables.summary_table`
GROUP BY costumer_type
ORDER BY costumer_type;

SELECT 
  costumer_type,
  bike_type,
  COUNT(*) AS total_trips
FROM 
  `capstone-403818.VisualizationTables.summary_table`
GROUP BY 
  costumer_type, bike_type
ORDER BY 
  costumer_type, total_trips;

SELECT 
  costumer_type,
  ride_month,
  COUNT(ride_id) AS total_trips
FROM 
  `capstone-403818.VisualizationTables.summary_table`
GROUP BY 
  costumer_type, ride_month
ORDER BY 
  ride_month;

SELECT 
  costumer_type,
  day_of_week,
  COUNT(ride_id) AS total_trips
FROM 
  `capstone-403818.VisualizationTables.summary_table`
GROUP BY 
  costumer_type, day_of_week
ORDER BY 
  day_of_week;

SELECT 
  EXTRACT(HOUR FROM started_at) AS hour,
  COUNT(started_at) AS total_rides,
  costumer_type
FROM 
  `capstone-403818.VisualizationTables.summary_table`
GROUP BY 
  hour, costumer_type
ORDER BY 
  hour;
```

ii. 

### Results/Findings

The analysis results are summarized as follows:
1. The company's sales have been steadily increasing over the past year, with a noticeable peak during the holiday season.
2. Product Category A is the best-performing category in terms of sales and revenue.
3. Customer segments with high lifetime value (LTV) should be targeted for marketing efforts.

### Recommendations

Based on the analysis, we recommend the following actions:
- Invest in marketing and promotions during peak sales seasons to maximize revenue.
- Focus on expanding and promoting products in Category A.
- Implement a customer segmentation strategy to target high-LTV customers effectively.

### Limitations

I had to remove all zero values from budget and revenue columns because they would have affected the accuracy of my conclusions from the analysis. There are still a few outliers even after the omissions but even then we can still see that there is a positive correlation between both budget and number of votes with revenue.

### References

1. SQL for Businesses by werty.
2. [Stack Overflow](https://stack.com)

😄

💻

|Heading1|Heading2|
|--------|--------|
|Content|Content2|
|Python|SQL|

`column_1`

**bold**

*italic*
