CREATE OR REPLACE VIEW dbo.Adjustment360EndNoteSubCategory
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,REASONNUMBER
		,SUBCATEGORYID
		,ENDNOTETYPEID
FROM src.Adjustment360EndNoteSubCategory
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


