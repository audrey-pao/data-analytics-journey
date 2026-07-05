/*Day 4 – SQL Practice (Joins + Aggregations)

What I practiced:
 INNER JOIN vs LEFT JOIN and when to use each
 COUNT() behavior with NULL values
 GROUP BY and HAVING filtering on aggregates
 SUM() and AVG() calculations
 Multi-table joins (Customers, Orders, Payments)
 Comparing aggregated values across tables
 Learned that HAVING cannot reliably use SELECT aliases in SQL Server

Key takeaway:
I’m starting to think in terms of business questions first, then choosing SQL structure (JOIN type, aggregation, filtering) to match the requirement.

Challenge completed:
 Wrote multi-table query comparing total order amount vs total payment amount using GROUP BY and HAVING*/

SELECT c.Name,
       COUNT(o.OrderID) AS num_of_order
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name
HAVING COUNT(o.OrderID) > 0;

SELECT c.Name,
       COUNT(o.OrderID) AS num_of_order
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name
HAVING COUNT(o.OrderID) > 0
ORDER BY num_of_order DESC;

SELECT c.Name,
       SUM(o.Amount) AS total_spent,
       AVG(o.Amount) AS avg_spent
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY avg_spent DESC;

SELECT c.Name,
       SUM(o.Amount) AS total_order_amount,
       SUM(p.PaymentAmount) AS total_payment
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
JOIN Payments p
    ON o.OrderID = p.OrderID
GROUP BY c.CustomerID, c.Name
HAVING SUM(o.Amount) <> SUM(p.PaymentAmount);