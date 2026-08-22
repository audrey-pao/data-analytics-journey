-- CTE: Find customers whose 2026 spending is above
-- the average spending of all customers

WITH CustomerSpending AS (
    SELECT
        c.customerID,
        SUM(o.amount) AS totalSpent
    FROM Customers c
    JOIN Orders o
        ON c.customerID = o.customerID
    WHERE YEAR(o.orderDate) = 2026
    GROUP BY c.customerID
),
AverageSpending AS (
    SELECT
        AVG(totalSpent) AS averageSpent
    FROM CustomerSpending
)
SELECT
    cs.customerID,
    cs.totalSpent
FROM CustomerSpending cs
CROSS JOIN AverageSpending av
WHERE cs.totalSpent > av.averageSpent;