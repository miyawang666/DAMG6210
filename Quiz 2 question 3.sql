-- Question 3 (6 points)

 /* Given the following tables, there is a $100
    club annual membership fee per customer.
    There is a business rule, if a customer has spent more
	than $5000 for the current year, then the membership fee
	is waived for the current year. But if the total spending
	of the current year gets below $5000 after the fee has
	been waived, the fee will be charged again. The total
	spending may be reduced by a return. 
	
	Please write a trigger to implement the business rule.
	The membership fee is stored in the Customer table. */
use Lab4_Jiaqi_Wang;
create table Customer
(CustomerID int primary key,
 LastName varchar(50),
 FirstName varchar(50),
 MembershipFee money);

create table SalesOrder
(OrderID int primary key,
 CustomerID int references Customer(CustomerID),
 OrderDate date not null);

create table OrderDetail
(OrderID int references SalesOrder(OrderID),
 ProductID int,
 Quantity int not null,
 UnitPrice money not null
 primary key(OrderID, ProductID));

 go
 CREATE TRIGGER trig_Spending
ON "Lab4_Jiaqi_Wang".dbo.Customer
FOR UPDATE,INSERT, DELETE
AS 
BEGIN
 
   update dbo.Customer
   set 	MembershipFee=0
   where(select SUM(od.Quantity*od.UnitPrice)as total
   from   OrderDetail od 
    INNER JOIN SalesOrder so on so.OrderID=od.OrderID
	   inner join Customer c on c.CustomerID=so.CustomerID
	   group by c.CustomerID
   ) >5000
END;
go

-- Question 3 (6 points)
USE [SUN_JIQING_TEST]
/* Given five tables as defined below */

CREATE TABLE Department
 (DepartmentID INT PRIMARY KEY,
  Name VARCHAR(50));

CREATE TABLE Employee
(EmployeeID INT PRIMARY KEY,
 LastName VARCHAR(50),
 FirsName VARCHAR(50),
 Salary DECIMAL(10,2),
 DepartmentID INT REFERENCES Department(DepartmentID),
 TerminateDate DATE);

CREATE TABLE Project
(ProjectID INT PRIMARY KEY,
 Name VARCHAR(50));

CREATE TABLE Assignment
(EmployeeID INT REFERENCES Employee(EmployeeID),
 ProjectID INT REFERENCES Project(ProjectID),
 StartDate DATE,
 EndDate DATE
 PRIMARY KEY (EmployeeID, ProjectID, StartDate));

CREATE TABLE SalaryAudit
(LogID INT IDENTITY,
 EmployeeID INT,
 OldSalary DECIMAL(10,2),
 NewSalary DECIMAL(10,2),
 ChangedBy VARCHAR(50) DEFAULT original_login(),
 ChangeTime DATETIME DEFAULT GETDATE(),
 Perc decimal (3,2));


/* There is a business rule an employee cannot have more than
   two salary adjustments in the current year and any salary adjustment
   must be logged in the SalaryAudit table.
   Please write a trigger to implement the rule. Assume only one update
   takes place at a time. */

CREATE TRIGGER utrSalaryAudit ON Employee  
AFTER UPDATE
AS  
BEGIN
 
	IF UPDATE(Salary)
	BEGIN

	   DECLARE @COUNT INT
	   SELECT @COUNT = COUNT(LogID)
	   FROM SalaryAudit S
	   FULL JOIN inserted AS i 
	   ON S.EmployeeID = i.EmployeeID
	   FULL JOIN deleted d
	   ON i.EmployeeID = d.EmployeeID
	   WHERE S.EmployeeID = i.EmployeeID;

	   IF @COUNT > 2

	       ROLLBACK Transaction

	   ELSE
	      INSERT INTO SalaryAudit (EmployeeID, OldSalary, NewSalary) 
		  (SELECT isnull(i.EmployeeID, d.EmployeeID), d.Salary, i.Salary
		   FROM inserted AS i 
		   FULL JOIN deleted d
		   ON i.EmployeeID = d.EmployeeID);	  
    END
END

-- Question 4 (4 points)

/* Given the following tables, there is a business rule
   preventing a user from checking out a book if there is
   an unpaid fine. Please write a table-level constraint
   to implement the business rule. */
USE MURUGAPPAN_ASHWIN_TEST;

create table Book
(InventoryID int primary key,
 ISBN varchar (20),
 Title varchar(50),
 AuthorID int,
 CategoryID int);

create table Customer
(CustomerID int primary key,
 LastName varchar (50),
 FirstName varchar (50),
 PhoneNumber varchar (20));

create table CheckOut
(InventoryID int references Book(InventoryID),
 CustomerID int references Customer(CustomerID),
 CheckOutDate date,
 ReturnDate date
 primary key (InventoryID, CustomerID, CheckOutDate));

create table Fine
(CustomerID int references Customer(CustomerID),
 IssueDate date,
 Amount money,
 PaidDate date
 primary key (CustomerID, IssueDate));

DROP FUNCTION Checkcheckout;
CREATE FUNCTION Checkcheckout(@cid int)
RETURNS INT
AS
BEGIN
	DECLARE @checkflag SMALLINT = 0;
	DECLARE @amount money;
	DECLARE @pdate date;
	SELECT @amount = Amount FROM Fine
	WHERE Fine.CustomerID = @cid
	SELECT @pdate = PaidDate FROM Fine
	WHERE Fine.CustomerID = @cid
	IF @pdate is null and @amount > 0
		SET @checkflag = 1;
	RETURN @checkflag
END

ALTER TABLE CheckOut ADD CONSTRAINT validFine CHECK (dbo.Checkcheckout(CustomerID) = 0);

DROP table Fine;
DROP table CheckOut;
DROP table Customer;

-- Question 5 (4 points)

 /* Given the following tables, there is a $100
    club annual membership fee per customer.
    There is a business rule, if a customer has spent more
	than $5000 for the current year, then the membership fee
	is waived for the current year.
	
	Please write a trigger to implement the business rule.
	The membership fee is stored in the Customer table. */

USE MURUGAPPAN_ASHWIN_TEST;

DROP TABLE Customer;
create table dbo.Customer
(CustomerID int primary key,
 LastName varchar(50),
 FirstName varchar(50),
 MembershipFee money);

DROP table SalesOrder;
create table dbo.SalesOrder
(OrderID int primary key,
 CustomerID int references Customer(CustomerID),
 OrderDate date not null);

DROP table OrderDetailyeah ;
create table OrderDetailyeah 
(OrderID int references SalesOrder(OrderID),
 ProductID int,
 Quantity int not null,
 UnitPrice money not null
 primary key(OrderID, ProductID));

CREATE TRIGGER umemfee
ON SalesOrder
AFTER INSERT,UPDATE,DELETE
AS BEGIN
	DECLARE @t money = 0;
	DECLARE @cusid varchar(20);
	DECLARE @mf money = 0;

	SELECT @cusid = isnull(i.customerID, d.customerId) from INSERTED i FULL JOIN DELETED d on i.customerid = d.customerid;
	SELECT @t = sum(UnitPrice) from SaleOrder JOIN OrderDetail ON SaleOrder.OrderID = OrderDetail.OrderID
    WHERE customerId = @cusid AND DATEPART(year, OrderDate) = YEAR(GetDate());
	IF @t > 5000
		set @mf = 0
	ELSE
		set @mf = 100
	UPDATE Customer set MembershipFee = @mf where customerId = @cusid;
END

------------------------- Question 4 (4 points) ----------------------

/* There is a business rule that the company can not have have more than 10 active projects at the same time 
   and an active project team average size can not be greater than 50 empoyees. 
   An active project is a project which has at least one employee working on it. 
   Write a SINGLE table-level constraint to implement the rule. */



--int 0 = success, 1 = fail

CREATE FUNCTION quiz2.CheckProject (@pid int)
RETURNS smallint
AS
BEGIN
	DECLARE @checkresult smallint=0;
  
   	DECLARE @Countproject int = 0;
  	SELECT @Countproject = COUNT(DISTINCT ProjectID) FROM quiz2.Project;
  	IF @Countproject > 10
   		SET @checkresult = 1;
   	ELSE
   		DECLARE @Countemployee int = 0;
   		SELECT @Countemployee = COUNT(a.EmployeeID) FROM quiz2.Project p INNER JOIN quiz2.Assignment a on p.ProjectID=a.ProjectID
   		WHERE p.ProjectID = @pid;
		IF @Countemployee > 50 OR @Countemployee < 1
			SET @checkresult = 1; 
   RETURN @checkresult;
END;


ALTER TABLE quiz2.Project ADD CONSTRAINT validProject CHECK (quiz2.CheckProject(ProjectID) = 0);




------------------------- Question 5 (4 points) ----------------------

/* There is a business rule a salary adjustment cannot be greater than 10%.
   Also, any allowed adjustment must be logged in the SalaryAudit table.
   Please write a trigger to implement the rule. 
   Assume only one update takes place at a time. */

CREATE TRIGGER trig_Salary
ON quiz2.Employee
FOR UPDATE
AS 
BEGIN
	DECLARE @change float = 0.0;
	INSERT INTO quiz2.SalaryAudit (EmployeeID, OldSalary, NewSalary, ChangedBy)
       SELECT 
       		i.EmployeeID, 
            e.Salary,
            i.Salary,
            (i.Salary-e.Salary)/e.Salary
       FROM Inserted i
       INNER JOIN quiz2.Employee e ON i.EmployeeID = e.EmployeeID;
    SELECT @change = (i.Salary-e.Salary)/e.Salary FROM Inserted i INNER JOIN quiz2.Employee e ON i.EmployeeID = e.EmployeeID;
    IF @change > 0.1
	    BEGIN
		    ROLLBACK TRAN;
		    RAISERROR ('salary adjustment cannot be greater than 10%', 16, 1);
	    END;
END;


-- Question 3

create trigger trProcessingFee on Orderdetail
after insert, update, delete
as
begin
   declare @TotalQuantity int, @oid int, @fee money;

   set @oid = (select coalesce(i.OrderID, d.OrderID)
							   from inserted i
							   full join deleted d
							        on i.OrderID=d.OrderID);

   set @TotalQuantity = (select sum(Quantity) from OrderDetail 
                         where OrderID = @oid);
   
   if (select OrderValue from SalesOrder where OrderID = @oid) > 500
      set @fee = 0
      else set @fee = 5 * @TotalQuantity;

   update SalesOrder set ProcessingFee = @fee
          where OrderID = @oid;
end

drop trigger trProcessingFee


-- Suppose that your company has a business rule that no employee is allowed to have a salary greater than $200,000 unless the authorizing
-- manager’s employeeID has been entered with the transaction. Assume that a table, named employees, contains these columns:
Column name	Data type
EmployeeID	int
Salary	smallmoney
HireDate	smalldatetime
ApprovalID	int

CREATE TRIGGER trgSalary ON employees
FOR UPDATE
AS
IF UPDATE(Salary) 
  
IF (SELECT COUNT(*) FROM INSERTED WHERE 
Salary > 150000 AND ApprovalID IS NULL) > 0
   BEGIN
   --THE DATA INSERTED VIOLATES BUSINESS RULES
   --REMOVE ROWS FROM THE EMPLOYEES TABLE
   DELETE FROM employees
   FROM employees e JOIN INSERTED i 
     
ON (e.EmployeeID = i.EmployeeID)
 
WHERE e.Salary > 200000
  AND e.ApprovalID is NULL
  --RETURN AN ERROR BACK TO THE CALLING PROGRAM
   RAISERROR ('You must enter an ApprovalID for 
  salaries greater than $200,000', 16, 1)
   END
