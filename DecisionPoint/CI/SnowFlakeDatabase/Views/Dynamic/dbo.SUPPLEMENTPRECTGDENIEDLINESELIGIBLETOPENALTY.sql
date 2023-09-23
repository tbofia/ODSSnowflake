CREATE OR REPLACE VIEW dbo.SUPPLEMENTPRECTGDENIEDLINESELIGIBLETOPENALTY
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,BILLIDNO
		,LINENUMBER
		,CTGPENALTYTYPEID
		,SEQNO
FROM src.SUPPLEMENTPRECTGDENIEDLINESELIGIBLETOPENALTY
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';
