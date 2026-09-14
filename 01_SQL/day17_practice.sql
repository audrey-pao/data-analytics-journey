/*Find customers whose spending increased from January to February 2026 by at least $50.

Show:

Customer ID
Customer name
January spending
February spending
Dollar increase

Only include customers who had spending in both January and February.

1. final query returns customers whose spending increased by at least $50 from January to February
2. Customers & Orders, filter by date >= '2026-01-01' < '2026-03-01'
3. Sum aggregate, group by customers and by month
4. LAG to get previous month
5. Check for total from Feb > Jan by at least $50
6. Check that customer had spending in both Jan and February, meaning jan amount cannot be NULL


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
	totalSpent - prvMonth AS dollarIncrease
FROM CustomerSpendingHistory
WHERE totalSpent - prvMonth >= 50 
AND prvMonth IS NOT NULL;


/*Find customers whose spending increased every month from January through May 2026.

Show:

Customer ID
Customer name
January spending
February spending
March spending
April spending
May spending
Rules

A customer must:

Have spending in all five months.
Have spending that increases each month:
February > January
March > February
April > March
May > April

1. final query returns customers whose spending increase every month from January to May of 2026
2. customers & orders
3. Sum aggregate, group by customerID, name, and month
4. LAG to get previous month spending, add an increase Flag
5. LAG on increase to get prv increase, loop the lag until we get all the months
6. Query for customers that has increased every month

*/

WITH CustomerSpending AS (
	SELECT c.customerID,
		c.name,
		MIN(o.orderDate) AS date,
		SUM(o.totalAmount) AS amount		
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	where o.orderDate >= '2026-01-01'
	AND o.orderDate < '2026-06-01'
	GROUP BY c.customerID, c.name, MONTH(o.orderDate) 
),

CustomerSpendingPrvMonth AS (
	SELECT customerID,
		name,
		date,
		amount,
		LAG(amount) OVER (PARTITION BY customerID ORDER BY date DESC) AS prvAmount
	FROM CustomerSpending
),

CustomerSpendingPrvMonthIncInd AS (
	SELECT customerID,
		name,
		date,
		amount,
		prvAmount,
		CASE WHEN amount - prvAmount > 0 THEN 1 ELSE 0 END AS incFlag1
	FROM CustomerSpendingPrvMonth

),

CustomerSpendingPrv2Month AS (
	SELECT customerID,
		name,
		date,
		amount,
		prvAmount,
		incFlag1,
		LAG(prvAmount) OVER (PARTITION BY customerID ORDER BY date DESC) as prv2Amount
	FROM CustomerSpendingPrvMonthIncInd
),

CustomerSpendingPrv2MonthIncInd AS (
	SELECT customerID,
		name,
		date,
		amount,
		prvAmount,
		incFlag1,
		prv2Amount,
		CASE WHEN prvAmount - prv2Amount > 0 THEN 1 ELSE 0 END AS incFlag2
	FROM CustomerSpendingPrv2Month
),

CustomerSpendingPrv3Month AS (
	SELECT customerID,
		name,
		date,
		amount,
		prvAmount,
		incFlag1,
		prv2Amount,
		incFlag2,
		LAG (prv2Amount) OVER (PARTITION BY customerID ORDER BY date DESC) as prv3Amount
	FROM CustomerSpendingPrv2MonthIncInd
),

CustomerSpendingPrv3MonthIncInd AS (
	SELECT customerID,
		name,
		date,
		amount,
		prvAmount,
		incFlag1,
		prv2Amount,
		incFlag2,
		prv3Amount,
		CASE WHEN prv2Amount - prv3Amount > 0 THEN 1 ELSE 0 END AS incFlag3
	FROM CustomerSpendingPrv3Month
),

CustomerSpendingPrv4Month AS (
	SELECT customerID,
		name,
		date,
		amount,
		prvAmount,
		incFlag1,
		prv2Amount,
		incFlag2,
		prv3Amount,
		incFlag3,
		LAG (prv3Amount) OVER (PARTITION BY customerID ORDER BY date DESC) as prv4Amount
	FROM CustomerSpendingPrv3MonthIncInd
),

CustomerSpendingPrv4MonthIncInd AS (
	SELECT customerID,
		name,
		date,
		amount,
		prvAmount,
		incFlag1,
		prv2Amount,
		incFlag2,
		prv3Amount,
		incFlag3,
		prv4Amount,
		CASE WHEN prv3Amount - prv4Amount > 0 THEN 1 ELSE 0 END AS incFlag4
	FROM CustomerSpendingPrv4Month
)

/* SELECT customerID,
	name,
	prv4Amount AS January,
	prv3Amount AS February,
	prv2Amount AS March,
	prvAmount AS April,
	amount AS May
FROM CustomerSpendingPrv4MonthIncInd
WHERE incFlag1 = 1
AND incFlag2 = 1
AND incFlag3 = 1
AND incFlag4 = 1;*/


SELECT customerID,
	name,
	prv4Amount AS January,
	prv3Amount AS February,
	prv2Amount AS March,
	prvAmount AS April,
	amount AS May
FROM CustomerSpendingPrv4MonthIncInd
WHERE incFlag1 + incFlag2 + incFlag3 + incFlag4 = 4;  



/*Better solution, more concise and less complicated*/
WITH CustomerSpending AS (
	SELECT c.customerID,
		c.name,
		MONTH(o.orderDate) AS monthNum,
		SUM(o.totalAmount) AS amount
	FROM Customers c
	JOIN Orders o
	ON c.customerID = o.customerID
	WHERE o.orderDate >= '2026-01-01'
	AND o.orderDate < '2026-06-01'
	GROUP BY c.customerID, c.name, MONTH(o.orderDate)
),

CustomerHistory AS (
	SELECT customerID,
		name,
		monthNum,
		amount,
		LAG(amount) OVER (PARTITION BY customerID ORDER BY monthNum) AS previousAmount,
		LAG(monthNum) OVER (PARTITION BY customerID ORDER BY monthNum) AS previousMonth
	FROM CustomerSpending
),

QualifyingCustomers AS (
	SELECT customerID,
		name
	FROM CustomerHistory
	GROUP BY customerID, name
	HAVING SUM(
		CASE
			WHEN monthNum = previousMonth + 1
			AND amount > previousAmount
			THEN 1
			ELSE 0
		END
	) = 4
)

SELECT h.customerID,
	h.name,
	MAX(CASE WHEN h.monthNum = 1 THEN h.amount END) AS January,
	MAX(CASE WHEN h.monthNum = 2 THEN h.amount END) AS February,
	MAX(CASE WHEN h.monthNum = 3 THEN h.amount END) AS March,
	MAX(CASE WHEN h.monthNum = 4 THEN h.amount END) AS April,
	MAX(CASE WHEN h.monthNum = 5 THEN h.amount END) AS May
FROM CustomerHistory h
JOIN QualifyingCustomers q
ON h.customerID = q.customerID
GROUP BY h.customerID, h.name;


