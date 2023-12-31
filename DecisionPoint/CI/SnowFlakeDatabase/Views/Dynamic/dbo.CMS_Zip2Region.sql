CREATE OR REPLACE VIEW dbo.CMS_Zip2Region
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,STARTDATE
		,ENDDATE
		,ZIP_CODE
		,STATE
		,REGION
		,AMBREGION
		,RURALFLAG
		,ASCREGION
		,PLUSFOUR
		,CARRIERID
FROM src.CMS_Zip2Region
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


