CREATE OR REPLACE VIEW dbo.PPORateType
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,RATETYPECODE
		,PPONETWORKID
		,CATEGORY
		,PRIORITY
		,VBCOLOR
		,RATETYPEDESCRIPTION
		,EXPLANATION
FROM src.PPORateType
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


