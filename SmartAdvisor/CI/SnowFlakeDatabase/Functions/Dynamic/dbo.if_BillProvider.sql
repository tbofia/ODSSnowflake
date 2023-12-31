CREATE OR REPLACE FUNCTION dbo.if_BillProvider(
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
		,CLIENTCODE VARCHAR(4)
		,BILLSEQ NUMBER(10,0)
		,BILLPROVIDERSEQ NUMBER(10,0)
		,QUALIFIER VARCHAR(2)
		,LASTNAME VARCHAR(40)
		,FIRSTNAME VARCHAR(30)
		,MIDDLENAME VARCHAR(25)
		,SUFFIX VARCHAR(10)
		,NPI VARCHAR(10)
		,LICENSENUM VARCHAR(30)
		,DEANUM VARCHAR(9) )
AS
$$
SELECT T.ODSPOSTINGGROUPAUDITID
		,T.ODSCUSTOMERID
		,T.ODSCREATEDATE
		,T.ODSSNAPSHOTDATE
		,T.ODSROWISCURRENT
		,T.ODSHASHBYTESVALUE
		,T.DMLOPERATION
		,T.CLIENTCODE
		,T.BILLSEQ
		,T.BILLPROVIDERSEQ
		,T.QUALIFIER
		,T.LASTNAME
		,T.FIRSTNAME
		,T.MIDDLENAME
		,T.SUFFIX
		,T.NPI
		,T.LICENSENUM
		,T.DEANUM
FROM src.BillProvider T
INNER JOIN (
	SELECT 
		ODSCUSTOMERID,
		CLIENTCODE,
		BILLSEQ,
		BILLPROVIDERSEQ,
		MAX(ODSPOSTINGGROUPAUDITID) AS ODSPOSTINGGROUPAUDITID
	FROM src.BillProvider
	WHERE ODSPOSTINGGROUPAUDITID <= IF_ODSPOSTINGGROUPAUDITID
	GROUP BY ODSCUSTOMERID,
		CLIENTCODE,
		BILLSEQ,
		BILLPROVIDERSEQ) S
ON T.ODSPOSTINGGROUPAUDITID = S.ODSPOSTINGGROUPAUDITID
	AND T.ODSCUSTOMERID = S.ODSCUSTOMERID
	AND T.CLIENTCODE = S.CLIENTCODE
	AND T.BILLSEQ = S.BILLSEQ
	AND T.BILLPROVIDERSEQ = S.BILLPROVIDERSEQ
WHERE T.DMLOPERATION <> 'D'

$$;


