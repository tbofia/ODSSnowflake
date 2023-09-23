CREATE OR REPLACE FUNCTION dbo.if_ICD_Diagnosis(
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
		,ICDDIAGNOSISID NUMBER(10,0)
		,CODE VARCHAR(8)
		,SHORTDESC VARCHAR(60)
		,DESCRIPTION VARCHAR(300)
		,DETAILED BOOLEAN )
AS
$$
SELECT T.ODSPOSTINGGROUPAUDITID
		,T.ODSCUSTOMERID
		,T.ODSCREATEDATE
		,T.ODSSNAPSHOTDATE
		,T.ODSROWISCURRENT
		,T.ODSHASHBYTESVALUE
		,T.DMLOPERATION
		,T.ICDDIAGNOSISID
		,T.CODE
		,T.SHORTDESC
		,T.DESCRIPTION
		,T.DETAILED
FROM src.ICD_Diagnosis T
INNER JOIN (
	SELECT 
		ODSCUSTOMERID,
		ICDDIAGNOSISID,
		MAX(ODSPOSTINGGROUPAUDITID) AS ODSPOSTINGGROUPAUDITID
	FROM src.ICD_Diagnosis
	WHERE ODSPOSTINGGROUPAUDITID <= IF_ODSPOSTINGGROUPAUDITID
	GROUP BY ODSCUSTOMERID,
		ICDDIAGNOSISID) S
ON T.ODSPOSTINGGROUPAUDITID = S.ODSPOSTINGGROUPAUDITID
	AND T.ODSCUSTOMERID = S.ODSCUSTOMERID
	AND T.ICDDIAGNOSISID = S.ICDDIAGNOSISID
WHERE T.DMLOPERATION <> 'D'

$$;

