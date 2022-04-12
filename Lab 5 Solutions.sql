
-- Lab 5 Solutions

--Q1
/* Create a function in your own database that takes two 
   parameters: 
1) A year parameter  
2) A month parameter 
   The function then calculates and returns the total sale  
   for the requested year and month. If there was no sale 
   for the requested period, returns 0. 
 
   Hints: a) Use the TotalDue column of the  
             Sales.SalesOrderHeader table in an 
             AdventureWorks database for 
             calculating the total sale. 
          b) The year and month parameters should use  
             the INT data type. 
          c) Make sure the function returns 0 if there 
             was no sale in the database for the requested 
             period. */ 

create function ufSalesByMonthYear
(@month int, @year int)
returns money
As
Begin 
	Declare @sale money;
	select @sale = isnull( sum(TotalDue) , 0)
	   from sales.SalesOrderHeader
	   where month(orderDate) = @month AND year(OrderDate) = @year
	return @sale;
End
	

-- Q2
/*Create a table in your own database using the following statement. 
CREATE TABLE DateRange 
(DateID INT IDENTITY,  
 DateValue DATE, 
 Month INT, 
 DayOfWeek INT); 
 
Write a stored procedure that accepts two parameters: 
1)  A starting date  
2)  The number of the consecutive dates beginning with the starting 
date 
The stored procedure then populates all columns of the 
DateRange table according to the two provided parameters. */

CREATE TABLE DateRange
(DateID INT IDENTITY,
 DateValue DATE,
 Month INT,
 DayOfWeek INT);

create procedure dbo.uspFillDateRange
@startDate date,
@daysAfter int
AS BEGIN
	Declare @counter int = 0;
	declare @tempdate date;
	while (@counter < @daysAfter)
	Begin 
	    set @tempdate = DATEADD(dd, @counter, @startDate);
		Insert into dbo.DateRange (DateValue, month, DayOfWeek)
			values( @tempdate, month(@tempdate), DATEPART(dw, @tempdate));
			set @counter += 1;
	End
	Return;
End
Go


--Q3
/* Write a trigger to update the CustomerStatus column of Customer  
   based on the total of OrderAmountBeforeTax for all orders  
   placed by the customer. If the total exceeds 5,000, put Preferred 
   in the CustomerStatus column. */ 

Create trigger trUpdateCustomerStatus
on dbo.saleOrder
after INSERT, UPDATE, DELETE
As begin
	declare @total money = 0;
	declare @custid varchar(20);
	declare @status varchar(10);

	select @custid = isnull (i.CustomerID, d.CustomerID)
	   from inserted i full join deleted d 
	   on i.CustomerID = d.CustomerID;

	select @total = sum(OrderAmountBeforeTax)
	   from saleOrder
   	   where CustomerID = @custid;

	if @total > 5000
		set @status = 'preferred'
	else
		set @status = 'regular';

	update Customer
		set CustomerStatus = @status
		where CustomerID = @custid 
end

