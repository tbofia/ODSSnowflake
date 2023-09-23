CREATE OR REPLACE VIEW dbo.ScriptAdvisorBillSource
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,BILLSOURCEID
		,BILLSOURCE
FROM src.ScriptAdvisorBillSource
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


