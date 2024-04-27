Project - Big Z Inc.
*/

INSERT INTO BigZ_Dimensional.CALENDAR 
	(FullDate, DayOfWeek, DayOfMonth, MONTH, Quarter, YEAR)
		SELECT DISTINCT OrderDate AS FullDate, DAYOFWEEK(OrderDate) AS DayOfWeek, dayofmonth(OrderDate) AS DayOfMonth, 
		month(OrderDate) AS MONTH, quarter(OrderDate) AS Qtr, year(OrderDate) AS YEAR
			FROM BigZ_Orders.ORDER_;

INSERT INTO BigZ_Dimensional.CUSTOMER (CustomerID, CustomerName, CustomerType, CustomerZip) 
	SELECT * 
		FROM BigZ_Orders.CUSTOMER;

INSERT INTO BigZ_Dimensional.DEPOT (DepotID, DepotSize, DepotZip)
	SELECT * 
		FROM BigZ_Orders.DEPOT;

INSERT INTO BigZ_Dimensional.ORDERCLERK (OCID, OCName, OCTitle, OCEducation, OCYofhire) 
	SELECT oc.OCID, oc.OCName, hr.Title, hr.EducationLevel, hr.YearOfHire
		FROM BigZ_Orders.ORDERCLERK AS oc, BigZ_HR_Table.HRDEPARTMENT AS hr
			WHERE oc.OCID = hr.EmployeeID;

INSERT INTO BigZ_Dimensional.PRODUCT (ProductID, ProductName, ProductType, SupplierName)
	SELECT p.ProductID, p.ProductName, p.ProductType, s.SupplierName
		FROM BigZ_Orders.PRODUCT AS p, BigZ_Orders.SUPPLIER AS s
			WHERE p.SupplierID = s.SupplierID;

INSERT INTO BigZ_Dimensional.ORDER_QUANTITY_FACT (Calendarkey, CustomerKey, Depotkey, OrderClerkKey, ProductKey, OrderID, TIME, Quantity) 
	SELECT C.CalendarKey, CU.CustomerKey, D.DepotKey, OC.OCKey, P.ProductKey, OV.OrderID, O.OrderTime, sum(OV.Quantity)
		FROM BigZ_Dimensional.CALENDAR AS C, BigZ_Dimensional.CUSTOMER AS CU, BigZ_Dimensional.Depot AS D, BigZ_Dimensional.ORDERCLERK AS OC, 
			BigZ_Dimensional.PRODUCT AS P, BigZ_Orders.ORDER_ AS O, BigZ_Orders.ORDERVIA AS OV
			WHERE O.OrderDate = C.FullDate AND O.CustomerID = CU.CustomerID AND O.DepotID = D.DepotID AND O.OCID = OC.OCID AND OV.ProductID = 
			P.ProductID AND OV.OrderID = O.OrderIDGROUP 
				BY OV.OrderID, OV.ProductID;

INSERT INTO BigZ_Normalized.ORDERCLERK (OCID, OCName, Title, EducationLevel, YearOfHire)
	SELECT HR.EmployeeID as OCID, HR.Name as OCName, HR.Title, HR.EducationLevel, HR.YearOfHire 
		FROM BigZ_HR_Table.HRDEPARTMENT HR, BigZ_Orders.ORDERCLERK OC
			WHERE HR.EmployeeID= OC.OCID;

INSERT INTO BigZ_Normalized.CUSTOMER 
	SELECT *
		FROM BigZ_Orders.CUSTOMER;

INSERT INTO BigZ_Normalized.DEPOT
	SELECT *
		FROM BigZ_Orders.DEPOT;

INSERT INTO BigZ_Normalized.PRODUCT 
	SELECT p.ProductID, p.ProductName, p.ProductType, s.SupplierName
		FROM BigZ_Orders.PRODUCT as p, BigZ_Orders.SUPPLIER AS s
			WHERE p.SupplierID = s.SupplierID;

INSERT INTO BigZ_Normalized.ORDER_ 
	SELECT * 
		FROM BigZ_Orders.ORDER_;

INSERT INTO BigZ_Normalized.ORDERVIA 
	SELECT * 
		FROM BigZ_Orders.ORDERVIA;
