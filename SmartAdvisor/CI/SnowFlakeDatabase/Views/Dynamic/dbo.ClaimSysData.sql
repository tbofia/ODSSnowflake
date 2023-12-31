CREATE OR REPLACE VIEW dbo.ClaimSysData
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,CLAIMSYSSUBSET
		,TYPECODE
		,SUBTYPE
		,SUBSEQ
		,NUMDATA
		,TEXTDATA
FROM src.ClaimSysData
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


