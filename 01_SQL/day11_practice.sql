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

-- Find the highest-selling product in each category.
-- Return all products if there is a tie.

WITH ProductSales AS (
    SELECT
        c.categoryID,
        c.categoryName,
        p.productID,
        p.productName,
        SUM(od.quantity * od.unitPrice) AS totalSales
    FROM Category c
    JOIN Products p
        ON c.categoryID = p.categoryID
    JOIN OrderDetails od
        ON p.productID = od.productID
    GROUP BY
        c.categoryID,
        c.categoryName,
        p.productID,
        p.productName
),
ProductRank AS (
    SELECT
        categoryID,
        categoryName,
        productID,
        productName,
        totalSales,
        RANK() OVER (
            PARTITION BY categoryID
            ORDER BY totalSales DESC
        ) AS salesRank
    FROM ProductSales
)
SELECT
    categoryName,
    productID,
    productName,
    totalSales
FROM ProductRank
WHERE salesRank = 1;
-- Find customers whose spending increased
-- for at least 2 consecutive months in 2026.

WITH MonthlySpending AS (
    SELECT
        c.customerID,
        c.name,
        MONTH(o.orderDate) AS month,
        SUM(o.amount) AS total
    FROM Customers c
    JOIN Orders o
        ON c.customerID = o.customerID
    WHERE YEAR(o.orderDate) = 2026
    GROUP BY
        c.customerID,
        c.name,
        MONTH(o.orderDate)
),

SpendingHistory AS (
    SELECT
        customerID,
        name,
        month,
        total,
        LAG(total) OVER (
            PARTITION BY customerID
            ORDER BY month
        ) AS previousTotal
    FROM MonthlySpending
),

CustomerChanges AS (
    SELECT
        customerID,
        name,
        month,
        total,
        previousTotal,
        CASE
            WHEN total > previousTotal THEN 1
            ELSE 0
        END AS increased
    FROM SpendingHistory
),

ConsecutiveChanges AS (
    SELECT
        customerID,
        name,
        month,
        total,
        previousTotal,
        increased,
        LAG(increased) OVER (
            PARTITION BY customerID
            ORDER BY month
        ) AS previousIncreased
    FROM CustomerChanges
)

SELECT DISTINCT
    customerID,
    name
FROM ConsecutiveChanges
WHERE increased = 1
  AND previousIncreased = 1;