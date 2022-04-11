------------------------- Question 1 (2 points) ----------------

/* Rewrite the following query to present the same data in a horizontal format
   using the SQL PIVOT command. Your report should have the format listed below.
   
TerritoryID		2008-3-1	2008-3-2	2008-3-3	2008-3-4	2008-3-5
	1				34			7			9			8			12
	2				12			0			0			0			0
	3				13			0			0			0			0
	4				46			14			10			10			13
	5				15			0			0			0			0    
*/

USE AdventureWorks2008R2;

SELECT TerritoryID, CAST(OrderDate AS DATE) [Order Date], COUNT(CustomerID) AS [Customer Count]
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '3-1-2008' AND '3-5-2008'
GROUP BY TerritoryID, OrderDate
ORDER BY TerritoryID, OrderDate;


--pivot table


SELECT TerritoryID, [2008-3-1], [2008-3-2], [2008-3-3], [2008-3-4], [2008-3-5]
FROM 
(SELECT TerritoryID, CAST(OrderDate AS DATE) [Order Date], CustomerID FROM Sales.SalesOrderHeader) SourceTable
PIVOT(
  COUNT (CustomerID) FOR [Order Date] IN ([2008-3-1], [2008-3-2], [2008-3-3], [2008-3-4], [2008-3-5])
) AS PivotTable;


-- Question 1 (3 points)

/* Rewrite the following query to present the same data in a horizontal format,
   as listed below, using the SQL PIVOT command. */

select (p.LastName + ', ' + p.FirstName) FullName, year(sh.OrderDate) OrderYear, count(SalesOrderID) TotalOrder
from Sales.SalesOrderHeader sh
join Sales.Customer c
on sh.CustomerID = c.CustomerID
join Person.Person p
on c.PersonID = p.BusinessEntityID
where sh.CustomerID between 30000 and 30005
group by p.LastName + ', ' + p.FirstName, year(sh.OrderDate)
order by FullName;


/*
FullName				2005	2006	2007	2008
McCoy, James			0		2		4		2
McDonald, Christinia	0		0		1		1
McGuel, Alejandro		0		0		2		2
McKay, Yvonne			1		1		2		0
McLin, Nkenge			2		2		2		1
McPhearson, Nancy		0		0		2		2
*/
SELECT FullName, [2005], [2006], [2007], [2008]
FROM 
(
	select (p.LastName + ', ' + p.FirstName) FullName, year(sh.OrderDate) OrderYear, SalesOrderID
	from Sales.SalesOrderHeader sh
	join Sales.Customer c
	on sh.CustomerID = c.CustomerID
	join Person.Person p
	on c.PersonID = p.BusinessEntityID
	where sh.CustomerID between 30000 and 30005
) AS SourceTable
PIVOT
(
	count(SalesOrderID) FOR OrderYear IN ([2005], [2006], [2007], [2008])
) AS PivotTable;


-- Question 1 (4 points)

/* Using AdventureWorks2008R2, rewrite the following query to 
   present the same data in a horizontal format,
   as listed below, based on the SQL PIVOT command. */
select (p.LastName + ', ' + p.FirstName) FullName, datepart(dw, sh.OrderDate) Weekday, count(SalesOrderID) TotalOrder
from Sales.SalesOrderHeader sh
join Person.Person p
on sh.SalesPersonID = p.BusinessEntityID
group by p.LastName + ', ' + p.FirstName, datepart(dw, sh.OrderDate)
order by FullName;

--pivot table
use AdventureWorks2008R2;
select  FullName,[1]as[Sun],[2]as[Mon],[3]as[Tue],[4]as[Wed],[5]as[Thr],[6]as[Fri],[7]as[Sat]
from
(select (p.LastName + ', ' + p.FirstName) FullName, datepart(dw, sh.OrderDate) Weekday, SalesOrderID
from Sales.SalesOrderHeader sh
join Person.Person p
on sh.SalesPersonID = p.BusinessEntityID
)as sourcetable
pivot
(	count(SalesOrderID) for  Weekday in([1],[2],[3],[4],[5],[6],[7])
)  as pivottable

/*
FullName					Sun		Mon		Tue		Wed		Thr		Fri		Sat
Abbas, Syed					2		0		2		0		3		1		8
Alberts, Amy				2		2		5		7		8		7		8
Ansman-Wolfe, Pamela		11		19		20		10		7		12		16
Blythe, Michael				57		39		63		54		82		64		91
Campbell, David				28		19		33		20		35		20		34
Carson, Jillian				49		43		65		58		117		81		60
Ito, Shu					32		18		29		22		51		40		50
Jiang, Stephen				8		2		11		7		9		4		7
Mensa-Annan, Tete			20		7		17		16		30		20		30
Mitchell, Linda				40		36		67		58		94		62		61
Pak, Jae					47		16		52		35		66		62		70
Reiter, Tsvi				53		41		64		59		98		52		62
Saraiva, Jos?			29		36		37		38		55		31		45
Tsoflias, Lynn				22		7		12		10		13		8		37
Valdez, Rachel				19		13		17		14		19		12		36
Vargas, Garrett				20		21		35		32		55		37		34
Varkey Chudukatil, Ranjit	22		8		21		24		44		29		27
*/


-- Question 1 (2 points)
USE AdventureWorks2008R2;
/* The following SQL query generates a report in a vertical format.
   Please convert the query to a PIVOT query that creates a report
   containing the same data but in a horizontal format.
   The returned report should have the format like the one listed below,
   with NULL converted to 0. Use an alias to create a column heading.
   The example format below may not contain all the returned data. */
    
SELECT TerritoryID, CAST(OrderDate AS DATE) [Order Date], 
       SUM(TotalDue) AS [Sale Amount]
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '5-1-2008' AND '5-5-2008'
GROUP BY TerritoryID, OrderDate
ORDER BY TerritoryID, OrderDate;

TerritoryID	2008-5-1		2008-5-2	2008-5-3	2008-5-4	2008-5-5
	1		640355.3651		3513.7676	10004.2614	2220.8956	7148.2785
	2		187500.0667		0.00		0.00		0.00		0.00
	3		281836.1068		0.00		0.00		0.00		0.00

SELECT TerritoryID,isnull([2008-5-1],0),isnull([2008-5-2],0),isnull([2008-5-3],0),isnull([2008-5-4],0),isnull([2008-5-5],0)
FROM 
(SELECT TerritoryID, CAST(OrderDate AS DATE) [Order Date],TotalDue FROM Sales.SalesOrderHeader) SourceTable
PIVOT(
	SUM(TotalDue) FOR [Order Date] IN ([2008-5-1],[2008-5-2],[2008-5-3],[2008-5-4],[2008-5-5])
) AS PivotTable;

USE AdventureWorks2008R2;
SELECT 'AverageCost' AS Cost_Sorted_By_Production_Days, 
[0], [1], [2], [3], [4]
FROM
(SELECT DaysToManufacture, StandardCost 
    FROM Production.Product) AS SourceTable
PIVOT
(
AVG(StandardCost)
FOR DaysToManufacture IN ([0], [1], [2], [3], [4])
) AS PivotTable;


   
USE AdventureWorks2008R2;
select 'Sold Quantity' as 'Territory ID',[1], [4], [6], [10]
from(select TerritoryID, OrderQty
  from Sales.SalesOrderHeader sh
  join Sales.SalesOrderDetail sd
  on sh.SalesOrderID = sd.SalesOrderID) as sourcetable
pivot
(max(OrderQty) for TerritoryID in ([1], [4], [6], [10])) pivottable;
-- Sold Quantity	44	33	32	27

