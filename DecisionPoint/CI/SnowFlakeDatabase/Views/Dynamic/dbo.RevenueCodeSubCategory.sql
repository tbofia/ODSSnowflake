CREATE OR REPLACE VIEW dbo.RevenueCodeSubCategory
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,REVENUECODESUBCATEGORYID
		,REVENUECODECATEGORYID
		,DESCRIPTION
		,NARRATIVEINFORMATION
FROM src.RevenueCodeSubCategory
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


