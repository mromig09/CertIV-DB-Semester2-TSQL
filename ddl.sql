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


---------------------ADD CUSTOMER---------------------


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
exec add_customer @pcustID = 499, @pcustName = 'testdude3';

select * from customer;


--------------------DELETE CUSTOMER-------------------


if object_id('delete_all_customers') is not null 
drop procedure delete_all_customers;
go

create procedure delete_all_customers as
begin try
    delete from customer;
    return @@rowcount;
end try

begin catch
    declare @errormessage nvarchar(max) = error_message();
    throw 50000, @errormessage, 1
end catch;

go

begin
declare @count int;
exec @count = delete_all_customers;
select @count;
end;


----------------------ADD PRODUCT---------------------


if object_id('add_product') is not null drop procedure add_product;
go

create procedure add_product @pprodID int, @pprodName nvarchar(100), @pprice money as

begin
    begin try
        if @pprodID < 1000 or @pprodID > 2500
        throw 50040, 'Product ID out of range', 1

        insert into product (prodID, prodName, sellingPrice, sales_ytd) values
        (@pprodID, @pprodName, @pprice, 0);
    end try

    begin catch
        if error_number() = 2667
            throw 50030, 'Duplicate Product ID', 1
        else if error_number() = 50000
            throw
        else
            begin
                declare @errormessage nvarchar(max) = error_message();
                throw 50000, @errormessage, 1
            end;
    end catch;
end;

go

exec add_product @pprodID = 1000, @pprodName = 'testprice1', @pprice = 500;
exec add_product @pprodID = 2500, @pprodName = 'testprice2', @pprice = 20000;

select * from product;


--------------------DELETE PRODUCT--------------------


if object_id('delete_all_products') is not null 
drop procedure delete_all_products;
go

create procedure delete_all_products as
begin try
    delete from product;
    return @@rowcount;
end try

begin catch
    declare @errormessage nvarchar(max) = error_message();
    throw 50000, @errormessage, 1
end catch;

go

begin
declare @count int;
exec @count = delete_all_products;
select @count;
end;


-----------------GET CUSTOMER STRING------------------


if object_id('get_customer_string') is not null 
drop procedure  get_customer_string;
go

create procedure get_customer_string @pcustID int, @preturnstring nvarchar(1000) output as
begin
    begin try
        select @preturnstring = concat ('custID: ', custID, ', ', 'Name: ', custName, ', ', 
        'Status: ', status, ', ', 'SalesYTD: ', sales_ytd)
        from customer
        where custID = @pcustID
    end try

    begin catch
        if error_number() = 2657
            throw 50060, 'No matching customer ID not found', 1
        else if error_number() = 50000
            throw
        else
            begin
                declare @errormessage nvarchar(max) = error_message();
                throw 50000, @errormessage, 1
            end;
    end catch;
end;

go

begin
    declare @output nvarchar(1000);
    exec get_customer_string @pcustID = 1, @preturnstring = @output OUTPUT;
    select @output as 'customer';
end;


---------------UPDATE CUSTOMER SALESYTD---------------


if object_id('update_customer_salesytd') is not null 
drop procedure  update_customer_salesytd;
go

create procedure update_customer_salesytd @pcustID int, @pamt int as
begin
    begin try
        update customer
        set sales_ytd = sales_ytd + @pamt 
        where custID = @pcustID
    end try

    begin catch
        if error_number() = 2637
            throw 50070, 'No rows updated', 1
        else if error_number() = 50080
            throw 50080, 'Pamt out side of range -999.99 to 999.99', 2
        else
            begin
                declare @errormessage nvarchar(max) = error_message();
                throw 50000, @errormessage, 1
            end;
    end catch;
end;

go

begin
    declare @pamt int;
    exec update_customer_salesytd @pcustID = 1, @pamt = 999.99;
    exec update_customer_salesytd @pcustID = 499, @pamt = 500.99;
end;

select * from customer


------------------GET PRODUCT STRING------------------


if object_id('get_product_string') is not null 
drop procedure  get_product_string;
go

create procedure get_product_string @pprodID int, @preturnstring nvarchar(1000) output as
begin
    begin try
        select @preturnstring = concat ('prodID: ', prodID, ', ', 'Name: ', prodName, ', ', 
        'Price: ', sellingPrice, ', ', 'SalesYTD: ', sales_ytd)
        from product
        where prodID = @pprodID
    end try
 
    begin catch
        if error_number() = 2647
            throw 50090, 'No matching product ID not found', 1
        else if error_number() = 50000
            throw
        else
            begin
                declare @errormessage nvarchar(max) = error_message();
                throw 50000, @errormessage, 1
            end;
    end catch;
end;

go

begin
    declare @output nvarchar(1000);
    exec get_product_string @pprodID = 1000, @preturnstring = @output OUTPUT;
    select @output as 'product';
end;


-------------------UPDATE PROD SALESYTD------------------


if object_id('update_product_salesytd') is not null 
drop procedure  update_product_salesytd;
go

create procedure update_product_salesytd @pprodID int, @pamt int as
begin
    begin try
        if not exists (
            select @pprodID
            from product
            where prodID = @pprodID)
            
            throw 50100, 'Product ID is not found', 1
            if @pamt <-999.99 or @pamt > 999.99
            throw 50110, 'Amount is out of range', 1

            update product set
            sales_ytd = sales_ytd + @pamt
            where prodID = @pprodID;
    end try

begin catch
    if error_number() = 50100
    throw
    if error_number() = 50110
    throw
end catch
end

exec update_product_salesytd @pprodID = 2209, @pamt = 500;

select *
from product


-------------------UPDATE CUSTOMER STATUS------------------

if object_id('update_customer_status') is not null
drop procedure update_customer_status
go

create procedure update_customer_status @pcustID int, @pstatus nvarchar(7) as
begin
    begin try
        if not exists (
            select @pcustID
            from customer
            where custID = @pcustID)

            throw 50120, 'Customer ID is not found', 1

            if @pstatus = 'ok' or @pstatus = 'suspend'
            update customer set
            status = upper(@pstatus)
            where custID = @pcustID;
            else
            throw 5013, 'Invalid status value', 1
    end try

    begin catch
        if error_number() = 50120
        throw
        if error_number() = 50130
        throw
    end catch
end

exec update_customer_status @pcustID = 1, @pstatus = 'ok';
exec update_customer_status @pcustID = 2, @pstatus = 'suspend';

exec update_customer_status @pcustID = 40, @pstatus = 'suspend';
exec update_customer_status @pcustID = 2, @pstatus = 'testInvalid';

select * 
from customer


-------------------ADD SIMPLE SALE------------------


if object_id('add_simple_sale') is not null
drop procedure add_simple_sale;
go

create procedure add_simple_sale @pcustID int, @pprodID int, @pqty int as

begin
    begin try
        declare
        @pthisCustID int = @pcustID,
        @pthisProdID int = @pprodID;

        declare
        @prices int
        select @pprices = sellingPrice
        from product
        where prodID = @pprodID;

        DECLARE
        @pqtyPriceProd int = @pqty * prices;

        if not exists (
            select @pcustID 
            from customer 
            where custID = @pthisCustID)

                throw 50160, 'Customer ID is not found', 1

        if not exists (
            select @pthisProdID
            from product
            where prodID = @pthisProdID)

                throw 50170, 'Product ID is not found', 1
        
        if not exists (
            select @pthisCustID
            from customer
            where custID = @pthisCustID and status = 'suspend')

                throw 50150, 'Customer status is not ok', 1
            
        if @pqty < 1 or @pqty > 999
            throw 50140, 'Sale quantity is out of range', 1

        exec update_customer_salesytd @pcustID = @pthisCustID, @pamt = @pqtyPriceProd;
        exec update_customer_salesytd @pprodID = @pthisProdID, @pamt = @pqtyPriceProd;
    end try

    begin catch
        if error_number() = 50140
        throw
        if error_number() = 50150
        throw
        if error_number() = 50160
        throw
        if error_number() = 50170
        throw
    end catch
end

exec add_simple_salesytd @pcustID = 3, @pprodID = 2000, @pqty = 20;
exec add_simple_salesytd @pcustID = 22, @pprodID = 2000, @pqty = 30;

select *
from customer

select * 
from product


--------------------SUM CUSTOMER SALESYTD-------------------


if object_id('sum_customer_salesytd') is not null
drop procedure sum_customer_salesytd;
go

create procedure sum_customer_salesytd @psumCustSales int output as
begin
    select @psumCustSales = sum(sales_ytd)
    from (
    select sales_ytd
    from customer )a
    return @psumCustSales
end

begin
    declare @output nvarchar(max);
    exec sum_customer_salesytd @psumCustSales = @output output;
    select @output as 'sum of customer sales_ytd';
end


--------------------SUM PRODUCT SALESYTD-------------------


if object_id('sum_product_salesytd') is not null
drop procedure sum_product_salesytd;
go

create procedure sum_product_salesytd @psumProdSales int output as
begin
    select @psumProdSales = sum(sales_ytd)
    from (
    select sales_ytd
    from product )a
    return @psumProdSales
end

begin
    declare @output nvarchar(max);
    exec sum_product_salesytd @psumProdSales = @output output;
    select @output as 'sum of product sales_ytd';
end


----------------------GET ALL PRODUCTS---------------------


if object_id('get_all_products') is not null
drop procedure get_all_products;
go

create procedure get_all_products @poutcur cursor varying output as

begin
    begin try
        set @poutcur = cursor for select *
        from product;
        open @poutcur;
    end try

    begin catch
    declare @errormessage nvarchar(max) = error_message();
    throw 50000, @errormessage, 1
    end catch
end

begin
    declare @cur cursor;

    exec get_all_products @poutcur = @cur output;

    declare
    @pprodID int,
    @pprodName nvarchar(100),
    @sellingPrice money,
    @sales_ytd money;

    fetch next from @cur into @pprodID, @pprodName, @sellingPrice, @sales_ytd;

    while @@fetch_status = 0

    begin
        print(concat('ID: ', @pprodID, ', ', 'Name: ', @pprodName, ', ', 'Selling Price: ', @sellingPrice, ', ', 'Sales_YTD: ', @sales_ytd))
        fetch next from @cur into @pprodID, @pprodName, @sellingPrice, @sales_ytd;
    end

    close @cur
    deallocate @cur
end


------------------------ADD LOCATION-----------------------


if object_id('add_location') is not null
drop procedure add_location;
go

create procedure add_location @plocCode nvarchar(5), @minQty int, @maxQty int as

begin
    begin try
        declare @lengthcheck nvarchar(5) = '12345';
        
        if @pminQty < 0 or @pminQty > 999
        throw 50200, 'Minimum qty is out of range', 1

        if @pmaxQty < 0 or @pmaxQty > 999
        throw 50210, 'Maximum qty us out of range', 1

        if @pminQty > @pmaxQty
        throw 50220, 'Minimum qty larger than maximum qty', 1
        
        if @plocCode like '[a-Za-z]%' or @plocCode > 99
        throw 50190, 'Location code length invalid', 1

        insert into [location] (locID, minQty, maxQty) values
        ('loc' + @plocCode, @pminQty, @pmaxQty);
    end try

    begin catch
        if error_number() = 2627
        throw 50180, 'Duplicate location ID', 1
        
        else if error_number() = 50190
        throw
        else if error_number() = 50200
        throw
        else if error_number() = 50210
        throw
        else if error_number() = 50220
        throw

        begin
            declare @errormessage nvarchar(max) = error_message();
            throw 50000, @errormessage, 1
        end;
    end catch;
end;

exec add_location @ = 71, @pminQty = 0, @pmaxQty = 30;
exec add_location @ = 99, @pminQty = 66, @pmaxQty = 777;
exec add_location @ = 24, @pminQty = 6, @pmaxQty = 44;

select *
from [location]


----------------------ADD COMPLEX SALE---------------------


if object_id('add_complex_sale') is not null
drop procedure add_complex_sale;
go


------------------------GET ALL SALES----------------------


if object_id('get_all_sales') is not null
drop procedure get_all_sales;
go
