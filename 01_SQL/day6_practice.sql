/*Using the Orders table, write a query that returns:

OrderID
Amount

where the amount is greater than the average order amount.*/
SELECT OrderID,
       CustomerID,
       Amount
FROM Orders
WHERE Amount >
(
    SELECT AVG(Amount)
    FROM Orders
);

/*Show the customers whose total spending is greater than the average total spending of all customers.*/

SELECT c.Name, SUM(o.Amount) as total_spent
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
Group by c.CustomerID, c.Name
Having SUM(o.Amount) >(
    SELECT AVG(total_spending) AS average_spending
    FROM (SELECT customerID, SUM(amount) as total_spending
        FROM orders
       GROUP BY customerID
    ) AS customer_spending
);

/*Show all orders whose amount is less than the average order amount.

Return:

OrderID
CustomerID
Amount
*/
SELECT CustomerID,
       OrderID,
       Amount
FROM Orders
WHERE Amount < (
    SELECT AVG(Amount)
    FROM Orders
);

/*Show customers whose total spending is less than the average customer spending.

Return:

Customer Name
Total Spending*/
SELECT c.Name, SUM(o.Amount) as total_spent
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
Group by c.CustomerID, c.Name
Having SUM(o.Amount) <(
    SELECT AVG(total_spending) AS average_spending
    FROM (SELECT customerID, SUM(amount) as total_spending
        FROM orders
       GROUP BY customerID
    ) AS customer_spending
); 


/*"Who is our biggest customer?"

Return:

Customer Name
Total Spending*/
SELECT c.Name, SUM(o.Amount) as total_spent
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
Group by c.CustomerID, c.Name
Having SUM(o.Amount) =(
    SELECT MAX(total_spending)
    FROM (SELECT customerID, SUM(amount) as total_spending
        FROM orders
       GROUP BY customerID
    ) AS customer_spending
);