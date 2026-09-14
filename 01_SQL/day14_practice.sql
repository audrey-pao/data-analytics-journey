/*Which customers placed at least 2 orders in 2026, and how much did each of them spend in 2026?*/

SELECT c.customerID,
	c.name,
	COUNT(o.orderID) AS num_order,
	SUM (o.totalAmount) AS total_spent
FROM Customers c
JOIN Orders o
ON c.customerID = o.customerID
WHERE YEAR(o.orderDate) = 2026
GROUP BY c.customerID, c.name
HAVING COUNT(o.orderID) >= 2;

/*Which customer spent the most money in 2026?*/

WITH CustomerTotal AS (
	SELECT c.customerID,
		c.name,
		SUM(o.totalAmount) AS total_spent
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE YEAR(o.orderDate) = 2026
	GROUP BY c.customerID, c.name	
),

CustomerRanking AS (
	SELECT customerID,
		name,
		total_spent,
		rank() OVER (
			ORDER BY total_spent DESC) AS ranking
		) AS ranking
FROM CustomerTotal

SELECT *
FROM CustomerRanking
WHERE ranking = 1;

/*For each customer who placed orders in 2026, calculate their total spending and rank them from highest to lowest spending.*/

WITH CustomerTotal AS (
	SELECT c.customerID, 
		c.name, 
		SUM(o.totalAmount) as total_spent
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE YEAR(o.orderDate) = 2026
	GROUP BY c.customerID, c.name
),

CustomerRanking AS (
	SELECT customerID,
		name,
		total_spent,
		rank() OVER (
			ORDER BY total_spent DESC)
	FROM CustomerTotal
),

SELECT customerID,
	name,
	total_spent,
	ranking
FROM CustomerRanking
ORDER BY ranking ASC;

/*Calculate the total sales for each month in 2026 and show the month, number of orders, and total sales.*/

number of order, total sales listed by month (1 = January) for 2026


SELECT DATENAME(MONTH, o.orderDate) AS month,
	COUNT(o.orderID) AS num_orders,
	SUM(o.totalAmount) AS total_sales
FROM Orders o
WHERE o.orderDate >= '2026-01-01'
	AND o.orderDate < '2027-01-01'
GROUP BY MONTH(o.orderDate)
ORDER BY MONTH(o.orderDate) ASC;


/*Which month had the highest total sales in 2026?*/
SELECT TOP 1
	DATENAME(MONTH, o.OrderDate) AS month,
	SUM(o.totalAmount) AS total_sales
FROM Orders o
WHERE o.orderDate >= '2026-01-01'
	AND o.orderDate < '2027-01-01'
GROUP BY MONTH(o.orderDate)
ORDER BY SUM(o.totalAmount) DESC;

/*Show me the top 3 customers by total spending in 2026. If there is a tie for 3rd place, include all customers tied for 3rd.
CTE 1 - customers and total spending for 2026
CTE 2 - add rankings to customers
final query - returns top 3 ranks
*/

WITH CustomerSpending AS (
	SELECT c.customerID,
		c.name,
		SUM(o.totalAmount) AS total_spent
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE o.orderDate >= '2026-01-01'
	AND o.orderDate < '2027-01-01'
	GROUP BY c.customerID, c.name
),

CustomerRanking AS (
	SELECT customerID,
		name,
		total_spent,
		RANK() OVER (
			ORDER BY total_spent DESC) AS ranking
	FROM CustomerSpending
)

SELECT customerID,
	name,
	total_spent,
	ranking
FROM CustomerRanking
WHERE ranking <= 3;



