CREATE OR REPLACE VIEW dbo.SENTRY_PROFILE_RULE
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,PROFILEID
		,RULEID
		,PRIORITY
FROM src.SENTRY_PROFILE_RULE
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


