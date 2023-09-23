CREATE OR REPLACE FUNCTION dbo.if_CLAIMS(
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
		,ClaimIDNo NUMBER(10,0)
		,ClaimNo VARCHAR
		,DateLoss DATETIME
		,CV_Code VARCHAR(2)
		,DiaryIndex NUMBER(10,0)
		,LastSaved DATETIME
		,PolicyNumber VARCHAR(50)
		,PolicyHoldersName VARCHAR(30)
		,PaidDeductible NUMBER(19,4)
		,Status VARCHAR(1)
		,InUse VARCHAR(100)
		,CompanyID NUMBER(10,0)
		,OfficeIndex NUMBER(10,0)
		,AdjIdNo NUMBER(10,0)
		,PaidCoPay NUMBER(19,4)
		,AssignedUser VARCHAR(15)
		,Privatized NUMBER(5,0)
		,PolicyEffDate DATETIME
		,Deductible NUMBER(19,4)
		,LossState VARCHAR(2)
		,AssignedGroup NUMBER(10,0)
		,CreateDate DATETIME
		,LastChangedOn DATETIME
		,AllowMultiCoverage BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ClaimIDNo
		,t.ClaimNo
		,t.DateLoss
		,t.CV_Code
		,t.DiaryIndex
		,t.LastSaved
		,t.PolicyNumber
		,t.PolicyHoldersName
		,t.PaidDeductible
		,t.Status
		,t.InUse
		,t.CompanyID
		,t.OfficeIndex
		,t.AdjIdNo
		,t.PaidCoPay
		,t.AssignedUser
		,t.Privatized
		,t.PolicyEffDate
		,t.Deductible
		,t.LossState
		,t.AssignedGroup
		,t.CreateDate
		,t.LastChangedOn
		,t.AllowMultiCoverage
FROM src.CLAIMS t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CLAIMS
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimIDNo = s.ClaimIDNo
WHERE t.DmlOperation <> 'D'

$$;


