if object_id('sale') is not null drop table sale;
if object_id('product') is not null drop table product;
if object_id('customer') is not null drop table customer;
if object_id('location') is not null drop table location;

go

create table customer (
custID          int,
custName        nvarchar(100),
sales_ytd       int,
status          nvarchar(7),
primary key (custID)       
);

create table product (
prodID          int,
prodName        nvarchar(100),
sellingPrice    money,
sales_ytd       money,
primary key (prodID)
);

create table sale (
saleID          int,
custID          int,
prodID          int,
qty             int,
price           money,
saleDate        date,
primary key (saleID),
foreign key (custID) references customer,
foreign key (prodID) references product,
);

create table location (
locID           nvarchar(5),
minQty          integer,
maxQty          integer,
PRIMARY KEY (LocID),
constraint check_locID_length check (len(locId) = 5),
constraint check_minQty_range check (minQty between 0 and 999),
constraint check_maxQty_range check (maxQty between 0 and 999),
constraint check_maxQty_greater_mixQty check (maxQty >= minQty),
);

if object_id('sale_seq') is not null
drop sequence sale_seq;
create sequence sale_seq;

go


--------------------ADD CUSTOMER--------------------


if object_id ('add_customer') is not null drop procedure add_customer;
go

create procedure add_customer @pcustID int, @pcustName nvarchar(100) as

begin
    begin try
        if @pcustID < 1 or @pcustID > 499
        throw 50020, 'Customer ID out of range', 1

        insert into customer (custID, custName, sales_ytd, status) values
        (@pcustID, @pcustName, 0, 'ok');

end try
    begin catch
        if error_number() = 2627
            throw 50010, 'Duplicate Customer ID', 1
        else if error_number() = 50020
            throw
        else
            begin
                declare @errormessage nvarchar(max) = error_message();
                throw 50000, @errormessage, 1
                end;
            end catch;
            
end;
go

exec add_customer @pcustID = 1, @pcustName = 'testdude2';
exec add_customer @pcustID = 500, @pcustName = 'testdude3';

select * from customer;


--------------------DELETE CUSTOMER--------------------


if object_id('delete_all_customers') is not null drop procedure delete_all_customers;
go

create procedure delete_all_customers @pcustID int, @pcustName nvarchar(100) as

begin
    delete from customer
        where custID = @pcustID and 
              custName = @pcustName
end

begin
declare @errormessage nvarchar(max) = error_message();
raise_application_error (-50000, 'Use value of error_message()') 
end;
  
go

exec delete_all_customers @pcustID = custID, @pcustName = custName;

select * from customer;


----------------------ADD PRODUCT----------------------


if object_id('add_product') is not null drop procedure add_product;
go

create procedure

--------------------DELETE PRODUCT--------------------


if object_id('delete_product') is not null drop procedure delete_product;
go

create procedure