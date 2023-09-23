CREATE OR REPLACE FUNCTION dbo.if_VpnBillableFlags(
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
		,SOJ VARCHAR(2)
		,NetworkID NUMBER(10,0)
		,ActivityFlag VARCHAR(2)
		,Billable VARCHAR(1)
		,CompanyCode VARCHAR(10)
		,CompanyName VARCHAR(100) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.SOJ
		,t.NetworkID
		,t.ActivityFlag
		,t.Billable
		,t.CompanyCode
		,t.CompanyName
FROM src.VpnBillableFlags t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CompanyCode,
		SOJ,
		NetworkID,
		ActivityFlag,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnBillableFlags
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CompanyCode,
		SOJ,
		NetworkID,
		ActivityFlag) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CompanyCode = s.CompanyCode
	AND t.SOJ = s.SOJ
	AND t.NetworkID = s.NetworkID
	AND t.ActivityFlag = s.ActivityFlag
WHERE t.DmlOperation <> 'D'

$$;


