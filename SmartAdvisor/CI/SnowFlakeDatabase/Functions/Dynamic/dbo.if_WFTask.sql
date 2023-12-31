CREATE OR REPLACE FUNCTION dbo.if_WFTask(
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
		,WFTASKSEQ NUMBER(10,0)
		,WFLOWSEQ NUMBER(10,0)
		,WFTASKREGISTRYSEQ NUMBER(10,0)
		,NAME VARCHAR(35)
		,PARAMETER1 VARCHAR(35)
		,RECORDSTATUS VARCHAR(1)
		,NODELEFT NUMBER(8,2)
		,NODETOP NUMBER(8,2)
		,CREATEUSERID VARCHAR(2)
		,CREATEDATE DATETIME
		,MODUSERID VARCHAR(2)
		,MODDATE DATETIME
		,NOPRIOR VARCHAR(1)
		,NORESTART VARCHAR(1)
		,PARAMETERX VARCHAR(2000)
		,DEFAULTPENDGROUP VARCHAR(12)
		,CONFIGURATION VARCHAR(2000) )
AS
$$
SELECT T.ODSPOSTINGGROUPAUDITID
		,T.ODSCUSTOMERID
		,T.ODSCREATEDATE
		,T.ODSSNAPSHOTDATE
		,T.ODSROWISCURRENT
		,T.ODSHASHBYTESVALUE
		,T.DMLOPERATION
		,T.WFTASKSEQ
		,T.WFLOWSEQ
		,T.WFTASKREGISTRYSEQ
		,T.NAME
		,T.PARAMETER1
		,T.RECORDSTATUS
		,T.NODELEFT
		,T.NODETOP
		,T.CREATEUSERID
		,T.CREATEDATE
		,T.MODUSERID
		,T.MODDATE
		,T.NOPRIOR
		,T.NORESTART
		,T.PARAMETERX
		,T.DEFAULTPENDGROUP
		,T.CONFIGURATION
FROM src.WFTask T
INNER JOIN (
	SELECT 
		ODSCUSTOMERID,
		WFTASKSEQ,
		MAX(ODSPOSTINGGROUPAUDITID) AS ODSPOSTINGGROUPAUDITID
	FROM src.WFTask
	WHERE ODSPOSTINGGROUPAUDITID <= IF_ODSPOSTINGGROUPAUDITID
	GROUP BY ODSCUSTOMERID,
		WFTASKSEQ) S
ON T.ODSPOSTINGGROUPAUDITID = S.ODSPOSTINGGROUPAUDITID
	AND T.ODSCUSTOMERID = S.ODSCUSTOMERID
	AND T.WFTASKSEQ = S.WFTASKSEQ
WHERE T.DMLOPERATION <> 'D'

$$;


