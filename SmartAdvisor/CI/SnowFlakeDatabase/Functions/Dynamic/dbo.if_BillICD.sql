CREATE OR REPLACE FUNCTION dbo.if_BillICD(
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
		,BILLICDSEQ NUMBER(5,0)
		,CODETYPE VARCHAR(1)
		,ICDCODE VARCHAR(8)
		,CODEDATE DATETIME
		,POA VARCHAR(1) )
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
		,T.BILLICDSEQ
		,T.CODETYPE
		,T.ICDCODE
		,T.CODEDATE
		,T.POA
FROM src.BillICD T
INNER JOIN (
	SELECT 
		ODSCUSTOMERID,
		CLIENTCODE,
		BILLSEQ,
		BILLICDSEQ,
		CODETYPE,
		MAX(ODSPOSTINGGROUPAUDITID) AS ODSPOSTINGGROUPAUDITID
	FROM src.BillICD
	WHERE ODSPOSTINGGROUPAUDITID <= IF_ODSPOSTINGGROUPAUDITID
	GROUP BY ODSCUSTOMERID,
		CLIENTCODE,
		BILLSEQ,
		BILLICDSEQ,
		CODETYPE) S
ON T.ODSPOSTINGGROUPAUDITID = S.ODSPOSTINGGROUPAUDITID
	AND T.ODSCUSTOMERID = S.ODSCUSTOMERID
	AND T.CLIENTCODE = S.CLIENTCODE
	AND T.BILLSEQ = S.BILLSEQ
	AND T.BILLICDSEQ = S.BILLICDSEQ
	AND T.CODETYPE = S.CODETYPE
WHERE T.DMLOPERATION <> 'D'

$$;


