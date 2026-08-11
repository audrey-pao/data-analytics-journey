/* ============================================================
   WINDOW FUNCTIONS – REVIEW & NEW PATTERNS
   ============================================================ */

/*
1. ROW_NUMBER() – Get ONE row per group

Business question:
Find each customer's most recent order.

Pattern:
- Keep all order rows
- Partition by customer
- Order by date DESC
- Assign row numbers
- Filter to row_number = 1

Example:
*/
SELECT name, orderID, orderDate, amount
FROM (
    SELECT 
        c.name,
        o.orderID,
        o.orderDate,
        o.amount,
        ROW_NUMBER() OVER (
            PARTITION BY c.customerID
            ORDER BY o.orderDate DESC
        ) AS row_num
    FROM Customers c
    JOIN Orders o 
        ON c.customerID = o.customerID
) AS CustomerOrders
WHERE row_num = 1;


/*
2. ROW_NUMBER() vs RANK() / DENSE_RANK()

ROW_NUMBER():
- Always assigns a unique row number
- If values are tied, only one row will have row_number = 1
- Use when the business wants exactly ONE row

RANK():
- Tied values receive the same rank
- Skips ranks after a tie
- Example: 1, 1, 3
- Use when all tied rows should be included

DENSE_RANK():
- Tied values receive the same rank
- Does not skip ranks
- Example: 1, 1, 2

If filtering WHERE rank = 1:
RANK() and DENSE_RANK() return the same tied rows.


/*
3. AGGREGATE FIRST → WINDOW FUNCTION SECOND

Business question:
Find the highest-selling product in each category.

Important:
First calculate total sales for each product.
Then rank the aggregated product totals within each category.

Pattern:

OrderDetails
    ↓
GROUP BY Product
    ↓
Total Sales per Product
    ↓
ROW_NUMBER() / RANK()
    ↓
Filter to top product
*/

-- Step 1: Calculate total sales for each product
SELECT 
    c.categoryName,
    p.productName,
    SUM(o.quantity * o.unitPrice) AS totalSales
FROM Product p
JOIN Category c 
    ON p.categoryID = c.categoryID
JOIN OrderDetails o 
    ON p.productID = o.productID
GROUP BY 
    c.categoryID,
    p.productID,
    p.productName;


/*
Step 2: Rank products within each category

ROW_NUMBER() gives exactly one product per category.
RANK() or DENSE_RANK() can return multiple products if tied.
*/

SELECT 
    categoryName,
    productName,
    totalSales,
    ROW_NUMBER() OVER (
        PARTITION BY categoryName
        ORDER BY totalSales DESC
    ) AS row_num
FROM ProductSales;


/*
4. AVG() OVER()

Business question:
Find customers whose total spending is above
the average spending of all customers.

First:
Calculate total spending for each customer.

Then:
AVG(totalSpent) OVER () calculates the average
across ALL customer rows without collapsing the rows.

No PARTITION BY:
AVG(totalSpent) OVER ()

With PARTITION BY:
AVG(totalSpent) OVER (PARTITION BY Country)

The PARTITION BY determines the comparison group.
*/


/*
5. LAG()

Business question:
For every order, show the customer's previous order amount.

LAG() looks at the value from the previous row
within the specified window.

Pattern:
*/
SELECT 
    c.name,
    o.orderID,
    o.orderDate,
    o.amount,
    LAG(o.amount) OVER (
        PARTITION BY c.customerID
        ORDER BY o.orderDate ASC
    ) AS previousOrderAmount
FROM Customers c
JOIN Orders o 
    ON c.customerID = o.customerID;


/*
Key concept:

ROW_NUMBER()
→ What position is this row?

LAG()
→ What was the value on the previous row?

AVG() OVER()
→ What is the average across the window?

Window functions keep the original rows.
GROUP BY combines rows into groups.
*/


/*
6. BUSINESS QUESTION → SQL PATTERN

"Most recent order per customer"
→ ROW_NUMBER()
→ PARTITION BY CustomerID
→ ORDER BY OrderDate DESC
→ WHERE row_num = 1

"First order per customer"
→ ROW_NUMBER()
→ PARTITION BY CustomerID
→ ORDER BY OrderDate ASC
→ WHERE row_num = 1

"All customers tied for highest"
→ RANK() or DENSE_RANK()
→ WHERE rank = 1

"Previous order amount"
→ LAG()
→ PARTITION BY CustomerID
→ ORDER BY OrderDate ASC

"Above-average customer spending"
→ GROUP BY customer first
→ AVG(totalSpent) OVER ()
→ compare totalSpent to avgSpent

"Highest-selling product in each category"
→ GROUP BY product first
→ ROW_NUMBER() / RANK() OVER (
       PARTITION BY Category
       ORDER BY TotalSales DESC
   )
→ filter to rank = 1
*/