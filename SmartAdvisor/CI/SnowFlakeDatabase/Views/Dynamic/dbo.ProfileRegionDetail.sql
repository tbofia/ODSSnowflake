CREATE OR REPLACE VIEW dbo.ProfileRegionDetail
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,PROFILEREGIONSITECODE
		,PROFILEREGIONID
		,ZIPCODEFROM
		,ZIPCODETO
FROM src.ProfileRegionDetail
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

