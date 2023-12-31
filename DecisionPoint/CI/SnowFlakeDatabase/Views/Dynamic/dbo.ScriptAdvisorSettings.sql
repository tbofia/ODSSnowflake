CREATE OR REPLACE VIEW dbo.ScriptAdvisorSettings
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,SCRIPTADVISORSETTINGSID
		,ISPHARMACYELIGIBLE
		,ENABLESENDCARDTOCLAIMANT
		,ENABLEBILLSOURCE
FROM src.ScriptAdvisorSettings
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


