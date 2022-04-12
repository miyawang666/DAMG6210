

-- Exercise Solution 1

create function ufLookUpFine (@StID int)
returns money
begin
   declare @amt money;
   select @amt = sum(Amount)
      from Fine
      where StudentID = @StID and PaidDate is null;
   return @amt;
end

alter table Enrollment add CONSTRAINT ckfine CHECK (dbo.ufLookUpFine (StudentID) = 0);




-- Exercise Solution 2

create function ufLookUpFine (@CustID int)
returns money
begin
   declare @amt money;
   select @amt = sum(Amount)
      from Fine
      where CustomerID = @CustID and PaidDate is null;
   return @amt;
end

alter table CustomerCheckOut add CONSTRAINT ckfine CHECK (dbo.ufLookUpFine (CustomerID) = 0);


