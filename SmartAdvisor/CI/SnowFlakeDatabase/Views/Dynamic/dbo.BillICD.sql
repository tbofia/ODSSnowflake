CREATE OR REPLACE VIEW dbo.BillICD
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
		,BILLICDSEQ
		,CODETYPE
		,ICDCODE
		,CODEDATE
		,POA
FROM src.BillICD
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

