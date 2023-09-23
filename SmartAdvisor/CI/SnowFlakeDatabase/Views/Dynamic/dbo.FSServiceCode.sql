CREATE OR REPLACE VIEW dbo.FSServiceCode
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
		,SERVICECODE
		,GEOAREACODE
		,EFFECTIVEDATE
		,DESCRIPTION
		,TERMDATE
		,CODESOURCE
		,CODEGROUP
FROM src.FSServiceCode
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

