-- case study

-- 1. Top Product Analysis 1998
select CategoryName, ProductName
from
	(
		select *, rank() over (partition by CategoryName order by sales desc) r
		from
			(
				select sum(a.Quantity*a.UnitPrice) sales, b.CategoryName, b.ProductName
				from [Order Details] a
				left join 
					(
						select ProductID, ProductName, CategoryName
						from Products a
						left join Categories b
						on a.CategoryID = b.CategoryID
					) b
				on a.ProductID = b.ProductID
				left join Orders c
				on a.OrderID = c.OrderID
				where year(c.OrderDate) = '1998'
				group by b.CategoryName, b.ProductName
			) a
	) t
where t.r = 1;


-- 2. Supplier Region Analysis 1998
select Region, count(OrderID) orders
from
	(
		select
			case
				when lower(Country) = 'australia' then 'Australia'
				when lower(Country) in ('brazil', 'canada', 'usa') then 'America'
				when lower(Country) in ('denmark', 'finland', 'france', 'germany', 'italy', 'netherlands', 'norway', 'spain', 'sweden', 'uk') then 'Europe'
				when lower(Country) in ('japan', 'singapore') then 'Asia'
			end Region,
			b.OrderID OrderID
		from
			(
				select Country, ProductID
				from Suppliers a
				left join Products b
				on a.SupplierID = b.SupplierID
			) a
		left join [Order Details] b
		on a.ProductID = b.ProductID
		left join Orders c
		on b.OrderID = c.OrderID
		where year(c.OrderDate) = '1998'
	) a
group by Region;


-- 3. Shipper Trend Analysis 1998
select month(OrderDate) month, CompanyName, count(OrderID) count_order
from Shippers a
left join Orders b
on a.ShipperID = b.ShipVia
where year(OrderDate) = '1998'
group by month(OrderDate), CompanyName
order by month, CompanyName