SELECT c.Name
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;

SELECT DISTINCT c.Name
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID;

SELECT c.Name,
       SUM(o.Amount) AS TotalSpent
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name
HAVING SUM(o.Amount) > 100;

SELECT TOP 3
       c.Name,
       SUM(o.Amount) AS total_spent
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY total_spent DESC;