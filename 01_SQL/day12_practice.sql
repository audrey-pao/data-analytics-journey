/*Find customers whose average order amount in 2026 is greater than the average order amount of all customers in 2026.*/

WITH CustomerAverages AS (
	SELECT c.customerID, c.name, AVG(o.amount) AS average
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE YEAR(o.orderDate) = 2026
	GROUP BY c.customerID, c.name
),

OverallAverage AS (
	SELECT AVG(average) AS oAverage
	FROM CustomerAverages
)

SELECT customerID, name, average, oAverage
FROM CustomerAverages
CROSS JOIN OverallAverage
WHERE average > oAverage

/*Find customers whose total 2026 spending is greater than the average total spending of customers in their country.  Assuming there is a country column in the Customers table*/

WITH CustomerTotalSpending AS (
	SELECT c.customerID
		c.name,
		c.country,
		SUM(o.amount) AS totalSpending
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE YEAR(o.orderDate) = 2026
	GROUP BY c.customerID, c.name, c.country
),

WITH CustomerCountryAverage AS (
	SELECT customerID, name, totalSpending, 
		AVG(totalSpending) OVER (PARTITION BY country) AS countryAvg
	FROM CustomerTotalSpending 
)

SELECT customerID, name, totalSpending, countryAvg
FROM CustomerCountryAverage
WHERE totalSpending > countryAvg

/*Find customers whose 2026 spending increased every month they placed an order, starting from their first order of the year.*/

WITH CustomerMonthlySpending AS (
	SELECT c.customerID, 
		c.name, 
		MONTH(o.orderDate) AS month, 
		SUM(o.amount) AS total
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE YEAR(o.OrderDate) = 2026
	GROUP BY c.customerID, c.name, MONTH(o.orderDate)

),

SpendingHistory AS (
	SELECT customerID, 
		name,
		month, 
		total,
		LAG(total) OVER (
			PARTITION BY customerID ORDER by month ASC) AS prvTotal 
	FROM CustomerMonthlySpending
),

MonthlyChanges AS (
	SELECT customerID,
		name,
		month,
		total,
		CASE WHEN total > prvTotal THEN 1 ELSE 0 END AS increasedFlag
	FROM SpendingHistory
)

SELECT customerID, name
FROM MonthlyChanges
GROUP BY customerID, name
HAVING COUNT(*) >= 2
AND SUM(increasedFlag) = COUNT(*) -1;

