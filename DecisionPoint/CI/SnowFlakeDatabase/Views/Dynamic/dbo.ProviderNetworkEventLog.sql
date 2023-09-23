CREATE OR REPLACE VIEW dbo.ProviderNetworkEventLog
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,IDFIELD
		,LOGDATE
		,EVENTID
		,CLAIMIDNO
		,BILLIDNO
		,USERID
		,NETWORKID
		,FILENAME
		,EXTRATEXT
		,PROCESSINFO
		,TIEREDTYPEID
		,TIERNUMBER
FROM src.ProviderNetworkEventLog
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

