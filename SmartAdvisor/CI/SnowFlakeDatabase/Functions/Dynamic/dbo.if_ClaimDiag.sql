CREATE OR REPLACE FUNCTION dbo.if_ClaimDiag(
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
		,CLAIMSYSSUBSET VARCHAR(4)
		,CLAIMSEQ NUMBER(10,0)
		,CLAIMDIAGSEQ NUMBER(5,0)
		,DIAGCODE VARCHAR(8) )
AS
$$
SELECT T.ODSPOSTINGGROUPAUDITID
		,T.ODSCUSTOMERID
		,T.ODSCREATEDATE
		,T.ODSSNAPSHOTDATE
		,T.ODSROWISCURRENT
		,T.ODSHASHBYTESVALUE
		,T.DMLOPERATION
		,T.CLAIMSYSSUBSET
		,T.CLAIMSEQ
		,T.CLAIMDIAGSEQ
		,T.DIAGCODE
FROM src.ClaimDiag T
INNER JOIN (
	SELECT 
		ODSCUSTOMERID,
		CLAIMSYSSUBSET,
		CLAIMSEQ,
		CLAIMDIAGSEQ,
		MAX(ODSPOSTINGGROUPAUDITID) AS ODSPOSTINGGROUPAUDITID
	FROM src.ClaimDiag
	WHERE ODSPOSTINGGROUPAUDITID <= IF_ODSPOSTINGGROUPAUDITID
	GROUP BY ODSCUSTOMERID,
		CLAIMSYSSUBSET,
		CLAIMSEQ,
		CLAIMDIAGSEQ) S
ON T.ODSPOSTINGGROUPAUDITID = S.ODSPOSTINGGROUPAUDITID
	AND T.ODSCUSTOMERID = S.ODSCUSTOMERID
	AND T.CLAIMSYSSUBSET = S.CLAIMSYSSUBSET
	AND T.CLAIMSEQ = S.CLAIMSEQ
	AND T.CLAIMDIAGSEQ = S.CLAIMDIAGSEQ
WHERE T.DMLOPERATION <> 'D'

$$;


