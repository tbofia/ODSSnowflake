CREATE OR REPLACE VIEW dbo.RPT_RsnCategories
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,CATEGORYIDNO
		,CATDESC
		,PRIORITY
FROM src.RPT_RsnCategories
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


