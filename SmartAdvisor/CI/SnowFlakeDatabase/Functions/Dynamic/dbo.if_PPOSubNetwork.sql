CREATE OR REPLACE FUNCTION dbo.if_PPOSubNetwork(
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
		,PPONETWORKID VARCHAR(2)
		,GROUPCODE VARCHAR(3)
		,GROUPNAME VARCHAR(40)
		,EXTERNALID VARCHAR(30)
		,SITECODE VARCHAR(3)
		,CREATEDATE DATETIME
		,CREATEUSERID VARCHAR(2)
		,MODDATE DATETIME
		,MODUSERID VARCHAR(2)
		,STREET1 VARCHAR(30)
		,STREET2 VARCHAR(30)
		,CITY VARCHAR(15)
		,STATE VARCHAR(2)
		,ZIP VARCHAR(10)
		,PHONENUM VARCHAR(20)
		,EMAILADDRESS VARCHAR(255)
		,WEBSITE VARCHAR(255)
		,TIN VARCHAR(9)
		,COMMENT VARCHAR(4000) )
AS
$$
SELECT T.ODSPOSTINGGROUPAUDITID
		,T.ODSCUSTOMERID
		,T.ODSCREATEDATE
		,T.ODSSNAPSHOTDATE
		,T.ODSROWISCURRENT
		,T.ODSHASHBYTESVALUE
		,T.DMLOPERATION
		,T.PPONETWORKID
		,T.GROUPCODE
		,T.GROUPNAME
		,T.EXTERNALID
		,T.SITECODE
		,T.CREATEDATE
		,T.CREATEUSERID
		,T.MODDATE
		,T.MODUSERID
		,T.STREET1
		,T.STREET2
		,T.CITY
		,T.STATE
		,T.ZIP
		,T.PHONENUM
		,T.EMAILADDRESS
		,T.WEBSITE
		,T.TIN
		,T.COMMENT
FROM src.PPOSubNetwork T
INNER JOIN (
	SELECT 
		ODSCUSTOMERID,
		PPONETWORKID,
		GROUPCODE,
		MAX(ODSPOSTINGGROUPAUDITID) AS ODSPOSTINGGROUPAUDITID
	FROM src.PPOSubNetwork
	WHERE ODSPOSTINGGROUPAUDITID <= IF_ODSPOSTINGGROUPAUDITID
	GROUP BY ODSCUSTOMERID,
		PPONETWORKID,
		GROUPCODE) S
ON T.ODSPOSTINGGROUPAUDITID = S.ODSPOSTINGGROUPAUDITID
	AND T.ODSCUSTOMERID = S.ODSCUSTOMERID
	AND T.PPONETWORKID = S.PPONETWORKID
	AND T.GROUPCODE = S.GROUPCODE
WHERE T.DMLOPERATION <> 'D'

$$;


