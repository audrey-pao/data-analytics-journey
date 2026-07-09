/*
Week 1 - Day 5: CASE WHEN

Topics:
- Learned CASE WHEN for categorizing data.
- Used CASE with aggregate functions like SUM().
- Practiced INNER JOIN vs LEFT JOIN based on business requirements.
- Reviewed SQL processing order:
  SELECT aliases can be used in ORDER BY but not in HAVING (SQL Server).

Key Takeaways:
- CASE creates labels; it does not filter rows.
- CASE evaluates conditions from top to bottom, so put the most specific conditions first.
- Business requirements determine JOIN choice and query structure.

Practice:
- Classified orders as Large/Small.
- Created customer categories using total spending (Gold/Standard).
*/

SELECT c.Name,
       SUM(o.Amount) AS amount_spent,
       CASE
           WHEN SUM(o.Amount) >= 200 THEN 'Gold'
           ELSE 'Standard'
       END AS customer_level
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY amount_spent DESC;

SELECT OrderID,
       Amount,
       CASE
           WHEN Amount >= 200 THEN 'High Value'
           WHEN Amount >= 100 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS Order_Category
FROM Orders;

SELECT c.Name,
       SUM(o.Amount) AS total_spending,
       CASE
           WHEN SUM(o.Amount) >= 200 THEN 'Gold'
           WHEN SUM(o.Amount) >= 100 THEN 'Silver'
           ELSE 'Bronze'
       END AS customer_level
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name;