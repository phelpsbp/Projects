--  AMOUNT IN STOCK VS. AMOUNT ORDERED --
-- Ordering from greatest to least based on inventory stock vs. orders placed for each product --


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
    
    
--  AMOUNT IN STOCK VS AMOUNT ORDERED - PRODUCT LINE --
    
    
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
    
    
    
-- WAREHOUSES WITH HIGHEST/LOWEST PRODUCT INVENTORIES  --
-- 1. Looking at individual products in each warehouse --   
    
    
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
    
    
-- 2. Looking at the total inventory overall, in each warehouse -- 


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
    
    
    
-- HIGHEST PRICING VS. AMOUNT ORDERED --    
-- 1. Checking for items that costs the most -- 


SELECT 
	prd.productCode,
    prd.productName,
    prd.buyPrice,
    SUM(ord.quantityOrdered) as totalOrdered
FROM
	mintclassics.products as prd
LEFT JOIN 
	mintclassics.orderdetails as ord on prd.productCode = ord.productCode
GROUP BY 
	prd.productCode, prd.productName, prd.buyPrice
order by 
	buyPrice desc;
    
    

-- TOP CUSTOMERS -- 
-- 1. Customers vs. Sales Amounts --

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
    
    
-- 2. Customer Credit: Debt vs. Amount paid --


SELECT
	cmr.customerNumber,
    cmr.customerName,
    cmr.creditLimit,
    SUM(pmt.amount) as amountPaid,
    (SUM(pmt.amount) - cmr.creditLimit) AS creditDifference
FROM
	mintclassics.customers as cmr
LEFT JOIN
	mintclassics.payments as pmt on cmr.customerNumber = pmt.customerNumber
GROUP BY
	cmr.customerNumber, cmr.creditLimit
HAVING
	SUM(pmt.amount) < cmr.creditLimit
order by
	amountPaid asc;
