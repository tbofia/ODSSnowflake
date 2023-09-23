CREATE OR REPLACE VIEW dbo.Adjustment360ApcEndNoteSubCategory
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
FROM src.Adjustment360ApcEndNoteSubCategory
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


