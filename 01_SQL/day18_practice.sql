/* Find customers who placed an order in at least 3 different months during 2026.

Return:

customerID
name
numberOfMonths
totalSpent

Sort by numberOfMonths descending, then totalSpent descending.

1.  Final query returns customers who placed at orders in at least 3 different months in 2026
2.  Customers and Orders
3.  SUM aggregate, group by customer, month
4.  CTE 1 - returns customer and total spent each month in 2026
5.  Final query sum the total for each month and do a count of months and restricted to those with orders in 3 or more months.

*/

SELECT c.customerID,
	c.name,
	COUNT(DISTINCT MONTH(o.orderDate)) AS numOfMonths,
	SUM(o.totalAmount) AS totalSpent
FROM Customers c
JOIN Orders o
ON c.customerID = o.customerID
WHERE o.orderDate >= '2026-01-01'
AND o.orderDate < '2027-01-01'
GROUP BY c.customerID, c.name
HAVING COUNT(DISTINCT MONTH(o.orderDate)) >= 3
order by numOfMonths DESC, totalSpent DESC

/*Find customers who placed orders in both the first half and second half of 2026.

For this exercise:

First half: January 1 – June 30
Second half: July 1 – December 31
A customer must have at least one order in each half.
Return:
customerID
name
firstHalfSpent
secondHalfSpent
totalSpent
Sort by totalSpent descending.

1. Final query returns a customer who place an order in first half and 2nd half
2. Customers & Orders
3. Aggregate-Sum, group by customers
4. 2 CTE, one for each half
5. Final query joins them, SUM the total

*/

WITH CustomerFirstHalf AS (
	SELECT c.customerID,
		c.name,
		SUM(o.totalAmount) AS firstHalfSpent
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE o.orderDate >= '2026-01-01'
	AND o.orderDate < '2026-07-01'
	GROUP BY c.customerID, c.name
),

CustomerSecondHalf AS (
	SELECT c.customerID,
		c.name,
		SUM(o.totalAmount) AS secondHalfSpent
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE o.orderDate >= '2026-07-01'
	AND o.orderDate < '2027-01-01'
	GROUP BY c.customerID, c.name
)

SELECT cf.customerID, 
	cf.name,
	cf.firstHalfSpent,
	cs.secondHalfSpent,
	cf.firstHalfSpent + cs.secondHalfSpent as totalSpent
FROM CustomerFirstHalf cf
JOIN CustomerSecondHalf cs
ON cf.customerID = cs.customerID
ORDER BY totalSpent DESC;

/*Find customers whose spending in the second half of 2026 was greater than their spending in the first half of 2026.

Return:

customerID
name
firstHalfSpent
secondHalfSpent
increase
percentIncrease

Where:

increase = second-half spending − first-half spending

percentIncrease = increase ÷ first-half spending × 100

1. Final query returns a customer row
2. 2 CTE for each half
3.  Calculate and filter in the final query


*/
WITH CustomerFirstHalf AS (
	SELECT c.customerID,
		c.name,
		SUM(o.totalAmount) AS firstHalfSpent
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE o.orderDate >= '2026-01-01'
	AND o.orderDate < '2026-07-01'
	GROUP BY c.customerID, c.name
),

CustomerSecondHalf AS (
	SELECT c.customerID,
		c.name,
		SUM(o.totalAmount) AS secondHalfSpent
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE o.orderDate >= '2026-07-01'
	AND o.orderDate < '2027-01-01'
	GROUP BY c.customerID, c.name
)

SELECT cf.customerID, 
	cf.name,
	cf.firstHalfSpent,
	cs.secondHalfSpent,
	cs.secondHalfSpent - cf.firstHalfSpent AS increase,
	((cs.secondHalfspent - cf.firstHalfSpent) * 1.0)/cf.firstHalfSpent * 100 AS percentIncrease
FROM CustomerFirstHalf cf
JOIN CustomerSecondHalf cs
ON cf.customerID = cs.customerID
WHERE cs.secondHalfSpent > cf.firstHalfSpent
AND cf.firstHalfSpent > 0
ORDER BY percentIncrease DESC;

/*Find customers who had a higher total spending than the previous month for two consecutive months during 2026.

Return:

customerID
name
month
total_spending
previous_month_spending

Only show the months where the customer's spending increased and that increase was part of two consecutive monthly increases.

Sort by customerID, then month.

1. Final query returns customers who had a higher total spending than the previous month for 2 consecutive monthly increase
2. Customers & Orders
3. SUM per month for each customers (SUM aggregate, group by customer and month
4. LAG for previous month spending
*/

WITH CustomerSpending AS (
	SELECT c.customerID,
		c.name,
		MIN(o.orderDate) AS date,
		MONTH(o.orderDate) AS monthNum,
		SUM(o.totalAmount) AS amount
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE o.orderDate >= '2026-01-01'
	AND o.orderDate < '2027-01-01'
	GROUP BY c.customerID, c.name, MONTH(o.orderDate)
),

CustomerHistory As (
	SELECT customerID,
		name,
		date,
		monthNum,
		amount,
		LAG(amount) OVER (PARTITION BY customerID ORDER BY monthNum) AS previousAmount,
		LAG(date) OVER (PARTITION BY customerID ORDER BY monthNum) AS previousDate,
		LAG(monthNum) OVER (PARTITION BY customerID ORDER BY monthNum) AS previousMonth
	FROM CustomerSpending	
),

ConsecutiveMonths AS (
	SELECT customerID,
		name,
		date,
		monthNum,
		amount,
		previousAmount,
		previousDate,
		previousMonth,
		LAG(previousAmount) OVER (PARTITION BY customerID ORDER BY monthNum) AS prv2Amount,
		LAG(previousDate) OVER (PARTITION BY customerID ORDER BY monthNum) AS prv2Date,
		LAG(previousMonth) OVER (PARTITION BY customerID ORDER BY monthNum) AS prv2Month
	FROM CustomerHistory
),

QualifyingCustomers AS (
	SELECT customerID,
		name,
		date,
		monthNum,
		previousMonth,
		amount AS totalSpending,
		previousAmount AS previousMonthSpending
	FROM ConsecutiveMonths
	WHERE amount > previousAmount
	AND  previousAmount > prv2Amount
	AND  monthNum = previousMonth + 1
	AND  previousMonth = prv2Month + 1		
)


SELECT customerID,
	name,
	FORMAT(date, 'yyyy-MM') AS month,
	totalSpending,
	previousMonthSpending
FROM QualifyingCustomers
ORDER BY customerID, month;


