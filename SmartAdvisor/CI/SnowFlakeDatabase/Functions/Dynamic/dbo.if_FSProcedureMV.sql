CREATE OR REPLACE FUNCTION dbo.if_FSProcedureMV(
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
		,JURISDICTION VARCHAR(2)
		,EXTENSION VARCHAR(3)
		,PROCEDURECODE VARCHAR(6)
		,EFFECTIVEDATE DATETIME
		,TERMINATIONDATE DATETIME
		,FSPROCDESCRIPTION VARCHAR(24)
		,SV VARCHAR(1)
		,STAR VARCHAR(1)
		,PANEL VARCHAR(1)
		,IP VARCHAR(1)
		,MULT VARCHAR(1)
		,ASSTSURGEON VARCHAR(1)
		,SECTIONFLAG VARCHAR(1)
		,FUP VARCHAR(3)
		,BAV NUMBER(5,0)
		,PROCGROUP VARCHAR(4)
		,VIEWTYPE NUMBER(5,0)
		,UNITVALUE NUMBER(19,4)
		,PROUNITVALUE NUMBER(19,4)
		,TECHUNITVALUE NUMBER(19,4)
		,SITECODE VARCHAR(3) )
AS
$$
SELECT T.ODSPOSTINGGROUPAUDITID
		,T.ODSCUSTOMERID
		,T.ODSCREATEDATE
		,T.ODSSNAPSHOTDATE
		,T.ODSROWISCURRENT
		,T.ODSHASHBYTESVALUE
		,T.DMLOPERATION
		,T.JURISDICTION
		,T.EXTENSION
		,T.PROCEDURECODE
		,T.EFFECTIVEDATE
		,T.TERMINATIONDATE
		,T.FSPROCDESCRIPTION
		,T.SV
		,T.STAR
		,T.PANEL
		,T.IP
		,T.MULT
		,T.ASSTSURGEON
		,T.SECTIONFLAG
		,T.FUP
		,T.BAV
		,T.PROCGROUP
		,T.VIEWTYPE
		,T.UNITVALUE
		,T.PROUNITVALUE
		,T.TECHUNITVALUE
		,T.SITECODE
FROM src.FSProcedureMV T
INNER JOIN (
	SELECT 
		ODSCUSTOMERID,
		JURISDICTION,
		EXTENSION,
		PROCEDURECODE,
		EFFECTIVEDATE,
		MAX(ODSPOSTINGGROUPAUDITID) AS ODSPOSTINGGROUPAUDITID
	FROM src.FSProcedureMV
	WHERE ODSPOSTINGGROUPAUDITID <= IF_ODSPOSTINGGROUPAUDITID
	GROUP BY ODSCUSTOMERID,
		JURISDICTION,
		EXTENSION,
		PROCEDURECODE,
		EFFECTIVEDATE) S
ON T.ODSPOSTINGGROUPAUDITID = S.ODSPOSTINGGROUPAUDITID
	AND T.ODSCUSTOMERID = S.ODSCUSTOMERID
	AND T.JURISDICTION = S.JURISDICTION
	AND T.EXTENSION = S.EXTENSION
	AND T.PROCEDURECODE = S.PROCEDURECODE
	AND T.EFFECTIVEDATE = S.EFFECTIVEDATE
WHERE T.DMLOPERATION <> 'D'

$$;

