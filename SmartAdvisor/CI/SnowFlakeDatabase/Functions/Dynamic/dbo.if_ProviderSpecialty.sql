CREATE OR REPLACE FUNCTION dbo.if_ProviderSpecialty(
		IF_ODSPOSTINGGROUPAUDITID INT
)
RETURNS TABLE  (
		 ODSPOSTINGGROUPAUDITID NUMBER(10,0)
		,ODSCUSTOMERID NUMBER(10,0)
		,ODSCREATEDATE DATETIME
		,ODSSNAPSHOTDATE DATETIME
		,ODSROWISCURRENT INT
		,ODSHASHBYTESVALUE BINARY(8000)
		,DMLOPERATION VARCHAR(1)
		,ID VARCHAR
		,DESCRIPTION VARCHAR
		,IMPLEMENTATIONDATE TIMESTAMP_NTZ(0)
		,DEACTIVATIONDATE TIMESTAMP_NTZ(0)
		,DATASOURCE VARCHAR
		,CREATOR VARCHAR(128)
		,CREATEDATE TIMESTAMP_NTZ(0)
		,LASTUPDATER VARCHAR(128)
		,LASTUPDATEDATE TIMESTAMP_NTZ(0)
		,CBRCODE VARCHAR(4) )
AS
$$
SELECT T.ODSPOSTINGGROUPAUDITID
		,T.ODSCUSTOMERID
		,T.ODSCREATEDATE
		,T.ODSSNAPSHOTDATE
		,T.ODSROWISCURRENT
		,T.ODSHASHBYTESVALUE
		,T.DMLOPERATION
		,T.ID
		,T.DESCRIPTION
		,T.IMPLEMENTATIONDATE
		,T.DEACTIVATIONDATE
		,T.DATASOURCE
		,T.CREATOR
		,T.CREATEDATE
		,T.LASTUPDATER
		,T.LASTUPDATEDATE
		,T.CBRCODE
FROM src.ProviderSpecialty T
INNER JOIN (
	SELECT 
		ODSCUSTOMERID,
		ID,
		MAX(ODSPOSTINGGROUPAUDITID) AS ODSPOSTINGGROUPAUDITID
	FROM src.ProviderSpecialty
	WHERE ODSPOSTINGGROUPAUDITID <= IF_ODSPOSTINGGROUPAUDITID
	GROUP BY ODSCUSTOMERID,
		ID) S
ON T.ODSPOSTINGGROUPAUDITID = S.ODSPOSTINGGROUPAUDITID
	AND T.ODSCUSTOMERID = S.ODSCUSTOMERID
	AND T.ID = S.ID
WHERE T.DMLOPERATION <> 'D'

$$;


