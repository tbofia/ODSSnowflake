CREATE OR REPLACE FUNCTION dbo.if_BILL_HDR(
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
		,BillIDNo NUMBER(10,0)
		,CMT_HDR_IDNo NUMBER(10,0)
		,DateSaved DATETIME
		,DateRcv DATETIME
		,InvoiceNumber VARCHAR(40)
		,InvoiceDate DATETIME
		,FileNumber VARCHAR(50)
		,Note VARCHAR(20)
		,NoLines NUMBER(5,0)
		,AmtCharged NUMBER(19,4)
		,AmtAllowed NUMBER(19,4)
		,ReasonVersion NUMBER(5,0)
		,Region VARCHAR(50)
		,PvdUpdateCounter NUMBER(5,0)
		,FeatureID NUMBER(10,0)
		,ClaimDateLoss DATETIME
		,CV_Type VARCHAR(2)
		,Flags NUMBER(10,0)
		,WhoCreate VARCHAR(15)
		,WhoLast VARCHAR(15)
		,AcceptAssignment NUMBER(5,0)
		,EmergencyService NUMBER(5,0)
		,CmtPaidDeductible NUMBER(19,4)
		,InsPaidLimit NUMBER(19,4)
		,StatusFlag VARCHAR(2)
		,OfficeId NUMBER(10,0)
		,CmtPaidCoPay NUMBER(19,4)
		,AmbulanceMethod NUMBER(5,0)
		,StatusDate DATETIME
		,Category NUMBER(10,0)
		,CatDesc VARCHAR(1000)
		,AssignedUser VARCHAR(15)
		,CreateDate DATETIME
		,PvdZOS VARCHAR(12)
		,PPONumberSent NUMBER(5,0)
		,AdmissionDate DATETIME
		,DischargeDate DATETIME
		,DischargeStatus NUMBER(5,0)
		,TypeOfBill VARCHAR(4)
		,SentryMessage VARCHAR(1000)
		,AmbulanceZipOfPickup VARCHAR(12)
		,AmbulanceNumberOfPatients NUMBER(5,0)
		,WhoCreateID NUMBER(10,0)
		,WhoLastId NUMBER(10,0)
		,NYRequestDate DATETIME
		,NYReceivedDate DATETIME
		,ImgDocId VARCHAR(50)
		,PaymentDecision NUMBER(5,0)
		,PvdCMSId VARCHAR(6)
		,PvdNPINo VARCHAR(15)
		,DischargeHour VARCHAR(2)
		,PreCertChanged NUMBER(5,0)
		,DueDate DATETIME
		,AttorneyIDNo NUMBER(10,0)
		,AssignedGroup NUMBER(10,0)
		,LastChangedOn DATETIME
		,PrePPOAllowed NUMBER(19,4)
		,PPSCode NUMBER(5,0)
		,SOI NUMBER(5,0)
		,StatementStartDate DATETIME
		,StatementEndDate DATETIME
		,DeductibleOverride BOOLEAN
		,AdmissionType NUMBER(3,0)
		,CoverageType VARCHAR(2)
		,PricingProfileId NUMBER(10,0)
		,DesignatedPricingState VARCHAR(2)
		,DateAnalyzed DATETIME
		,SentToPpoSysId NUMBER(10,0)
		,PricingState VARCHAR(2)
		,BillVpnEligible BOOLEAN
		,ApportionmentPercentage NUMBER(5,2)
		,BillSourceId NUMBER(3,0)
		,OutOfStateProviderNumber NUMBER(10,0)
		,FloridaDeductibleRuleEligible BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIDNo
		,t.CMT_HDR_IDNo
		,t.DateSaved
		,t.DateRcv
		,t.InvoiceNumber
		,t.InvoiceDate
		,t.FileNumber
		,t.Note
		,t.NoLines
		,t.AmtCharged
		,t.AmtAllowed
		,t.ReasonVersion
		,t.Region
		,t.PvdUpdateCounter
		,t.FeatureID
		,t.ClaimDateLoss
		,t.CV_Type
		,t.Flags
		,t.WhoCreate
		,t.WhoLast
		,t.AcceptAssignment
		,t.EmergencyService
		,t.CmtPaidDeductible
		,t.InsPaidLimit
		,t.StatusFlag
		,t.OfficeId
		,t.CmtPaidCoPay
		,t.AmbulanceMethod
		,t.StatusDate
		,t.Category
		,t.CatDesc
		,t.AssignedUser
		,t.CreateDate
		,t.PvdZOS
		,t.PPONumberSent
		,t.AdmissionDate
		,t.DischargeDate
		,t.DischargeStatus
		,t.TypeOfBill
		,t.SentryMessage
		,t.AmbulanceZipOfPickup
		,t.AmbulanceNumberOfPatients
		,t.WhoCreateID
		,t.WhoLastId
		,t.NYRequestDate
		,t.NYReceivedDate
		,t.ImgDocId
		,t.PaymentDecision
		,t.PvdCMSId
		,t.PvdNPINo
		,t.DischargeHour
		,t.PreCertChanged
		,t.DueDate
		,t.AttorneyIDNo
		,t.AssignedGroup
		,t.LastChangedOn
		,t.PrePPOAllowed
		,t.PPSCode
		,t.SOI
		,t.StatementStartDate
		,t.StatementEndDate
		,t.DeductibleOverride
		,t.AdmissionType
		,t.CoverageType
		,t.PricingProfileId
		,t.DesignatedPricingState
		,t.DateAnalyzed
		,t.SentToPpoSysId
		,t.PricingState
		,t.BillVpnEligible
		,t.ApportionmentPercentage
		,t.BillSourceId
		,t.OutOfStateProviderNumber
		,t.FloridaDeductibleRuleEligible
FROM src.BILL_HDR t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILL_HDR
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
WHERE t.DmlOperation <> 'D'

$$;


