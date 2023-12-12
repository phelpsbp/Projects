# Cyclistic Bike-Share Case Study
**Google Capstone Project: Cyclistic Bike-Share Case Study**

In this case study, I am a junior data analyst on the Marketing Analytics Team for a company named Cyclistic Bike-Share. I have been assigned the analysis of historical bike trip data in order to identify trends. Using those trends, I am tasked to produce compelling data and professional data visualizations with insights and recommendations for marketing strategies to convert casual riders to annual members for future revenue and growth.

The [data](https://divvy-tripdata.s3.amazonaws.com/index.html) is made available by Motivate International Inc. under this [license](https://divvybikes.com/data-license-agreement). This is a public data set and there is no personal user information being shared. 

Tools Used:
* Excel
* SQL via BigQuery
* Power BI

Quick Links:
* [Data Merging](https://github.com/phelpsbp/Project-Files/blob/main/SQL/GoogleCaseStudy/Data%20Merging)
* [Data Cleaning](https://github.com/phelpsbp/Project-Files/blob/main/SQL/GoogleCaseStudy/Data%20Cleaning)
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


### Data Cleaning/Preparation

In the initial data preparation phase, we performed the following tasks:
1. Data loading and inspection.
2. Handling missing values.
3. Data cleaning and formatting.

### Exploratory Data Analysis

EDA involved exploring the sales data to answer key questions, such as:

- What is the overall sales trend?
- Which products are top sellers?
- What are the peak sales periods?

### Data Analysis

Include some interesting code/features worked with

```sql
SELECT * FROM table1
WHERE cond = 2;
```

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
