CREATE OR REPLACE VIEW dbo.Region
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,JURISDICTION
		,EXTENSION
		,ENDZIP
		,BEG
		,REGION
		,REGIONDESCRIPTION
FROM src.Region
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


