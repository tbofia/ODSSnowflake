CREATE OR REPLACE VIEW dbo.StateSettingsOregon
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,STATESETTINGSOREGONID
		,APPLYOREGONFEESCHEDULE
FROM src.StateSettingsOregon
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


