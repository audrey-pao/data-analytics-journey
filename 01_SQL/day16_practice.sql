/*Find the customer who spent the most money in 2026 in each city.

1.final queries should be customer/customers with the highest spending in each city in 2026
2. Customers table and Orders table
3. aggregate on totalamount per customer
4. window function, rank over city

*/

WITH CustomerTotalSpending2026 AS (
	SELECT c.customerID,
		c.name,
		c.city,
		SUM(o.totalAmount) AS totalSpent
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID	
	WHERE o.orderDate >= '2026-01-01'
	AND o.orderDAte < '2027-01-01'
	GROUP BY c.customerID, c.name, c.city
),

CustomerRank2026 AS (
	SELECT customerID,
		name,
		city,
		totalSpent,
		rank() OVER (
			PARTITION BY city
			ORDER BY totalSpent DESC) AS rank
		FROM CustomerTotalSpending2026
)

SELECT customerID,
	name,
	city,
	totalSpent
FROM CustomerRank2026
WHERE rank = 1;

/*The company wants to analyze how sales changed throughout 2026.

For each month in 2026, show:

month
total sales
previous month's total sales
difference in sales compared with the previous month

1. Final query returns, for each month the total spending.  
2. Orders
3. Use SUM Aggregate to calculate total for each month, group by customer and by month
4. Use windows function LAG on total spent to get previous months spent
5. calculate the difference  
*/

WITH MonthlySpending AS (
	SELECT MIN(orderDate) AS minDate,
		SUM (totalAmount) AS totalSales
	FROM Orders 
	WHERE orderdate >= '2026-01-01'
	AND orderDate < '2027-01-01'
	GROUP BY MONTH(orderDate)
),


SpendingHistory AS (
	SELECT minDate,
		totalSales,
		LAG (totalSales) OVER (ORDER BY minDate ASC) AS prvMonth
	FROM MonthlySpending


)

SELECT  DATENAME(MONTH, minDate) AS month,
	totalSales,
	prvMonth,
	(totalSales - prvMonth) AS difference 
FROM SpendingHistory;

/*
Find customers whose spending increased from January to February 2026.

Show:

customer ID
customer name
January spending
February spending
dollar increase

1. final query returns customers whose spending increased from January to February
2. Customers & Orders, filter by date >= '2026-01-01' < '2026-03-01'
3. Sum aggregate, group by customers and by month
4. LAG to get previous month
5. Check for total from Feb > Jan
*/

WITH CustomerSpending AS (
	SELECT c.customerID,
		c.name,
		MIN(o.orderDate) AS date,
		SUM(o.totalAmount) AS totalSpent		
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	where o.orderDate >= '2026-01-01'
	AND o.orderDate < '2026-03-01'
	GROUP BY c.customerID, c.name, MONTH(o.orderDate) 
),

CustomerSpendingHistory AS (
	SELECT customerID,
		name,
		date,
		totalSpent,
		LAG(totalSpent) OVER (PARTITION BY customerID ORDER BY date ASC) as prvMonth
	FROM CustomerSpending
)

SELECT customerID,
	name,
	totalSpent AS February,
	prvMonth AS January,
	totalSpent - prvMonth AS IncreasedAmount
FROM CustomerSpendingHistory
WHERE totalSpent > prvMonth
AND prvMonth IS NOT NULL;