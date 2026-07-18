/*
Day 8 - Advanced Aggregation / Subqueries

Business Requirement:
Find customers whose total spending is above the average customer spending.

Key Concepts:
- The final output grain is one row per customer.
- Need to calculate customer-level totals first.
- Average must be calculated from customer totals, not individual orders.
- HAVING is used because we are filtering on an aggregate (SUM).
- No window function needed because we are comparing values, not ranking rows.
*/

SELECT 
    c.Name, 
    SUM(o.Amount) AS total_spent
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY 
    c.CustomerID,
    c.Name
HAVING SUM(o.Amount) > (
    SELECT AVG(total_spending)
    FROM (
        SELECT 
            CustomerID,
            SUM(Amount) AS total_spending
        FROM Orders
        GROUP BY CustomerID
    ) AS customer_spending
);
/*
Thought Process:

1. Orders table contains individual transactions.
2. Summarize orders into customer totals using SUM and GROUP BY.
3. Calculate average of those customer totals.
4. Return customers whose total spending exceeds that average.
*/