CREATE OR REPLACE VIEW dbo.BillData
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,CLIENTCODE
		,BILLSEQ
		,TYPECODE
		,SUBTYPE
		,SUBSEQ
		,NUMDATA
		,TEXTDATA
		,MODDATE
		,MODUSERID
		,CREATEDATE
		,CREATEUSERID
FROM src.BillData
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


