CREATE OR REPLACE VIEW dbo.Bills_Pharm_OverrideEndNotes
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,OVERRIDEENDNOTEID
		,BILLIDNO
		,LINE_NO
		,OVERRIDEENDNOTE
		,PERCENTDISCOUNT
		,ACTIONID
FROM src.Bills_Pharm_OverrideEndNotes
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


