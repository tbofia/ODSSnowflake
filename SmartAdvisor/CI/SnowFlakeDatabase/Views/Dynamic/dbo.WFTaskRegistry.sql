CREATE OR REPLACE VIEW dbo.WFTaskRegistry
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,WFTASKREGISTRYSEQ
		,ENTITYTYPECODE
		,DESCRIPTION
		,ACTION
		,SMALLIMAGERESID
		,LARGEIMAGERESID
		,PERSISTBEFORE
		,NACTION
FROM src.WFTaskRegistry
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


