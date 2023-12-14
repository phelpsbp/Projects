# Mint Classics Inventory Analysis

Mint Classics Company, a retailer of classic model cars and other vehicles, is looking to close one of its storage facilities. To make a data-based business decision, the company wants suggestions and recommendations for reorganizing or reducing inventory while maintaining timely customer service. As a data analyst, you will use MySQL Workbench to familiarize yourself with the general business by examining the current data and isolating and identifying those parts of the data that could be useful in deciding how to reduce inventory.

## Table of Contents

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Data Cleaning and Preparation](#data-cleaning-and-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Results and Findings](#results-and-findings)
- [Recommendations](#recommendations)

  
### Project Overview
---

Conducted exploratory analysis to investigate if there were any patterns or themes that may influence the reduction or reorganization of inventory in the Mint Classics storage facilities, and provided analytic insights and data-driven recommendations. 

### Data Sources

* [Mint Classics Dataset](https://d3c33hcgiwev3.cloudfront.net/2oM-7bPhQAK0DX4vqIQ_JQ_596ae3ede6934608af481acc56cb18f1_mintclassicsDB.sql?Expires=1701993600&Signature=dShvrtGJLsQD2jDNaa~4YrY9RMnItBt9vtQaxiN6PeFpDNgNMmnV3eu8q6RRgu66Mo9YmvipbRfHsgXCuLKOvraKCq7vbGuQN664xB5X8ot0~N-txScgkRcM5d2OYhUdoKy1jy6RCkTKQNX1afuYxThRPKe-klWcSlNfuyCuuf0_&Key-Pair-Id=APKAJLTNE6QMUY6HBC5A)
* [EER Diagram](https://github.com/phelpsbp/Projects/blob/main/Mint%20Classics%20Inventory%20Analysis/EER.jpg)

### Tools

Tools Used:
* MySQL Workbench - Data Analysis
* Excel - Pivot Tables and Visualizations
---
## Data Cleaning and Preparation

In the initial data preparation phase, we performed the following tasks:
1. Import the Classic Model Car Relational Database.
2. Examine the database structure via the EER to build familiarity with the business process.

## Exploratory Data Analysis

EDA involved exploring the products currently in inventory to answer key questions, such as:

- Which products have the lowest and highest order rates?
- Which product lines are most in demand?
- Which warehouses have the highest and lowest inventory stocks?
- Who are the top customers? 

## Data Analysis


### Order Frequencies
#### Individual Products
To start, let's look at the overall stock counts. Using the `mintclassics.products` and `mintclassics.orderdetails` tables, I'll take a look at the differences in inventory-to-order counts.

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
The query filters the results to show only those records where the inventory difference is greater than zero, indicating a positive difference (more in stock than ordered). The results are then ordered in descending order based on the inventory difference.

![top5_products_in_stock](https://github.com/phelpsbp/Projects/assets/150976820/da4f1f41-2d7c-4ac9-89f7-6ee0959b9f3f)

It looks like 2002 Suzuki XREO has the largest inventory difference, with 9997 currently in stock and only 1028 ordered overall. 
In the top 5 individual products with the highest stock-to-order difference, 4 of the products are cars and 1 is an airplane. 
Let's dig deeper into that. Are there any product lines that underperform or contribute to overstocking? 

#### Product Lines
Let's look at the product lines and their total inventories, quantity ordered, total earnings, and their stock-to-order ratios. 
```sql
SELECT
    	prd.productLine,
    	prl.textDescription as productLineDescription,
    	SUM(prd.quantityInStock) as inventoryTotal,
    	SUM(ord.quantityOrdered) as totalOrdered,
    	SUM(ord.priceEach * ord.quantityOrdered) as totalEarnings,
    	(SUM(ord.quantityOrdered) / SUM(prd.quantityInStock)) * 100 as inventoryDifferencePercentage
FROM
	mintclassics.products as prd
LEFT JOIN
	mintclassics.productlines as prl on prl.productLine = prd.productLine
LEFT JOIN
	mintclassics.orderdetails as ord on prd.productCode = ord.productCode
GROUP BY 
	prd.productLine, prl.textDescription
order by 
	inventoryDifferencePercentage desc;
```
The order of these results is based on the order frequencies of the product line as whole, helping to identify which have a higher percentage of excess inventory or unmet demand. 

<img src="https://github.com/phelpsbp/Projects/assets/150976820/ccf06c2a-677f-47ae-b216-3327a89008f0"/><img src="https://github.com/phelpsbp/Projects/assets/150976820/57e112e7-bcc3-4633-80da-11b53ec5783d"/>

It appears that while 4 of the 5 products with the highest amount of stock were classic cars, they are also the most ordered product line with significantly higher earnings than any other product line, indicating their inventory numbers are meeting demands. 
Ships and trains have very low order rates, with trains making up only 2.67% of all orders. The low amount of orders coupled with a 0.62% stock-to-order rate suggests that, despite the relatively low demand indicated by the quantity of orders, there is a possibility of an overstock of trains. 

### Warehouses

Let's take a look at data related to product inventory across different warehouses. I'll be looking at which warehouses have both the highest and lowest inventories.
#### Individual Products in Each Warehouse

```sql
SELECT
	prd.productName,
    	wh.warehouseName,
    	SUM(prd.quantityInStock) AS inventoryTotal
FROM 
	mintclassics.products AS prd
JOIN
	mintclassics.warehouses AS wh ON prd.warehouseCode = wh.warehouseCode
GROUP BY 
	prd.productName, wh.warehouseName
ORDER BY
	inventoryTotal asc;
```
The results show a list of products along with their corresponding warehouse names and the total quantity in stock for each product in each warehouse. The ordering is based on the ascending total inventory, meaning that the products with the lowest inventory across all warehouses appear first.

| ![Screenshot 2023-12-14 121215](https://github.com/phelpsbp/Projects/assets/150976820/b3b64170-5087-4adb-af0d-e61778c73887)| 
|:--:| 
| Pivot Table from the results of the query examining individual product stocks in each warehouse. The Pivot Table shows stock totals by warehouse |

It looks like the Southern Warehouses have the lowest inventory overall. 
To validate the pivot table findings, I'm going to run a query for warehouse stock totals overall.
#### Overall Stock Totals
```sql
SELECT
	wh.warehouseCode,
    	wh.warehouseName,
    	SUM(prd.quantityinStock) as stockTotal
FROM
	mintclassics.warehouses as wh
LEFT JOIN 
	mintclassics.products as prd on wh.warehouseCode = prd.warehouseCode
GROUP BY 
	wh.warehouseCode,
    	wh.warehouseName
order by 
	stockTotal desc;
```
![Screenshot 2023-12-14 123455](https://github.com/phelpsbp/Projects/assets/150976820/50b88e20-ff34-4118-9f23-6be15589e932)![Screenshot 2023-12-14 123055](https://github.com/phelpsbp/Projects/assets/150976820/2adbe1b7-7a6a-40f6-beab-e67caee61bfb)

The results show how the inventory is distributed across different warehouses.
The query validated that the Southern warehouses have the lowest overall inventory and Eastern Warehouses have the highest. 
Low inventory could allude to: 
1) high demand, quick turnover rates, or efficient supply chain managment.
or
2) slow turnover rate if the products are in low demand.

#### Southern Warehouse
To check for possible underlying reasons, I'm going to create a pivot table showing the specific items in stock in the Southern Warehouse. 
![Screenshot 2023-12-14 165105](https://github.com/phelpsbp/Projects/assets/150976820/9432be96-6371-4311-b52c-d90f3ebf3406)

Looks like the Southern Warehouse has inventory consisting primarily of the three product lines with the slowest turnover rates - Trucks and Buses, Ships, and Trains. 
Let's take a peak at the inventory in the Eastern Warehouse.

#### Eastern Warehouse

![Screenshot 2023-12-14 170108](https://github.com/phelpsbp/Projects/assets/150976820/8d59e585-6f08-456c-b9ef-bde45f0e62dc)

The Eastern Warehouse holds cars, which we know from previous queries have high inventory due to high demand. 


### Customers vs. Sales Amounts
Who are the top customers? To retrieve insights into customers and their spending habits, I'll be using their customer number, customer name, payment date, and the total earnings for the company associated with each payment. 

```sql
SELECT
	cmr.customerNumber,
	cmr.customerName,
    	pmt.paymentDate,
    	pmt.amount AS totalEarnings
FROM
	mintclassics.customers AS cmr
LEFT Join
	mintclassics.payments as pmt on cmr.customerNumber = pmt.customerNumber
order by
	totalEarnings desc;
```
|![Screenshot 2023-12-14 131242](https://github.com/phelpsbp/Projects/assets/150976820/e490bae5-6267-4621-9e84-0394e19f31ec)![Screenshot 2023-12-14 132411](https://github.com/phelpsbp/Projects/assets/150976820/a66f96a2-f057-4bda-a625-47c79f65f9cb)| 
|:--:| 
| The results are ordered by total earnings in descending order, meaning the customers who have spent the most are listed at the top of the table. These pivot tables show that Euro+ Shopping Channel and Mini Gifts Distributors Ltd. make up a majority of the company's sales |

## Results and Findings
The key findings are summarized as follows:
1. Trucks and Buses, Ships, and Trains were the three least ordered product lines. 
2. Trains made up only 2.67% of all orders made. Coupled with a low order frequency of 0.62%, this alludes to an overstock due to low consumer demands.
3. Southern Warehouses had low overall inventory with the inventory consisting of very slow selling product-lines.
4. The Eastern Warehouse had the highest stock levels consisting of classic model cars that are high in demand. 

## Recommendations
1. **Product Line Adjustment:**
* Consider reducing the inventory of product lines with low demand, such as Trucks and Buses, Ships, and Trains. This could involve offering promotions, bundling, or marketing strategies to boost sales.
* Allocate more resources and space to product lines with higher demand, like Classic Cars, which are top-sellers.
  
2. **Warehouse Optimization**:
* Evaluate the performance of Southern Warehouses and consider redistributing slow-moving products to other locations to ensure efficient space utilization.
* Explore the possibility of consolidating or closing Southern Warehouses if their low inventory is consistently due to slow-selling products.

3. **Customer Loyalty Programs**
* Tailor promotions or incentives that encourage repeat business.
* Consider exclusive offers for high-value customers to maintain their patronage.




---
