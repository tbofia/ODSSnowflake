CREATE OR REPLACE FUNCTION dbo.if_ProfileRegionDetail(
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
		,PROFILEREGIONSITECODE VARCHAR(3)
		,PROFILEREGIONID NUMBER(10,0)
		,ZIPCODEFROM VARCHAR(5)
		,ZIPCODETO VARCHAR(5) )
AS
$$
SELECT T.ODSPOSTINGGROUPAUDITID
		,T.ODSCUSTOMERID
		,T.ODSCREATEDATE
		,T.ODSSNAPSHOTDATE
		,T.ODSROWISCURRENT
		,T.ODSHASHBYTESVALUE
		,T.DMLOPERATION
		,T.PROFILEREGIONSITECODE
		,T.PROFILEREGIONID
		,T.ZIPCODEFROM
		,T.ZIPCODETO
FROM src.ProfileRegionDetail T
INNER JOIN (
	SELECT 
		ODSCUSTOMERID,
		PROFILEREGIONSITECODE,
		PROFILEREGIONID,
		ZIPCODEFROM,
		MAX(ODSPOSTINGGROUPAUDITID) AS ODSPOSTINGGROUPAUDITID
	FROM src.ProfileRegionDetail
	WHERE ODSPOSTINGGROUPAUDITID <= IF_ODSPOSTINGGROUPAUDITID
	GROUP BY ODSCUSTOMERID,
		PROFILEREGIONSITECODE,
		PROFILEREGIONID,
		ZIPCODEFROM) S
ON T.ODSPOSTINGGROUPAUDITID = S.ODSPOSTINGGROUPAUDITID
	AND T.ODSCUSTOMERID = S.ODSCUSTOMERID
	AND T.PROFILEREGIONSITECODE = S.PROFILEREGIONSITECODE
	AND T.PROFILEREGIONID = S.PROFILEREGIONID
	AND T.ZIPCODEFROM = S.ZIPCODEFROM
WHERE T.DMLOPERATION <> 'D'

$$;


