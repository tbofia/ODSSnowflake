CREATE OR REPLACE VIEW dbo.BillsProviderNetwork
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,BILLIDNO
		,NETWORKID
		,NETWORKNAME
FROM src.BillsProviderNetwork
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


