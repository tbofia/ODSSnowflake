CREATE OR REPLACE VIEW aw.AnalysisRuleGroup
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,ANALYSISRULEGROUPID
		,ANALYSISRULEID
		,ANALYSISGROUPID
FROM src.AnalysisRuleGroup
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


