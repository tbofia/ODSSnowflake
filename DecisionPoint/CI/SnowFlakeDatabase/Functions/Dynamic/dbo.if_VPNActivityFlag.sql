CREATE OR REPLACE FUNCTION dbo.if_VPNActivityFlag(
		if_OdsPostingGroupAuditId INT
)
RETURNS TABLE  (
		 OdsPostingGroupAuditId NUMBER(10,0)
		,OdsCustomerId NUMBER(10,0)
		,OdsCreateDate DATETIME
		,OdsSnapshotDate DATETIME
		,OdsRowIsCurrent INT
		,OdsHashbytesValue BINARY(8000)
		,DmlOperation VARCHAR(1)
		,Activity_Flag VARCHAR(1)
		,AF_Description VARCHAR(50)
		,AF_ShortDesc VARCHAR(50)
		,Data_Source VARCHAR(5)
		,Default_Billable BOOLEAN
		,Credit BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.Activity_Flag
		,t.AF_Description
		,t.AF_ShortDesc
		,t.Data_Source
		,t.Default_Billable
		,t.Credit
FROM src.VPNActivityFlag t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Activity_Flag,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VPNActivityFlag
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Activity_Flag) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Activity_Flag = s.Activity_Flag
WHERE t.DmlOperation <> 'D'

$$;


