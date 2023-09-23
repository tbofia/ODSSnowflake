CREATE OR REPLACE VIEW dbo.FSProcedureMV
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
		,PROCEDURECODE
		,EFFECTIVEDATE
		,TERMINATIONDATE
		,FSPROCDESCRIPTION
		,SV
		,STAR
		,PANEL
		,IP
		,MULT
		,ASSTSURGEON
		,SECTIONFLAG
		,FUP
		,BAV
		,PROCGROUP
		,VIEWTYPE
		,UNITVALUE
		,PROUNITVALUE
		,TECHUNITVALUE
		,SITECODE
FROM src.FSProcedureMV
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

