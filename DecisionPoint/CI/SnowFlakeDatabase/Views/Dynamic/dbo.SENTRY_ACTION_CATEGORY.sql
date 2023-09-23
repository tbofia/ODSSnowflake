CREATE OR REPLACE VIEW dbo.SENTRY_ACTION_CATEGORY
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,ACTIONCATEGORYIDNO
		,DESCRIPTION
FROM src.SENTRY_ACTION_CATEGORY
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


