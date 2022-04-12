
-- Exercise Question 1 Solution

WITH Temp AS

   (select CustomerID, ProductID, sum(OrderQty) ttl,
    rank() over (partition by CustomerID order by sum(OrderQty) desc) as TopProduct
    from Sales.SalesOrderHeader sh
	join Sales.SalesOrderDetail sd
	on sh.SalesOrderID = sd.SalesOrderID
	where CustomerID between 30000 and 30005
    group by CustomerID, ProductID)

select t1.CustomerID,

STUFF((SELECT  ', '+RTRIM(CAST(ProductID as char))  
       FROM temp 
       WHERE CustomerID = t1.CustomerID and TopProduct <=3
       FOR XML PATH('')) , 1, 2, '') AS Top3Products

from temp t1
where t1.TopProduct <= 3
group by t1.CustomerID;


-- Exercise Question 2 Solution

WITH Temp AS
(select SalesPersonID, SalesOrderID, TotalDue,
 rank() over (partition by SalesPersonID order by TotalDue desc) as TopOrder
 from Sales.SalesOrderHeader
 where SalesPersonID is not null)

select p.BusinessEntityID as 'SalesPersonID', p.Lastname+ ', ' + p.FirstName as 'FullName',

STUFF((SELECT  ', '+RTRIM(CAST(SalesOrderID as char))  
       FROM temp 
       WHERE SalesPersonID = p.BusinessEntityID and TopOrder <=3
       FOR XML PATH('')) , 1, 2, '') AS Top3Orders
from Person.Person p
where p.BusinessEntityID in 
(select distinct SalesPersonID from Sales.SalesOrderHeader where SalesPersonID is not null)
order by SalesPersonID;


