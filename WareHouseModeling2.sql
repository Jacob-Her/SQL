Project - Data Warehouse Modeling (MC8 - Jones Dozers)
*/

CREATE DEFINER = CURRENT_USER 

TRIGGER
	'JD_Sales_Rentals'.'SALESREP_BEFORE_INSERT' 
		BEFORE INSERT ON 'SALESREP' 
			FOR 
				EACH ROW

BEGIN
	DECLARE 
		totalproteges, totalmentors INT DEFAULT O;
	SET 
		totalproteges = (SELECT count(Mentors_SRepID) 
			FROM 
				JD_Sales_Rentals.SALESREP 
			WHERE 
				SRepID = NEW.SRepID);
	SELECT 
		count(SRepID) 
			FROM 
				JD_Sales_Rentals.SALESREP 
			WHERE
				Mentors_SRepID = NEW.Mentors_SRepID 
			INTO 
				totalmentors;
					IF 
						(totalproteges>=3 OR totalmentors >=1)
							THEN
								SET 
									NEW.SRepID = NULL;
					END IF;
END;

INSERT INTO 
	JD_SR_Dimensional.CALENDAR (FullDate, DayOfWeek, DayOfMonth, MONTH, Quarter, YEAR)
		SELECT DISTINCT 
			Date AS 
				FullDate, DAYOFWEEK(Date) AS DayOfWeek, dayofmonth(Date) AS DayOfMonth, month(Date) AS MONTH, 
				quarter(Date) AS Qtr, year(Date) AS YEÄR
			FROM 
				JD_Sales_Rentals.RENTAL 
			UNION SELECT DISTINCT 
				Date AS 
					FullDate DAYOFWEEK(Date) AS DayOfWeek, dayofmonth(Date ) AS DayOfMonth, month(Date) AS MONTH, quarter(Date) AS Qtr, year(Date) AS YEAR 
			FROM 
				JD_Sales_Rentals.SALE;

INSERT INTO 
	JD_SR_Dimensional.CUSTOMER (CustlD, CustName, CustCategory) 
		SELECT
			*FROM JD_Sales_Rentals.CUSTOMER;

INSERT INTO 
	JD_SR_Dimensional.EQUIPMENT (SerialNo, LastlnspectDate, DateMade, Make, Type, Model)
		SELECT 
			E.SerialNo, E.LastInspectDate, E.DateMade, ED.Make, ED.Type, ED.Model
				FROM 
					JD_Sales_Rentals.EQUIPMENT E, JD_Sales_Rentals.EQUIPMENTDETAIL ED
				WHERE
					E.EquipDetailID = ED.EquipDetailID;

INSERT INTO 
	JD_SR_Dimensional.REVTYPE (RevType) VALUES ('rental'), ('sale');

INSERT INTO 
	JD_SR_Dimensional.SALESREP (SRepID, SRepFName, SRepLName, Rank, NoOfProteges, NoOfMentors)
		SELECT 
			t1.SRepID, t1.SRepFName, t1.SRepLName, t1.Rank, count(t1.Mentors_SRepID) as NoOfProteges, count(t2.SRepID) as NoOfMentors 
				FROM
					JD_Sales_Rentals.SALESREP t1 LEFT JOIN JD_Sales_Rentals.SALESREP t2 ON t1.SRepID=t2.Mentors_SRepld
		GROUP BY 
			SRepID;

INSERT INTO 
	JD_SR_Dimensional.FACT (CalendarKey, RevTypeKey, Customerkey, EquipmentKey, SRepKey, TID, RevenueAmount) 
		SELECT 
			C.CalendarKey, RT.RevTypeKey, CU.CustomerKey, EQ.EquipmentKey, SR.SRepKey, R.RentTransID, R.Price 
				FROM
					JD_SR_Dimensional.CALENDAR AS C, JD_SR_Dimensional.REVTYPE AS RT, JD_SR_Dimensional.CUSTOMER AS CU, JD_SR_Dimensional.EQUIPMENT AS EQ,
					JD_SR_Dimensional.SALESREP AS SR, JD_Sales_Rentals.RENTAL AS R 
				WHERE 
					R.Date=C.FullDate AND RT.RevType = 'rental' AND R.CustID = CU.CustID AND R.SerialNo = EQ.SerialNo AND R.SRepID = SR.SRepID 
		UNION SELECT 
			C.Calendarkey, RT.RevTypeKey, CU.CustomerKey, EQ.EquipmentKey, SR.SRepKey, S.SaleTransID, S.Price 
				FROM
					JD_SR_Dimensional.CALENDAR AS C, JD_SR_Dimensional.REVTYPE AS RT, JD_SR_Dimensional.CUSTOMER AS CU, JD_SR_Dimensional.EQUIPMENT AS EQ,
					JD_SR_Dimensional.SALESREP AS SR, JD_Sales_Rentals.SALE AS S 
				WHERE 
					S.Date=C.FullDate AND RT.RevType = 'sale' AND S.CustID = CU.CustID AND S.SerialNo EQ =.SerialNo AND S.SRepID = SR.SRepID;
