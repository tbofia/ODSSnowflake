CREATE OR REPLACE VIEW dbo.ClaimICDDiagnosis
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,CLAIMSYSSUBSET
		,CLAIMSEQ
		,CLAIMDIAGNOSISSEQ
		,ICDDIAGNOSISID
FROM src.ClaimICDDiagnosis
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

