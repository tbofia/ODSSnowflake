CREATE OR REPLACE VIEW dbo.UB_RevenueCodes
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,REVENUECODE
		,STARTDATE
		,ENDDATE
		,PRC_DESC
		,FLAGS
		,VAGUE
		,PERVISIT
		,PERCLAIMANT
		,PERPROVIDER
		,BODYFLAGS
		,DRUGFLAG
		,CURATIVEFLAG
		,REVENUECODESUBCATEGORYID
FROM src.UB_RevenueCodes
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


