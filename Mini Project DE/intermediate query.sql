-- intermediate query
use Northwind;

-- 1
select datepart(month, OrderDate) bulan, count(CustomerID) jumlah_customer
from Orders
where year(OrderDate) = '1997'
group by month(OrderDate);


-- 2
select concat(FirstName, ' ', LastName) nama
from Employees
where Title = 'Sales Representative';


-- 3
select top 5 b.ProductName
from [Order Details] a
left join Products b
on a.ProductID = b.ProductID
left join Orders c
on a.OrderID = c.OrderID
where year(c.OrderDate) = '1997'
	and month(c.OrderDate) = '01'
order by a.Quantity desc;


-- 4
select b.CompanyName
from Orders a
left join Customers b
on a.CustomerID = b.CustomerID
left join
	(
		select a.ProductName, b.OrderID
		from Products a
		left join [Order Details] b
		on a.ProductID = b.ProductID
	) c
on a.OrderID = c.OrderID
where c.ProductName = 'Chai'
	and year(a.OrderDate) = '1997'
	and month(a.OrderDate) = '06';


-- 5
select 
	count(case when UnitPrice*Quantity <= 100 then OrderID end) '<=100',
	count(case when UnitPrice*Quantity > 100 and UnitPrice*Quantity <= 250 then OrderID end) '100<x<250',
	count(case when UnitPrice*Quantity > 250 and UnitPrice*Quantity <= 500 then OrderID end) '250<x<500',
	count(case when UnitPrice*Quantity > 500 then OrderID end) '>500'
from [Order Details];


-- 6
select b.CompanyName
from [Order Details] a
left join
	(
		select a.OrderID, b.CompanyName, a.OrderDate
		from Orders a
		left join Customers b
		on a.CustomerID = b.CustomerID
	) b
on a.OrderID = b.OrderID
where UnitPrice*Quantity > 500
	and year(b.OrderDate) = '1997'
group by b.CompanyName;


-- 7
select month, ProductName
from
	(
		select
			month,
			ProductName,
			row_number() over (partition by month order by sales desc) product_rank
		from
			(
				select sum(a.Quantity*a.UnitPrice) sales, month(c.OrderDate) month, b.ProductName
				from [Order Details] a
				left join Products b
				on a.ProductID = b.ProductID
				left join Orders c
				on a.OrderID = c.OrderID
				where year(c.OrderDate) = '1997'
				group by b.ProductName, month(c.OrderDate)
			) a
		) a
where product_rank <= 5;


-- 8
create view nomor8 as
select
	a.OrderID,
	a.ProductID,
	ProductName,
	a.UnitPrice,
	a.Quantity,
	a.Discount,
	a.UnitPrice*(1-a.Discount) harga_setelah_diskon
from [Order Details] a
left join Products b
on a.ProductID = b. ProductID;


-- 9
create procedure Invoice
(@CustomerID varchar(10))
as
begin

select
	a.CustomerID,
	b.ContactName CustomerName,
	a.OrderID,
	a.OrderDate,
	a.RequiredDate,
	a.ShippedDate
from Orders a
left join Customers b
on a.CustomerID = b.CustomerID
where a.CustomerID = @CustomerID

end
go