CREATE OR REPLACE VIEW dbo.DeductibleRuleExemptEndnote
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,ENDNOTE
		,ENDNOTETYPEID
FROM src.DeductibleRuleExemptEndnote
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


