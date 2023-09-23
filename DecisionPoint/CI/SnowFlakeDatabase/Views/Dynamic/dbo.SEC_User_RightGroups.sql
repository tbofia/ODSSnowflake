CREATE OR REPLACE VIEW dbo.SEC_User_RightGroups
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,SECUSERRIGHTGROUPID
		,USERID
		,RIGHTGROUPID
FROM src.SEC_User_RightGroups
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

