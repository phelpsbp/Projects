-- WHAT IF --
-- What impact would it have on the company and customer service if we reduced inventory in stock by 5% for every product? --

-- 1. Checking product availability  --

SELECT 
	prd.productName,
    prd.productCode,
    prd.warehouseCode,
    SUM(prd.quantityInStock) as productAvailable
FROM
	mintclassics.products as prd
LEFT JOIN 
	mintclassics.warehouses as wh on wh.warehouseCode = prd.warehouseCode
GROUP BY 
	prd.productCode, prd.warehouseCode
order by 
	productAvailable desc;

-- Updating the quanitity by reducing it by 5% -- 

WITH CTE_Table AS (
    SELECT 
        prd.productName,
        prd.productCode,
        prd.warehouseCode,
        SUM(prd.quantityInStock) AS productAvailable
    FROM
        mintclassics.products AS prd
    LEFT JOIN 
        mintclassics.warehouses AS wh ON wh.warehouseCode = prd.warehouseCode
    GROUP BY 
        prd.productCode, prd.warehouseCode
    ORDER BY 
        productAvailable DESC
)
UPDATE mintclassics.products
SET quantityInStock = quantityInStock * 0.95
WHERE (productCode, warehouseCode) IN (
    SELECT productCode, warehouseCode FROM CTE_Table
);

SELECT 
	productCode,
    productName,
    warehouseCode,
    quantityInStock, 
    buyPrice,
    MSRP
FROM mintclassics.products;

    
    
 -- COMPARING SALES AFTER INVENTORY UPDATE -- 
 -- 1. AMOUNT IN STOCK VS. AMOUNT ORDERED -- 
 
SELECT
    productCode,
    productName,
    quantityInStock * 0.95 AS reducedQuantityInStock,
    totalOrdered,
    (quantityInStock * 0.95 - totalOrdered) AS inventoryDifference_after
FROM
    (SELECT
        prd.productCode,
        prd.productName,
        prd.quantityInStock,
        SUM(ord.quantityOrdered) AS totalOrdered
    FROM 
        mintclassics.products AS prd
    LEFT JOIN 
        mintclassics.orderdetails AS ord ON prd.productCode = ord.productCode
    GROUP BY
        prd.productCode,
        prd.productName,
        prd.quantityInStock
    ) AS inventory_summary
WHERE 
    (quantityInStock * 0.95 - totalOrdered) > 0 
ORDER BY
    inventoryDifference_after DESC;
    
    
-- 2. AMOUNT IN STOCK VS AMOUNT ORDERED - PRODUCT LINE --


SELECT 
    prd.productLine,
    prl.textDescription AS productLineDescription,
    SUM(prd.quantityInStock) * 0.95 AS reducedInventoryTotal,
    SUM(ord.quantityOrdered) AS totalOrdered,
    SUM(ord.priceEach * ord.quantityOrdered) AS totalEarnings,
    (SUM(ord.quantityOrdered) / SUM(prd.quantityInStock * 0.95)) * 100 AS inventoryDifferencePercentage_after
FROM
    mintclassics.products AS prd
LEFT JOIN
    mintclassics.productlines AS prl ON prl.productLine = prd.productLine
LEFT JOIN
    mintclassics.orderdetails AS ord ON prd.productCode = ord.productCode
GROUP BY 
    prd.productLine, prl.textDescription
ORDER BY 
    inventoryDifferencePercentage_after DESC;
    
    
 -- WAREHOUSES WITH HIGHEST/LOWEST PRODUCT INVENTORIES  --
-- 1. Looking at individual products in each warehouse --   

SELECT
    prd.productName,
    wh.warehouseName,
    SUM(prd.quantityInStock) * 0.95 AS reducedInventoryTotal
FROM 
    mintclassics.products AS prd
JOIN
    mintclassics.warehouses AS wh ON prd.warehouseCode = wh.warehouseCode
GROUP BY 
    prd.productName, wh.warehouseName
ORDER BY
    reducedInventoryTotal ASC;


-- 2. Looking at the total inventory overall, in each warehouse -- 

SELECT
    wh.warehouseCode,
    wh.warehouseName,
    SUM(prd.quantityinStock) * 0.95 AS reducedStockTotal
FROM
    mintclassics.warehouses AS wh
LEFT JOIN 
    mintclassics.products AS prd ON wh.warehouseCode = prd.warehouseCode
GROUP BY 
    wh.warehouseCode,
    wh.warehouseName
ORDER BY 
    reducedStockTotal DESC;
    
    
    
    -- HIGHEST PRICING VS. AMOUNT ORDERED --    
-- 1. Checking for items that costs the most -- 

 SELECT 
    prd.productCode,
    prd.productName,
    prd.buyPrice,
    SUM(ord.quantityOrdered) AS totalOrdered
FROM
    mintclassics.products AS prd
LEFT JOIN 
    mintclassics.orderdetails AS ord ON prd.productCode = ord.productCode
GROUP BY 
    prd.productCode, prd.productName, prd.buyPrice
ORDER BY 
    prd.buyPrice DESC;
    
    
    
-- TOP CUSTOMERS -- 
-- 1.. Customers vs. Sales Amounts --

SELECT
    cmr.customerNumber,
    cmr.customerName,
    pmt.paymentDate,
    pmt.amount * 0.95 AS reducedTotalEarnings
FROM
    mintclassics.customers AS cmr
LEFT JOIN
    mintclassics.payments AS pmt ON cmr.customerNumber = pmt.customerNumber
ORDER BY
    reducedTotalEarnings DESC;
    
    
-- 2. Customer Credit: Debt vs. Amount paid --

SELECT
    cmr.customerNumber,
    cmr.customerName,
    cmr.creditLimit,
    SUM(pmt.amount * 0.95) AS reducedAmountPaid,
    (SUM(pmt.amount * 0.95) - cmr.creditLimit) AS reducedCreditDifference
FROM
    mintclassics.customers AS cmr
LEFT JOIN
    mintclassics.payments AS pmt ON cmr.customerNumber = pmt.customerNumber
GROUP BY
    cmr.customerNumber, cmr.creditLimit
HAVING
    SUM(pmt.amount * 0.95) < cmr.creditLimit
ORDER BY
    reducedAmountPaid ASC;
 
 