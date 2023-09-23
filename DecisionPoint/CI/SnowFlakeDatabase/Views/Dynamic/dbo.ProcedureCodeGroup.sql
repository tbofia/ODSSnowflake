CREATE OR REPLACE VIEW dbo.ProcedureCodeGroup
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,PROCEDURECODE
		,MAJORCATEGORY
		,MINORCATEGORY
FROM src.ProcedureCodeGroup
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

