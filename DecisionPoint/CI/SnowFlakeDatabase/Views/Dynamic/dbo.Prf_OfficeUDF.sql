CREATE OR REPLACE VIEW dbo.Prf_OfficeUDF
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,OFFICEID
		,UDFIDNO
FROM src.Prf_OfficeUDF
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

