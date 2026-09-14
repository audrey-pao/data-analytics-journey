/*Find customers who placed an order in both January and February 2026. Show the customer's ID, name, and the number of orders they placed during those two months.
*/
SELECT c.customerID,
       c.name,
       COUNT(o.orderID) AS num_orders
FROM Customers c
JOIN Orders o
    ON c.customerID = o.customerID
WHERE o.orderDate >= '2026-01-01'
  AND o.orderDate < '2026-03-01'
GROUP BY c.customerID, c.name
HAVING COUNT(DISTINCT MONTH(o.orderDate)) = 2;

/*Find customers who placed an order in January 2026 but did NOT place an order in February 2026.*/

SELECT c.customerID, 
	c.name, 
	COUNT(o.orderID) AS num_of_orders
FROM Customers c
JOIN Orders o
ON c.customerID = o.customerID
WHERE o.orderDate >= '01-01-26'
AND o.orderDate < '02-01-26'
AND NOT EXISTS (SELECT 1 FROM orders o2
		WHERE c.customerID = o2.customerID
		AND o2.orderDate >= '02-01-26'
		AND o2.orderdate < '03-01-26'
		) 
GROUP BY c.customerID, c.name;

/*Find customers who placed 3 or more orders in 2026.

Show:

customer ID
customer name
number of orders
total amount spent

Sort by total amount spent, highest to lowest*/

SELECT c.customerID,
	c.name,
	COUNT(o.orderID) AS num_orders,
	SUM(o.totalAmount) AS total_spent
FROM customers c
JOIN Orders o
ON c.customerID = o.customerID
WHERE o.orderDate >= '2026-01-01'
AND o.orderDate < '2027-01-01'
GROUP BY c.customerID, c.name
HAVING COUNT(o.orderID) >= 3
ORDER BY SUM(o.totalAmount) DESC;

/*Find customers who did not place any orders in 2026.*/

SELECT c.customerID, 
	c.name, 
	c.city
FROM Customers c
WHERE NOT EXISTS (SELECT 1 
		FROM Orders o
		WHERE c.customerID = o.customerID
		AND o.orderDate >= '2026-01-01'
		AND o.orderDate < '2027-01-01'); 

/*Find customers whose total spending in 2026 was greater than the average spending of all customers who placed orders in 2026.

CTE 1 - find the total of every customer in 2026
CTE 2 - find the average of total spending of each customer
final query cross join and select customer whose total > average*/

WITH CustomerTotal2026 AS (
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

CustomerAvg2026 AS (
	SELECT AVG(total_spent) AS avg_spent
	FROM CustomerTotal2026
)

SELECT customerID, 
	name, 
	total_spent
FROM CustomerTotal2026
CROSS JOIN CustomerAvg2026
WHERE total_spent > avg_spent;




