CREATE OR REPLACE VIEW dbo.Claims_ClientRef
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,CLAIMIDNO
		,CLIENTREFID
FROM src.Claims_ClientRef
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


