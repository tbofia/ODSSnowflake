CREATE OR REPLACE VIEW dbo.ExtractCat
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,CATIDNO
		,DESCRIPTION
FROM src.ExtractCat
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


