CREATE OR REPLACE VIEW aw.EventLog
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,EVENTLOGID
		,OBJECTNAME
		,OBJECTID
		,USERNAME
		,LOGDATE
		,ACTIONNAME
		,ORGANIZATIONID
FROM src.EventLog
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

