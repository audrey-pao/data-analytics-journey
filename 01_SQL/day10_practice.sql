-- Business question:
-- For each order, determine whether spending increased,
-- decreased, or stayed the same compared with the customer's
-- previous order.

SELECT
    name,
    orderID,
    amount,
    previousOrderAmount,
    CASE
        WHEN amount > previousOrderAmount THEN 'Increased'
        WHEN amount < previousOrderAmount THEN 'Decreased'
        WHEN amount = previousOrderAmount THEN 'Same'
        ELSE 'First Order'
    END AS OrderStats
FROM (
    SELECT
        c.name,
        o.orderID,
        o.amount,
        LAG(o.amount) OVER (
            PARTITION BY c.customerID
            ORDER BY o.orderDate ASC
        ) AS previousOrderAmount
    FROM Customers c
    JOIN Orders o
        ON c.customerID = o.customerID
) AS CustomerOrders;

-- Business question:
-- Compare each customer's monthly spending with the
-- previous month.

-- Step 1: Get monthly spending
SELECT
    c.customerID,
    YEAR(o.orderDate) AS year,
    MONTH(o.orderDate) AS month,
    SUM(o.amount) AS monthlySpending
FROM Customers c
JOIN Orders o
    ON c.customerID = o.customerID
GROUP BY
    c.customerID,
    YEAR(o.orderDate),
    MONTH(o.orderDate);

-- Step 2: Compare each month with the previous month
SELECT
    customerID,
    year,
    month,
    monthlySpending,
    LAG(monthlySpending) OVER (
        PARTITION BY customerID
        ORDER BY year, month
    ) AS previousMonthSpending
FROM MonthlySpending;
/*
TODAY'S NEW PATTERNS

LAG()
→ Look at the previous row's value.

LAG() + CASE
→ Compare the current row with the previous row.

GROUP BY → LAG()
→ Aggregate to the correct business grain first,
  then compare rows within that grain.

CASE → 1/0 → SUM() → HAVING
→ Conditional aggregation.
→ Useful for counting how many times a condition occurs.

Important:
Window functions do NOT change the number of rows.
GROUP BY DOES change the number of rows.
*/