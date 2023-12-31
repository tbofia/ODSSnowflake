CREATE OR REPLACE VIEW dbo.MedicareICQM
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,JURISDICTION
		,MDICQMSEQ
		,PROVIDERNUM
		,PROVSUFFIX
		,SERVICECODE
		,HCPCS
		,REVENUE
		,MEDICAREICQMDESCRIPTION
		,IP1995
		,OP1995
		,IP1996
		,OP1996
		,IP1997
		,OP1997
		,IP1998
		,OP1998
		,NPI
FROM src.MedicareICQM
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


