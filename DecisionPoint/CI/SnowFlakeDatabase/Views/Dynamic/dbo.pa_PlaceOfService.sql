CREATE OR REPLACE VIEW dbo.pa_PlaceOfService
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,POS
		,DESCRIPTION
		,FACILITY
		,MHL
		,PLUSFOUR
		,INSTITUTION
FROM src.pa_PlaceOfService
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


