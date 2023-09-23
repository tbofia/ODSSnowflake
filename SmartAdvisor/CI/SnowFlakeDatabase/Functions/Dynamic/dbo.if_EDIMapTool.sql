CREATE OR REPLACE FUNCTION dbo.if_EDIMapTool(
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
		,SITECODE VARCHAR(3)
		,EDIPORTTYPE VARCHAR(1)
		,EDIMAPTOOLID NUMBER(10,0)
		,EDISOURCEID VARCHAR(2)
		,EDIMAPTOOLNAME VARCHAR(50)
		,EDIMAPTOOLTYPE VARCHAR(4)
		,EDIMAPTOOLDESC VARCHAR(50)
		,EDIOBJECTID NUMBER(10,0)
		,MENUTITLE VARCHAR(50)
		,SECURITYLEVEL NUMBER(10,0)
		,EDIINPUTFILENAME VARCHAR(50)
		,EDIOUTPUTFILENAME VARCHAR(50)
		,EDIMULTIFILES VARCHAR(1)
		,EDIREPORTTYPE NUMBER(5,0)
		,FORMPROPERTIES VARCHAR
		,JURISDICTION VARCHAR(2)
		,EDITYPE VARCHAR(1)
		,EDIPARTNERID VARCHAR(3)
		,BILLCONTROLTABLECODE VARCHAR(4)
		,EDICONTROLFLAG VARCHAR(1)
		,BILLCONTROLSEQ NUMBER(5,0)
		,EDIOBJECTSITECODE VARCHAR(3)
		,PERMITUNDEFINEDRECIDS VARCHAR(1)
		,SELECTIONQUERY VARCHAR(255)
		,REPORTSELECTIONQUERY VARCHAR(255)
		,CLASS VARCHAR(4)
		,LINESELECTIONQUERY VARCHAR(255)
		,PORTPROPERTIES VARCHAR
		,EDIFILECONFIGSITECODE VARCHAR(3)
		,EDIFILECONFIGSEQ NUMBER(10,0)
		,LZCONTROLTABLECODE VARCHAR(4)
		,LZCONTROLSEQ NUMBER(5,0) )
AS
$$
SELECT T.ODSPOSTINGGROUPAUDITID
		,T.ODSCUSTOMERID
		,T.ODSCREATEDATE
		,T.ODSSNAPSHOTDATE
		,T.ODSROWISCURRENT
		,T.ODSHASHBYTESVALUE
		,T.DMLOPERATION
		,T.SITECODE
		,T.EDIPORTTYPE
		,T.EDIMAPTOOLID
		,T.EDISOURCEID
		,T.EDIMAPTOOLNAME
		,T.EDIMAPTOOLTYPE
		,T.EDIMAPTOOLDESC
		,T.EDIOBJECTID
		,T.MENUTITLE
		,T.SECURITYLEVEL
		,T.EDIINPUTFILENAME
		,T.EDIOUTPUTFILENAME
		,T.EDIMULTIFILES
		,T.EDIREPORTTYPE
		,T.FORMPROPERTIES
		,T.JURISDICTION
		,T.EDITYPE
		,T.EDIPARTNERID
		,T.BILLCONTROLTABLECODE
		,T.EDICONTROLFLAG
		,T.BILLCONTROLSEQ
		,T.EDIOBJECTSITECODE
		,T.PERMITUNDEFINEDRECIDS
		,T.SELECTIONQUERY
		,T.REPORTSELECTIONQUERY
		,T.CLASS
		,T.LINESELECTIONQUERY
		,T.PORTPROPERTIES
		,T.EDIFILECONFIGSITECODE
		,T.EDIFILECONFIGSEQ
		,T.LZCONTROLTABLECODE
		,T.LZCONTROLSEQ
FROM src.EDIMapTool T
INNER JOIN (
	SELECT 
		ODSCUSTOMERID,
		SITECODE,
		EDIPORTTYPE,
		EDIMAPTOOLID,
		MAX(ODSPOSTINGGROUPAUDITID) AS ODSPOSTINGGROUPAUDITID
	FROM src.EDIMapTool
	WHERE ODSPOSTINGGROUPAUDITID <= IF_ODSPOSTINGGROUPAUDITID
	GROUP BY ODSCUSTOMERID,
		SITECODE,
		EDIPORTTYPE,
		EDIMAPTOOLID) S
ON T.ODSPOSTINGGROUPAUDITID = S.ODSPOSTINGGROUPAUDITID
	AND T.ODSCUSTOMERID = S.ODSCUSTOMERID
	AND T.SITECODE = S.SITECODE
	AND T.EDIPORTTYPE = S.EDIPORTTYPE
	AND T.EDIMAPTOOLID = S.EDIMAPTOOLID
WHERE T.DMLOPERATION <> 'D'

$$;


