/*
Day 7 - Window Functions

Key concepts learned:
- ROW_NUMBER(), RANK(), and DENSE_RANK()
- PARTITION BY creates separate windows without grouping rows.
- Window functions keep rows; GROUP BY collapses rows.
- Common pattern:
    1. Aggregate data.
    2. Apply a window function.
    3. Filter on the window function in an outer query.
*/

/*Business Requirement -  Latest Order per customer*/
SELECT
    CustomerID,
    OrderID,
    OrderDate
FROM (
    SELECT
        CustomerID,
        OrderID,
        OrderDate,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID
            ORDER BY OrderDate DESC
        ) AS OrderSequence
    FROM Orders
) AS CustomerOrders
WHERE OrderSequence = 1;

/*Business Requirement - Top selling product in each category*/
SELECT
    ProductID,
    CategoryID,
    TotalSales
FROM (
    SELECT *,
           RANK() OVER (
               PARTITION BY CategoryID
               ORDER BY TotalSales DESC
           ) AS ProductSalesRank
    FROM (
        SELECT
            p.ProductID,
            p.CategoryID,
            SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Products p
        JOIN OrderDetails od
            ON p.ProductID = od.ProductID
        GROUP BY
            p.ProductID,
            p.CategoryID
    ) AS ProductSales
) AS RankedProducts
WHERE ProductSalesRank = 1;

/*
Today's Takeaways

- GROUP BY summarizes rows into one row per group.
- Window functions keep rows and add information.
- PARTITION BY creates separate windows for each group.
- ROW_NUMBER() gives every row a unique sequence.
- RANK() preserves ties and skips the next rank.
- DENSE_RANK() preserves ties without skipping ranks.
- A common SQL pattern:
    Aggregate -> Window Function -> Filter
*/