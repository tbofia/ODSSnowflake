CREATE OR REPLACE FUNCTION dbo.if_CLAIMANT(
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
		,CmtIDNo NUMBER(10,0)
		,ClaimIDNo NUMBER(10,0)
		,CmtSSN VARCHAR(11)
		,CmtLastName VARCHAR(60)
		,CmtFirstName VARCHAR(35)
		,CmtMI VARCHAR(1)
		,CmtDOB DATETIME
		,CmtSEX VARCHAR(1)
		,CmtAddr1 VARCHAR(55)
		,CmtAddr2 VARCHAR(55)
		,CmtCity VARCHAR(30)
		,CmtState VARCHAR(2)
		,CmtZip VARCHAR(12)
		,CmtPhone VARCHAR(25)
		,CmtOccNo VARCHAR(11)
		,CmtAttorneyNo NUMBER(10,0)
		,CmtPolicyLimit NUMBER(19,4)
		,CmtStateOfJurisdiction VARCHAR(2)
		,CmtDeductible NUMBER(19,4)
		,CmtCoPaymentPercentage NUMBER(5,0)
		,CmtCoPaymentMax NUMBER(19,4)
		,CmtPPO_Eligible NUMBER(5,0)
		,CmtCoordBenefits NUMBER(5,0)
		,CmtFLCopay NUMBER(5,0)
		,CmtCOAExport DATETIME
		,CmtPGFirstName VARCHAR(30)
		,CmtPGLastName VARCHAR(30)
		,CmtDedType NUMBER(5,0)
		,ExportToClaimIQ NUMBER(5,0)
		,CmtInactive NUMBER(5,0)
		,CmtPreCertOption NUMBER(5,0)
		,CmtPreCertState VARCHAR(2)
		,CreateDate DATETIME
		,LastChangedOn DATETIME
		,OdsParticipant BOOLEAN
		,CoverageType VARCHAR(2)
		,DoNotDisplayCoverageTypeOnEOB BOOLEAN
		,ShowAllocationsOnEob BOOLEAN
		,SetPreAllocation BOOLEAN
		,PharmacyEligible NUMBER(3,0)
		,SendCardToClaimant NUMBER(3,0)
		,ShareCoPayMaximum BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CmtIDNo
		,t.ClaimIDNo
		,t.CmtSSN
		,t.CmtLastName
		,t.CmtFirstName
		,t.CmtMI
		,t.CmtDOB
		,t.CmtSEX
		,t.CmtAddr1
		,t.CmtAddr2
		,t.CmtCity
		,t.CmtState
		,t.CmtZip
		,t.CmtPhone
		,t.CmtOccNo
		,t.CmtAttorneyNo
		,t.CmtPolicyLimit
		,t.CmtStateOfJurisdiction
		,t.CmtDeductible
		,t.CmtCoPaymentPercentage
		,t.CmtCoPaymentMax
		,t.CmtPPO_Eligible
		,t.CmtCoordBenefits
		,t.CmtFLCopay
		,t.CmtCOAExport
		,t.CmtPGFirstName
		,t.CmtPGLastName
		,t.CmtDedType
		,t.ExportToClaimIQ
		,t.CmtInactive
		,t.CmtPreCertOption
		,t.CmtPreCertState
		,t.CreateDate
		,t.LastChangedOn
		,t.OdsParticipant
		,t.CoverageType
		,t.DoNotDisplayCoverageTypeOnEOB
		,t.ShowAllocationsOnEob
		,t.SetPreAllocation
		,t.PharmacyEligible
		,t.SendCardToClaimant
		,t.ShareCoPayMaximum
FROM src.CLAIMANT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CmtIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CLAIMANT
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CmtIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CmtIDNo = s.CmtIDNo
WHERE t.DmlOperation <> 'D'

$$;


