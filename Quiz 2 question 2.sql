-- Question 2 (5 points)

/*
Using AdventureWorks2008R2, write a query to retrieve 
the customers and their order info.
Return the customer id, a customer's total purchase,
and a customer's top 5 orders. 
The top 5 orders have the 5 highest order values. 
Use TotalDue as the order value. If there is a tie, 
the tie must be retrieved.
Include only the customers who have had at least one order
which contained more than 70 unique products.
Sort the returned data by CustomerID. Return the data in
the format specified below.
*/

/*
CustomerID	TotalPurchase	Orders
29712		653973.76		51739, 46987, 69437, 57061, 50225
29722		954021.92		45529, 48306, 47365, 44750, 53465
30048		678828.84		51160, 46657, 67316, 49879, 55297
30107		650362.05		51721, 57046, 69422, 43869, 63157
*/
use AdventureWorks2008R2;
with temp as 
(select CustomerID,TotalDue, SalesOrderID,sum(t1.TotalDue)AS TotalPurchase,
RANK() OVER (PARTITION BY CustomerID ORDER BY TotalDue DESC ) AS OrderRank
from Sales.SalesOrderHeader 
 group by CustomerID
)
SELECT DISTINCT 
	t2.CustomerID as CustomerID,sum(t1.TotalDue)AS TotalPurchase,
	STUFF
	(
		(SELECT  ', '+t1.SalesOrderID  
		FROM temp t1 
		WHERE t1.CustomerID = t2.CustomerID  AND t1.OrderRank< 6
		FOR XML PATH('')) , 1, 2, '') AS Orders
FROM temp t2
group by CustomerID;


-- Question 2 (6 points)

/* Write a query to retrieve the top two salespersons of each territory.
   Use the sum of TotalDue in SalesOrderHeader to determine the total sale amounts.
   The top 2 salespersons have the two highest total sale amounts. Your solution
   should retrieve a tie if there is any. The report should have the following format.
   The name is the full name of a salesperson. The email address is a salesperson's
   email address. Sort the report by the territory id.
TerritoryID	Top2Salespersons
	1		David Campbell david8@adventure-works.com, Pamela Ansman-Wolfe pamela0@adventure-works.com
	2		Jillian Carson jillian0@adventure-works.com, Michael Blythe michael9@adventure-works.com
	3		Jillian Carson jillian0@adventure-works.com, Michael Blythe michael9@adventure-works.com
	4		Linda Mitchell linda3@adventure-works.com, Shu Ito shu0@adventure-works.com
	5		Tsvi Reiter tsvi0@adventure-works.com, Michael Blythe michael9@adventure-works.com
	6		Jae Pak jae0@adventure-works.com, Garrett Vargas garrett1@adventure-works.com
	7		Ranjit Varkey Chudukatil ranjit0@adventure-works.com, Amy Alberts amy0@adventure-works.com
	8		Rachel Valdez rachel0@adventure-works.com, Amy Alberts amy0@adventure-works.com
	9		Lynn Tsoflias lynn0@adventure-works.com, Syed Abbas syed0@adventure-works.com
	10		Jos?Saraiva jos?@adventure-works.com, Amy Alberts amy0@adventure-works.com  
*/

WITH TEMP AS 
(
	SELECT DISTINCT SalesPersonID, TerritoryID, LastName, FirstName, EmailAddress, SUM(TotalDue) AS [TOTAL],
	       RANK() OVER(PARTITION BY TerritoryID ORDER BY SUM(TotalDue) DESC) AS [RANK]
	FROM Sales.SalesOrderHeader SH
	INNER JOIN Person.Person PP
	ON SH.SalesPersonID = PP.BusinessEntityID
	INNER JOIN Person.EmailAddress PE
	ON PP.BusinessEntityID = PE.BusinessEntityID
	WHERE SalesPersonID IS NOT NULL
	GROUP BY TerritoryID, SalesPersonID, LastName, FirstName, EmailAddress
)
SELECT DISTINCT TerritoryID,
STUFF
(
(SELECT  ', '+ FirstName + ' ' + LastName + ' ' + EmailAddress
 FROM  TEMP T2
 WHERE T2.TerritoryID = T1.TerritoryID AND [RANK] <= 2
 FOR XML PATH('')), 1, 2, ''
)AS Top2Salespersons
FROM TEMP T1
ORDER BY T1.TerritoryID

-- Question 3 (3 points)

/* Write a query to retrieve the top 3 customers, based on the total purchase,
   for each region. The top 3 customers have the 3 highest total purchase amounts.
   Use TotalDue of SalesOrderHeader to calculate the total purchase.
   Also calculate the top 3 customers' total purchase amount.
   Return the data in the following format.
territoryid	Total Sale	Top5Customers
	1		2639574		29818, 29617, 29580
	2		1899953		29701, 29966, 29844
	3		2203384		29827, 29913, 29924
	4		2521259		30117, 29646, 29716
	5		1950980		29715, 29507, 29624
	6		2742459		29722, 29614, 29639
	7		1873658		30103, 29712, 29923
	8		938793		29995, 29693, 29917
	9		583812		29488, 29706, 30059
	10		1565145		30050, 29546, 29587
*/
USE AdventureWorks2008R2;
with temp AS
	(SELECT DISTINCT
		sh.TerritoryID,sum(sh.TotalDue) [Total_Sale],sh.CustomerID,
		RANK() OVER (PARTITION BY TerritoryID ORDER BY SUM(sh.TotalDue) DESC ) AS OrderRank
	FROM sales.SalesOrderHeader sh
	GROUP BY sh.TerritoryID,sh.CustomerID)
SELECT DISTINCT
	t2.TerritoryID,sum(Total_Sale) [Total Sale],
	STUFF(
		(SELECT ', '+RTRIM(CAST(CustomerID as char))+' '
		FROM temp t1
		WHERE t1.TerritoryID = t2.TerritoryID
		AND t1.OrderRank <4
		FOR XML PATH('')),1,2,'') AS Top3Customers
FROM temp t2 WHERE OrderRank<4
GROUP BY TerritoryID
ORDER BY TerritoryID;

------------------------- Question 2 (3 points) ----------------------

/* Write a query to retrieve the top five customers of each territory.
   Use the sum of TotalDue in SalesOrderHeader to determine the total purchase amounts.
   The top 5 customers have the five highest total purchase amounts. Your solution
   should retrieve a tie if there is any. The report should have the following format.
   Sort the report by TerritoryID.
TerritoryID	Top5Customers
	1		Harui Roger, Camacho Lindsey, Bready Richard, Ferrier Fran�ois, Vanderkamp Margaret
	2		DeGrasse Kirk, Lum Richard, Hirota Nancy, Duerr Bernard, Browning Dave
	3		Hendricks Valerie, Kirilov Anton, Kennedy Mitch, Abercrombie Kim, Huntsman Phyllis
	4		Vessa Robert, Cereghino Stacey, Dockter Blaine, Liu Kevin, Arthur John
	5		Dixon Andrew, Allen Phyllis, Cantoni Joseph, Hendergart James, Dennis Helen   
*/

USE AdventureWorks2008R2;

WITH temp AS
   (SELECT DISTINCT
	    sh.TerritoryID, 
	    pp.FirstName,
	    pp.LastName,
	    SUM(sh.TotalDue) AS TotalSum,
	    RANK() OVER (PARTITION BY sh.TerritoryID ORDER BY SUM(sh.TotalDue) DESC ) AS OrderRank
	FROM Sales.SalesOrderHeader sh
	INNER JOIN Sales.Customer sc ON sh.CustomerID = sc.CustomerID
	INNER JOIN Person.Person pp ON sc.PersonID = pp.BusinessEntityID
	GROUP BY sh.TerritoryID, pp.FirstName, pp.LastName) 
	
SELECT DISTINCT 
	t2.TerritoryID, 
	STUFF(
		(SELECT  ', '+RTRIM(CAST(LastName as char)) +' '+ RTRIM(CAST(FirstName as char))   
		FROM temp t1 
		WHERE t1.TerritoryID = t2.TerritoryID 
		AND t1.OrderRank< 6
		FOR XML PATH('')) , 1, 2, '') AS listCustomers
FROM temp t2
ORDER BY TerritoryID;

/* Write a query to retrieve the top 2 customers, based on the total purchase,
for each year. Use TotalDue of SalesOrderHeader to calculate the total purchase.
The top 2 customers have the 2 highest total purchase amounts.
Also calculate the top two customer's total purchase as a percentage of the total
sale for the year. Return the data in the following format.
The email address is the customer's.
Sort the report by the year.

Year   % of Total Sale       Top2Customers
2005       4.16 29624 joseph0@adventure-works.com, 29861 phyllis1@adventure-works.com
2006       2.17 29614 ryan1@adventure-works.com, 29716 blaine0@adventure-works.com
2007       1.74 29913 anton0@adventure-works.com, 29818 roger0@adventure-works.com
2008       1.68 29923 edward1@adventure-works.com, 29641 raul0@adventure-works.com
*/



Select A.Year, A.[% of Total Sale]+B.[% of Total Sale] as [% of Total Sale]
,concat(A.CustomerId,' ',A.EmailAddress,', ',B.CustomerId,' ',B.EmailAddress) as Top2Customers
from
(
Select t1.Year, (TotalPurchase/t2.TotalSale)*100 as "% of Total Sale", t1.CustomerID, P.EmailAddress
from
   (
   select CustomerID, year(OrderDate) as Year, sum(totaldue) as TotalPurchase,
   ROW_NUMBER() OVER(PARTITION BY year(orderDate) ORDER BY sum(totaldue) DESC) as rownum
   from sales.SalesOrderHeader
   group by CustomerID, year(OrderDate)
   ) as t1
left join
(
select year(OrderDate) as Year, sum(totaldue) as TotalSale
from sales.SalesOrderHeader
group by year(OrderDate)
)t2
on t1.Year = t2.Year
left join
Sales.Customer as C
on t1.CustomerID=C.CustomerID
left join
Person.EmailAddress as P
on C.PersonID=P.BusinessEntityID
where rownum=1) A
left join
(
Select t1.Year, (TotalPurchase/t2.TotalSale)*100 as "% of Total Sale", t1.CustomerID, P.EmailAddress
from
   (
   select CustomerID, year(OrderDate) as Year, sum(totaldue) as TotalPurchase,
   ROW_NUMBER() OVER(PARTITION BY year(orderDate) ORDER BY sum(totaldue) DESC) as rownum
   from sales.SalesOrderHeader
   group by CustomerID, year(OrderDate)
   ) as t1
left join
(
select year(OrderDate) as Year, sum(totaldue) as TotalSale
from sales.SalesOrderHeader
group by year(OrderDate)
)t2
on t1.Year = t2.Year
left join
Sales.Customer as C
on t1.CustomerID=C.CustomerID
left join
Person.EmailAddress as P
on C.PersonID=P.BusinessEntityID
where rownum=2
) B
on A.year = B.year
ORDER BY year
