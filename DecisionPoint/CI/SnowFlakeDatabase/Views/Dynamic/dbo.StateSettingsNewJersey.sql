CREATE OR REPLACE VIEW dbo.StateSettingsNewJersey
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,STATESETTINGSNEWJERSEYID
		,BYPASSEMERGENCYSERVICES
FROM src.StateSettingsNewJersey
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

