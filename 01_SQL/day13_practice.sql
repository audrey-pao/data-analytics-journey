/*Find customers who placed at least 3 orders in 2026, and whose average order amount is greater than the average order amount of all 2026 orders.*/
/*Find customers who had at least 3 consecutive months of increasing spending during 2026.*/
WITH MonthlySpending AS (
	SELECT c.customerID, 
		c.name, 
		MONTH(o.orderDate) AS month,
		SUM(o.amount) AS total 
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE YEAR(o.orderDate) = 2026
	GROUP BY c.customerID,
		c.name,
		MONTH(o.orderDate)
),

SpendingHistory AS (
	SELECT 	customerID, 
		name, 
		month,
		total,
		LAG(total) OVER (PARTITION BY customerID ORDER BY month) AS prevTotal
	FROM MonthlySpending
),

MonthlyChanges AS (
	SELECT customerID,
		name,
		month,
		total,
		prevTotal,
		CASE WHEN total > prevTotal THEN 1 ELSE 0 END AS increased
	FROM SpendingHistory
),

MonthlyHistory AS (
	SELECT customerID,
		name,
		month,
		total,
		prevTotal,
		increased,
		LAG(increased) OVER (PARTITION BY customerID ORDER BY month) as prevIncreased
	FROM MonthlyChanges
)

SELECT distinct customerID
FROM MonthlyHistory
WHERE increased = 1 AND prevIncreased = 1;


WITH CustomerAverage AS (
	SELECT c.customerID,
		c.name,
		COUNT(o.orderID) AS numberOfOrders,
		AVG(o.amount) AS averageAmount		
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE YEAR(o.orderDate) = 2026
	GROUP BY c.customerID, c.name
	HAVING COUNT(o.orderID) >= 3
),

OverallAverage AS (
	SELECT AVG(amount) AS overallAvg
	FROM Orders
	WHERE YEAR(orderDate) = 2026
)

SELECT customerID, name, numberOfOrders, averageAmount, overallAvg
FROM CustomerAverage
CROSS JOIN OverallAverage
WHERE averageAmount > overallAvg


/*Find the customer with the highest total spending in 2026 in each country. If two or more customers tie for the highest spending, return all of them.*/

WITH CustomerTotalSpending AS (
	SELECT c.customerID,
		c.name,
		c.country,
		SUM(o.amount) AS totalSpending
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE YEAR(o.orderDate) = 2026
	GROUP BY c.customerID, c.name, c.country
),

CountryHighestSpender AS (
	SELECT customerID,
		name, 
		country,
		totalSpending,
		RANK() OVER (
			PARTITION BY country
			ORDER BY totalSpending DESC
		)AS ranking 
	FROM CustomerTotalSpending
)

SELECT customerID, name, country, totalSpending
FROM CountryHighestSpender
wHERE ranking = 1

/*Find customers who placed at least 2 orders in 2026, and at least one of those orders was over $500.*/

WITH CustomerOrderCount AS (
	SELECT c.customerID, 
		c.name, 
		COUNT(o.orderID) AS num_order
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE YEAR(o.orderDate) = 2026
	GROUP BY c.customerID, c.name
	HAVING COUNT(o.orderID) >= 2
)

SELECT DISTINCT
	cc.customerID,
	cc.name,
	cc.num_order
FROM CustomerOrderCount cc
WHERE EXISTS (SELECT 1
		FROM Orders o
		WHERE o.customerID = cc.customerID)
		AND YEAR(o.orderDate) = 2026
		AND o.amount >= 500;

