CREATE OR REPLACE VIEW aw.AnalysisGroup
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,ANALYSISGROUPID
		,GROUPNAME
FROM src.AnalysisGroup
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


