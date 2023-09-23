CREATE OR REPLACE VIEW dbo.ProviderSpecialty
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,ID
		,DESCRIPTION
		,IMPLEMENTATIONDATE
		,DEACTIVATIONDATE
		,DATASOURCE
		,CREATOR
		,CREATEDATE
		,LASTUPDATER
		,LASTUPDATEDATE
		,CBRCODE
FROM src.ProviderSpecialty
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

