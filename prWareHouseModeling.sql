Project - ZAGI Retail Company
*/

INSERT INTO ZAGI_Dimensional.CALENDAR_D (FullDate, DayOfWeek, DayOfMonth, Month, Qtr, Year) 
SELECT DISTINCT TDate as FullDate, DAYOFWEEK(tdate) AS DayOfWeek, dayofmonth(tdate) AS DayOfMonth, 
month(tdate) AS Month, quarter(tdate) AS Qtr, year(tdate) AS Year FROM SALESTRANSACTION;

INSERT INTO ZAGI_Dimensional.PRODUCT_D (ProductID, ProductName, ProductPrice, ProductVendorName, 
ProductCategoryName) 
SELECT p.ProductID as ProductID, p.ProductName, p.ProductPrice, v.VendorName AS ProductVendorName, c.CategoryName AS
ProductCategoryName 
FROM PRODUCT p, VENDOR v, CATEGORY c
WHERE p.VendorID=v.VendorID AND p.CategoryID=c.CategoryID 
GROUP BY p.ProductID;

INSERT INTO ZAGI_Dimensional.STORE_D (StoreID, StoreZip, StoreRegionName, StoreSize, StoreCSystem, StoreLayout )
SELECT s.StoreID as StoreId, s.StoreZip AS StoreZip, r.RegionName AS StoreRegionName, s1.StoreSize AS StoreSize, 
cs.CSystem AS StoreCSystem, l.Layout AS StoreLayout
FROM ZAGI_Sales_Dep.STORE s, ZAGI_Sales_Dep.REGION r, ZAGI_Facilities_Dep.STORE1 s1, ZAGI_Facilities_Dep.CHECKOUTSYSTEM cs,
ZAGI_Facilities_Dep.LAYOUT l
WHERE r.RegionID=s.RegionID AND s.StoreID=s1.StoreID AND s1.CSID=cs.CSID AND s1.LTID=l.LayoutID 
GROUP BY s.StoreID;

INSERT INTO ZAGI_Dimensional.CUSTOMER_D (CustomerID, CustomerName, CustomerZip, CustomerGender, CustomerMaritalStatus, 
CustomerEducationLevel, CustomerCreditScore)
SELECT t1.customerid as CustomerId, t1.customername AS CustomerName, t1.customerzip AS CustomerZip, t2.gender AS 
CustomerGender, t2.maritalstatus AS CustomerMaritalStatus, t2.educationlevel AS CustomerEducationLevel, t2.creditscore 
AS CustomerCreditScore 
FROM ZAGI_Sales_Dep.CUSTOMER AS t1, ZAGI_Customer_Table.CUSTOMER_TABLE AS t2 
WHERE t1.CustomerlD=t2.CustomerlD;

CREATE VIEW 'SALES_FACT_VIEW' 
AS SELECT st.TDate, st.StoreID, sv.ProductID, st.CustomerID, sv.TID AS TID, st.TTime AS TimeOfDay, 
p.ProductPrice*sv.NoOfiltems AS DollarsSold, sV.NoOfltems AS UnitsSold FROM ZAGI_Sales_Dep.SOLDVIA AS sv, 
ZAGI_Sales_Dep.PRODUCT AS p, ZAGI_Sales_Dep.SALESTRANSACTION AS st 
WHERE sv.ProductiD=p.ProductID AND sv.TID=st.TID;

INSERT INTO ZAGI_Dimensional.SALES_FACT (CalendarKey, StoreKey, ProductKey, Customerkey, TID, TimeOfDay, 
DollarsSold, UnitsSold ) 
SELECT CA.CalendarKey, S.StoreKey, P.Productkey, CU.CustomerKey, SFV.TID, SFV.TimeOfDay, SFV.DollarsSold, SFV.UnitsSold
FROM ZAGI_Sales_Dep.SALES_FACT_VIEW AS SFV, ZAGI_Dimensional.CALENDAR_D AS CA, ZAGI_Dimensional.PRODUCT_D AS P, ZAGI_Dimensional.STORE_D as S,
ZAGI_Dimensional.CUSTOMER_D AS CU 
WHERE CA.FullDate=SFV.TDate AND S.StorelD=SFV.StorelD AND P.ProductID=SFV.ProductID AND CU.CustomerID = SFV.CustomerID;
