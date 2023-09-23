CREATE OR REPLACE VIEW dbo.WeekEndsAndHolidays
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,DAYOFWEEKDATE
		,DAYNAME
		,WEEKENDSANDHOLIDAYID
FROM src.WeekEndsAndHolidays
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


