IF OBJECT_ID('dbo.if_Adjuster', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Adjuster;
GO

CREATE FUNCTION dbo.if_Adjuster(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClaimSysSubSet,
	t.Adjuster,
	t.FirstName,
	t.LastName,
	t.MInitial,
	t.Title,
	t.Address1,
	t.Address2,
	t.City,
	t.State,
	t.Zip,
	t.PhoneNum,
	t.PhoneNumExt,
	t.FaxNum,
	t.Email,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.Adjuster t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		Adjuster,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjuster
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		Adjuster) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.Adjuster = s.Adjuster
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_AdjusterPendGroup', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_AdjusterPendGroup;
GO

CREATE FUNCTION dbo.if_AdjusterPendGroup(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClaimSysSubset,
	t.Adjuster,
	t.PendGroupCode
FROM src.AdjusterPendGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubset,
		Adjuster,
		PendGroupCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AdjusterPendGroup
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubset,
		Adjuster,
		PendGroupCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubset = s.ClaimSysSubset
	AND t.Adjuster = s.Adjuster
	AND t.PendGroupCode = s.PendGroupCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Attorney', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Attorney;
GO

CREATE FUNCTION dbo.if_Attorney(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClaimSysSubSet,
	t.AttorneySeq,
	t.TIN,
	t.TINSuffix,
	t.ExternalID,
	t.Name,
	t.GroupCode,
	t.LicenseNum,
	t.MedicareNum,
	t.PracticeAddressSeq,
	t.BillingAddressSeq,
	t.AttorneyType,
	t.Specialty1,
	t.Specialty2,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.Status,
	t.ExternalStatus,
	t.ExportDate,
	t.SsnTinIndicator,
	t.PmtDays,
	t.AuthBeginDate,
	t.AuthEndDate,
	t.TaxAddressSeq,
	t.CtrlNum1099,
	t.SurchargeCode,
	t.WorkCompNum,
	t.WorkCompState
FROM src.Attorney t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		AttorneySeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Attorney
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		AttorneySeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.AttorneySeq = s.AttorneySeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_AttorneyAddress', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_AttorneyAddress;
GO

CREATE FUNCTION dbo.if_AttorneyAddress(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClaimSysSubSet,
	t.AttorneyAddressSeq,
	t.RecType,
	t.Address1,
	t.Address2,
	t.City,
	t.State,
	t.Zip,
	t.PhoneNum,
	t.FaxNum,
	t.ContactFirstName,
	t.ContactLastName,
	t.ContactMiddleInitial,
	t.URFirstName,
	t.URLastName,
	t.URMiddleInitial,
	t.FacilityName,
	t.CountryCode,
	t.MailCode
FROM src.AttorneyAddress t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		AttorneyAddressSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AttorneyAddress
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		AttorneyAddressSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.AttorneyAddressSeq = s.AttorneyAddressSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Bill', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bill;
GO

CREATE FUNCTION dbo.if_Bill(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.BillSeq,
	t.ClaimSeq,
	t.ClaimSysSubSet,
	t.ProviderSeq,
	t.ProviderSubSet,
	t.PostDate,
	t.DOSFirst,
	t.Invoiced,
	t.InvoicedPPO,
	t.CreateUserID,
	t.CarrierSeqNew,
	t.DocCtrlType,
	t.DOSLast,
	t.PPONetworkID,
	t.POS,
	t.ProvType,
	t.ProvSpecialty1,
	t.ProvZip,
	t.ProvState,
	t.SubmitDate,
	t.ProvInvoice,
	t.Region,
	t.HospitalSeq,
	t.ModUserID,
	t.Status,
	t.StatusPrior,
	t.BillableLines,
	t.TotalCharge,
	t.BRReduction,
	t.BRFee,
	t.TotalAllow,
	t.TotalFee,
	t.DupClientCode,
	t.DupBillSeq,
	t.FupStartDate,
	t.FupEndDate,
	t.SendBackMsg1SiteCode,
	t.SendBackMsg1,
	t.SendBackMsg2SiteCode,
	t.SendBackMsg2,
	t.PPOReduction,
	t.PPOPrc,
	t.PPOContractID,
	t.PPOStatus,
	t.PPOFee,
	t.NGDReduction,
	t.NGDFee,
	t.URFee,
	t.OtherData,
	t.ExternalStatus,
	t.URFlag,
	t.Visits,
	t.TOS,
	t.TOB,
	t.SubProductCode,
	t.ForcePay,
	t.PmtAuth,
	t.FlowStatus,
	t.ConsultDate,
	t.RcvdDate,
	t.AdmissionType,
	t.PaidDate,
	t.AdmitDate,
	t.DischargeDate,
	t.TxBillType,
	t.RcvdBrDate,
	t.DueDate,
	t.Adjuster,
	t.DOI,
	t.RetCtrlFlg,
	t.RetCtrlNum,
	t.SiteCode,
	t.SourceID,
	t.CaseType,
	t.SubProductID,
	t.SubProductPrice,
	t.URReduction,
	t.ProvLicenseNum,
	t.ProvMedicareNum,
	t.ProvSpecialty2,
	t.PmtExportDate,
	t.PmtAcceptDate,
	t.ClientTOB,
	t.BRFeeNet,
	t.PPOFeeNet,
	t.NGDFeeNet,
	t.URFeeNet,
	t.SubProductPriceNet,
	t.BillSeqNewRev,
	t.BillSeqOrgRev,
	t.VocPlanSeq,
	t.ReviewDate,
	t.AuditDate,
	t.ReevalAllow,
	t.CheckNum,
	t.NegoType,
	t.DischargeHour,
	t.UB92TOB,
	t.MCO,
	t.DRG,
	t.PatientAccount,
	t.ExaminerRevFlag,
	t.RefProvName,
	t.PaidAmount,
	t.AdmissionSource,
	t.AdmitHour,
	t.PatientStatus,
	t.DRGValue,
	t.CompanySeq,
	t.TotalCoPay,
	t.UB92ProcMethod,
	t.TotalDeductible,
	t.PolicyCoPayAmount,
	t.PolicyCoPayPct,
	t.DocCtrlID,
	t.ResourceUtilGroup,
	t.PolicyDeductible,
	t.PolicyLimit,
	t.PolicyTimeLimit,
	t.PolicyWarningPct,
	t.AppBenefits,
	t.AppAssignee,
	t.CreateDate,
	t.ModDate,
	t.IncrementValue,
	t.AdjVerifRequestDate,
	t.AdjVerifRcvdDate,
	t.RenderingProvLastName,
	t.RenderingProvFirstName,
	t.RenderingProvMiddleName,
	t.RenderingProvSuffix,
	t.RereviewCount,
	t.DRGBilled,
	t.DRGCalculated,
	t.ProvRxLicenseNum,
	t.ProvSigOnFile,
	t.RefProvFirstName,
	t.RefProvMiddleName,
	t.RefProvSuffix,
	t.RefProvDEANum,
	t.SendbackMsg1Subset,
	t.SendbackMsg2Subset,
	t.PPONetworkJurisdictionInd,
	t.ManualReductionMode,
	t.WholesaleSalesTaxZip,
	t.RetailSalesTaxZip,
	t.PPONetworkJurisdictionInsurerSeq,
	t.InvoicedWholesale,
	t.InvoicedPPOWholesale,
	t.AdmittingDxRef,
	t.AdmittingDxCode,
	t.ProvFacilityNPI,
	t.ProvBillingNPI,
	t.ProvRenderingNPI,
	t.ProvOperatingNPI,
	t.ProvReferringNPI,
	t.ProvOther1NPI,
	t.ProvOther2NPI,
	t.ProvOperatingLicenseNum,
	t.EHubID,
	t.OtherBillingProviderSubset,
	t.OtherBillingProviderSeq,
	t.ResubmissionReasonCode,
	t.ContractType,
	t.ContractAmount,
	t.PriorAuthReferralNum1,
	t.PriorAuthReferralNum2,
	t.DRGCompositeFactor,
	t.DRGDischargeFraction,
	t.DRGInpatientMultiplier,
	t.DRGWeight,
	t.EFTPmtMethodCode,
	t.EFTPmtFormatCode,
	t.EFTSenderDFIID,
	t.EFTSenderAcctNum,
	t.EFTOrigCoSupplCode,
	t.EFTReceiverDFIID,
	t.EFTReceiverAcctQual,
	t.EFTReceiverAcctNum,
	t.PolicyLimitResult,
	t.HistoryBatchNumber,
	t.ProvBillingTaxonomy,
	t.ProvFacilityTaxonomy,
	t.ProvRenderingTaxonomy,
	t.PPOStackList,
	t.ICDVersion,
	t.ODGFlag,
	t.ProvBillLicenseNum,
	t.ProvFacilityLicenseNum,
	t.ProvVendorExternalID,
	t.BRActualClientCode,
	t.BROverrideClientCode,
	t.BillReevalReasonCode,
	t.PaymentClearedDate,
	t.EstimatedBRClientCode,
	t.EstimatedBRJuris,
	t.OverrideFeeControlRetail,
	t.OverrideFeeControlWholesale
FROM src.Bill t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillControl', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillControl;
GO

CREATE FUNCTION dbo.if_BillControl(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.BillSeq,
	t.BillControlSeq,
	t.ModDate,
	t.CreateDate,
	t.Control,
	t.ExternalID,
	t.BatchNumber,
	t.ModUserID,
	t.ExternalID2,
	t.Message
FROM src.BillControl t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		BillControlSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillControl
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		BillControlSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.BillControlSeq = s.BillControlSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillControlHistory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillControlHistory;
GO

CREATE FUNCTION dbo.if_BillControlHistory(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.BillControlHistorySeq,
	t.ClientCode,
	t.BillSeq,
	t.BillControlSeq,
	t.CreateDate,
	t.Control,
	t.ExternalID,
	t.EDIBatchLogSeq,
	t.Deleted,
	t.ModUserID,
	t.ExternalID2,
	t.Message
FROM src.BillControlHistory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillControlHistorySeq,
		ClientCode,
		BillSeq,
		BillControlSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillControlHistory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillControlHistorySeq,
		ClientCode,
		BillSeq,
		BillControlSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillControlHistorySeq = s.BillControlHistorySeq
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.BillControlSeq = s.BillControlSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillData', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillData;
GO

CREATE FUNCTION dbo.if_BillData(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.BillSeq,
	t.TypeCode,
	t.SubType,
	t.SubSeq,
	t.NumData,
	t.TextData,
	t.ModDate,
	t.ModUserID,
	t.CreateDate,
	t.CreateUserID
FROM src.BillData t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		TypeCode,
		SubType,
		SubSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillData
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		TypeCode,
		SubType,
		SubSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.TypeCode = s.TypeCode
	AND t.SubType = s.SubType
	AND t.SubSeq = s.SubSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillFee', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillFee;
GO

CREATE FUNCTION dbo.if_BillFee(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.BillSeq,
	t.FeeType,
	t.TransactionType,
	t.FeeCtrlSource,
	t.FeeControlSeq,
	t.FeeAmount,
	t.InvoiceSeq,
	t.InvoiceSubSeq,
	t.PPONetworkID,
	t.ReductionCode,
	t.FeeOverride,
	t.OverrideVerified,
	t.ExclusiveFee,
	t.FeeSourceID,
	t.HandlingFee
FROM src.BillFee t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		FeeType,
		TransactionType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillFee
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		FeeType,
		TransactionType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.FeeType = s.FeeType
	AND t.TransactionType = s.TransactionType
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillICD', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillICD;
GO

CREATE FUNCTION dbo.if_BillICD(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.BillSeq,
	t.BillICDSeq,
	t.CodeType,
	t.ICDCode,
	t.CodeDate,
	t.POA
FROM src.BillICD t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		BillICDSeq,
		CodeType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillICD
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		BillICDSeq,
		CodeType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.BillICDSeq = s.BillICDSeq
	AND t.CodeType = s.CodeType
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillICDDiagnosis', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillICDDiagnosis;
GO

CREATE FUNCTION dbo.if_BillICDDiagnosis(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.BillSeq,
	t.BillDiagnosisSeq,
	t.ICDDiagnosisID,
	t.POA,
	t.BilledICDDiagnosis,
	t.ICDBillUsageTypeID
FROM src.BillICDDiagnosis t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		BillDiagnosisSeq,
		ICDBillUsageTypeID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillICDDiagnosis
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		BillDiagnosisSeq,
		ICDBillUsageTypeID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.BillDiagnosisSeq = s.BillDiagnosisSeq
	AND t.ICDBillUsageTypeID = s.ICDBillUsageTypeID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillICDProcedure', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillICDProcedure;
GO

CREATE FUNCTION dbo.if_BillICDProcedure(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.BillSeq,
	t.BillProcedureSeq,
	t.ICDProcedureID,
	t.CodeDate,
	t.BilledICDProcedure,
	t.ICDBillUsageTypeID
FROM src.BillICDProcedure t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		BillProcedureSeq,
		ICDBillUsageTypeID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillICDProcedure
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		BillProcedureSeq,
		ICDBillUsageTypeID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.BillProcedureSeq = s.BillProcedureSeq
	AND t.ICDBillUsageTypeID = s.ICDBillUsageTypeID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillPPORate', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillPPORate;
GO

CREATE FUNCTION dbo.if_BillPPORate(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.BillSeq,
	t.LinkName,
	t.RateType,
	t.Applied
FROM src.BillPPORate t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		LinkName,
		RateType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillPPORate
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		LinkName,
		RateType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.LinkName = s.LinkName
	AND t.RateType = s.RateType
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillProvider', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillProvider;
GO

CREATE FUNCTION dbo.if_BillProvider(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.BillSeq,
	t.BillProviderSeq,
	t.Qualifier,
	t.LastName,
	t.FirstName,
	t.MiddleName,
	t.Suffix,
	t.NPI,
	t.LicenseNum,
	t.DEANum
FROM src.BillProvider t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		BillProviderSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillProvider
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		BillProviderSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.BillProviderSeq = s.BillProviderSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillReevalReason', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillReevalReason;
GO

CREATE FUNCTION dbo.if_BillReevalReason(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.BillReevalReasonCode,
	t.SiteCode,
	t.BillReevalReasonCategorySeq,
	t.ShortDescription,
	t.LongDescription,
	t.Active,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.BillReevalReason t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillReevalReasonCode,
		SiteCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillReevalReason
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillReevalReasonCode,
		SiteCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillReevalReasonCode = s.BillReevalReasonCode
	AND t.SiteCode = s.SiteCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillRuleFire', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillRuleFire;
GO

CREATE FUNCTION dbo.if_BillRuleFire(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.BillSeq,
	t.LineSeq,
	t.RuleID,
	t.RuleType,
	t.DateRuleFired,
	t.Validated,
	t.ValidatedUserID,
	t.DateValidated,
	t.PendToID,
	t.RuleSeverity,
	t.WFTaskSeq,
	t.ChildTargetSubset,
	t.ChildTargetSeq
FROM src.BillRuleFire t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq,
		RuleID,
		ChildTargetSubset,
		ChildTargetSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillRuleFire
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq,
		RuleID,
		ChildTargetSubset,
		ChildTargetSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.LineSeq = s.LineSeq
	AND t.RuleID = s.RuleID
	AND t.ChildTargetSubset = s.ChildTargetSubset
	AND t.ChildTargetSeq = s.ChildTargetSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Branch', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Branch;
GO

CREATE FUNCTION dbo.if_Branch(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClaimSysSubSet,
	t.BranchSeq,
	t.Name,
	t.ExternalID,
	t.BranchID,
	t.LocationCode,
	t.AdminKey,
	t.Address1,
	t.Address2,
	t.City,
	t.State,
	t.Zip,
	t.PhoneNum,
	t.FaxNum,
	t.ContactName,
	t.TIN,
	t.StateTaxID,
	t.DIRNum,
	t.ModUserID,
	t.ModDate,
	t.RuleFire,
	t.FeeRateCntrlEx,
	t.FeeRateCntrlIn,
	t.SalesTaxExempt,
	t.EffectiveDate,
	t.TerminationDate
FROM src.Branch t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		BranchSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Branch
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		BranchSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.BranchSeq = s.BranchSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BRERuleCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BRERuleCategory;
GO

CREATE FUNCTION dbo.if_BRERuleCategory(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.BRERuleCategoryID,
	t.CategoryDescription
FROM src.BRERuleCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BRERuleCategoryID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BRERuleCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BRERuleCategoryID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BRERuleCategoryID = s.BRERuleCategoryID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CityStateZip', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CityStateZip;
GO

CREATE FUNCTION dbo.if_CityStateZip(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ZipCode,
	t.CtyStKey,
	t.CpyDtlCode,
	t.ZipClsCode,
	t.CtyStName,
	t.CtyStNameAbv,
	t.CtyStFacCode,
	t.CtyStMailInd,
	t.PreLstCtyKey,
	t.PreLstCtyNme,
	t.CtyDlvInd,
	t.AutZoneInd,
	t.UnqZipInd,
	t.FinanceNum,
	t.StateAbbrv,
	t.CountyNum,
	t.CountyName
FROM src.CityStateZip t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ZipCode,
		CtyStKey,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CityStateZip
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ZipCode,
		CtyStKey) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ZipCode = s.ZipCode
	AND t.CtyStKey = s.CtyStKey
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Claim', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Claim;
GO

CREATE FUNCTION dbo.if_Claim(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClaimSysSubSet,
	t.ClaimSeq,
	t.ClaimID,
	t.DOI,
	t.PatientSSN,
	t.PatientFirstName,
	t.PatientLastName,
	t.PatientMInitial,
	t.ExternalClaimID,
	t.PolicyCoPayAmount,
	t.PolicyCoPayPct,
	t.PolicyDeductible,
	t.Status,
	t.PolicyLimit,
	t.PolicyID,
	t.PolicyTimeLimit,
	t.Adjuster,
	t.PolicyLimitWarningPct,
	t.FirstDOS,
	t.LastDOS,
	t.LoadDate,
	t.ModDate,
	t.ModUserID,
	t.PatientSex,
	t.PatientCity,
	t.PatientDOB,
	t.PatientStreet2,
	t.PatientState,
	t.PatientZip,
	t.PatientStreet1,
	t.MMIDate,
	t.BodyPart1,
	t.BodyPart2,
	t.BodyPart3,
	t.BodyPart4,
	t.BodyPart5,
	t.Location,
	t.NatureInj,
	t.URFlag,
	t.CarKnowDate,
	t.ClaimType,
	t.CtrlDay,
	t.MCOChoice,
	t.ClientCodeDefault,
	t.CloseDate,
	t.ReopenDate,
	t.MedCloseDate,
	t.MedStipDate,
	t.LegalStatus1,
	t.LegalStatus2,
	t.LegalStatus3,
	t.Jurisdiction,
	t.ProductCode,
	t.PlaintiffAttorneySeq,
	t.DefendantAttorneySeq,
	t.BranchID,
	t.OccCode,
	t.ClaimSeverity,
	t.DateLostBegan,
	t.AccidentEmployment,
	t.RelationToInsured,
	t.Policy5Days,
	t.Policy90Days,
	t.Job5Days,
	t.Job90Days,
	t.LostDays,
	t.ActualRTWDate,
	t.MCOTransInd,
	t.QualifiedInjWorkInd,
	t.PermStationaryInd,
	t.HospitalAdmit,
	t.QualifiedInjWorkDate,
	t.RetToWorkDate,
	t.PermStationaryDate,
	t.MCOFein,
	t.CreateUserID,
	t.IDCode,
	t.IDType,
	t.MPNOptOutEffectiveDate,
	t.MPNOptOutTerminationDate,
	t.MPNOptOutPhysicianName,
	t.MPNOptOutPhysicianTIN,
	t.MPNChoice,
	t.JurisdictionClaimID,
	t.PolicyLimitResult,
	t.PatientPrimaryPhone,
	t.PatientWorkPhone,
	t.PatientAlternatePhone,
	t.ICDVersion,
	t.LastDateofTrauma,
	t.ClaimAdminClaimNum,
	t.PatientCountryCode
FROM src.Claim t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		ClaimSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Claim
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		ClaimSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.ClaimSeq = s.ClaimSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ClaimData', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ClaimData;
GO

CREATE FUNCTION dbo.if_ClaimData(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClaimSysSubset,
	t.ClaimSeq,
	t.TypeCode,
	t.SubType,
	t.SubSeq,
	t.NumData,
	t.TextData,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.ClaimData t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubset,
		ClaimSeq,
		TypeCode,
		SubType,
		SubSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimData
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubset,
		ClaimSeq,
		TypeCode,
		SubType,
		SubSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubset = s.ClaimSysSubset
	AND t.ClaimSeq = s.ClaimSeq
	AND t.TypeCode = s.TypeCode
	AND t.SubType = s.SubType
	AND t.SubSeq = s.SubSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ClaimDiag', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ClaimDiag;
GO

CREATE FUNCTION dbo.if_ClaimDiag(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClaimSysSubSet,
	t.ClaimSeq,
	t.ClaimDiagSeq,
	t.DiagCode
FROM src.ClaimDiag t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		ClaimSeq,
		ClaimDiagSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimDiag
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		ClaimSeq,
		ClaimDiagSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.ClaimSeq = s.ClaimSeq
	AND t.ClaimDiagSeq = s.ClaimDiagSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ClaimICDDiagnosis', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ClaimICDDiagnosis;
GO

CREATE FUNCTION dbo.if_ClaimICDDiagnosis(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClaimSysSubSet,
	t.ClaimSeq,
	t.ClaimDiagnosisSeq,
	t.ICDDiagnosisID
FROM src.ClaimICDDiagnosis t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		ClaimSeq,
		ClaimDiagnosisSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimICDDiagnosis
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		ClaimSeq,
		ClaimDiagnosisSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.ClaimSeq = s.ClaimSeq
	AND t.ClaimDiagnosisSeq = s.ClaimDiagnosisSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ClaimSys', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ClaimSys;
GO

CREATE FUNCTION dbo.if_ClaimSys(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClaimSysSubset,
	t.ClaimIDMask,
	t.ClaimAccess,
	t.ClaimSysDesc,
	t.PolicyholderReq,
	t.ValidateBranch,
	t.ValidatePolicy,
	t.LglCode1TableCode,
	t.LglCode2TableCode,
	t.LglCode3TableCode,
	t.UROccTableCode,
	t.Policy5DaysTableCode,
	t.Policy90DaysTableCode,
	t.Job5DaysTableCode,
	t.Job90DaysTableCode,
	t.HCOTransIndTableCode,
	t.QualifiedInjWorkTableCode,
	t.PermStationaryTableCode,
	t.ValidateAdjuster,
	t.MCOProgram,
	t.AdjusterRequired,
	t.HospitalAdmitTableCode,
	t.AttorneyTaxAddrRequired,
	t.BodyPartTableCode,
	t.PolicyDefaults,
	t.PolicyCoPayAmount,
	t.PolicyCoPayPct,
	t.PolicyDeductible,
	t.PolicyLimit,
	t.PolicyTimeLimit,
	t.PolicyLimitWarningPct,
	t.RestrictUserAccess,
	t.BEOverridePermissionFlag,
	t.RootClaimLength,
	t.RelateClaimsTotalPolicyDetail,
	t.PolicyLimitResult,
	t.EnableClaimClientCodeDefault,
	t.ReevalCopyDocCtrlID,
	t.EnableCEPHeaderFieldEdits,
	t.EnableSmartClientSelection,
	t.SCSClientSelectionCode,
	t.SCSProviderSubset,
	t.SCSClientCodeMask,
	t.SCSDefaultClient,
	t.ClaimExternalIDasCarrierClaimID,
	t.PolicyExternalIDasCarrierPolicyID,
	t.URProfileID,
	t.BEUROverridesRequireReviewRef,
	t.UREntryValidations,
	t.PendPPOEDIControl,
	t.BEReevalLineAddDelete,
	t.CPTGroupToIndividual,
	t.ClaimExternalIDasClaimAdminClaimNum,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.FinancialAggregation
FROM src.ClaimSys t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubset,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimSys
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubset) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubset = s.ClaimSysSubset
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ClaimSysData', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ClaimSysData;
GO

CREATE FUNCTION dbo.if_ClaimSysData(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClaimSysSubset,
	t.TypeCode,
	t.SubType,
	t.SubSeq,
	t.NumData,
	t.TextData
FROM src.ClaimSysData t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubset,
		TypeCode,
		SubType,
		SubSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimSysData
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubset,
		TypeCode,
		SubType,
		SubSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubset = s.ClaimSysSubset
	AND t.TypeCode = s.TypeCode
	AND t.SubType = s.SubType
	AND t.SubSeq = s.SubSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Client', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Client;
GO

CREATE FUNCTION dbo.if_Client(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.Name,
	t.Jurisdiction,
	t.ControlNum,
	t.PolicyTimeLimit,
	t.PolicyLimitWarningPct,
	t.PolicyLimit,
	t.PolicyDeductible,
	t.PolicyCoPayPct,
	t.PolicyCoPayAmount,
	t.BEDiagnosis,
	t.InvoiceBRCycle,
	t.Status,
	t.InvoiceGroupBy,
	t.BEDOI,
	t.DrugMarkUpBrand,
	t.SupplyLimit,
	t.InvoicePPOCycle,
	t.InvoicePPOTax,
	t.DrugMarkUpGen,
	t.DrugDispGen,
	t.DrugDispBrand,
	t.BEAdjuster,
	t.InvoiceTax,
	t.CompanySeq,
	t.BEMedAlert,
	t.UCRPercentile,
	t.ClientComment,
	t.RemitAttention,
	t.RemitAddress1,
	t.RemitAddress2,
	t.RemitCityStateZip,
	t.RemitPhone,
	t.ExternalID,
	t.BEOther,
	t.MedAlertDays,
	t.MedAlertVisits,
	t.MedAlertMaxCharge,
	t.MedAlertWarnVisits,
	t.ProviderSubSet,
	t.AllowReReview,
	t.AcctRep,
	t.ClientType,
	t.UCRMarkUp,
	t.InvoiceCombined,
	t.BESubmitDt,
	t.BERcvdCarrierDate,
	t.BERcvdBillReviewDate,
	t.BEDueDate,
	t.ProductCode,
	t.BEProvInvoice,
	t.ClaimSysSubSet,
	t.DefaultBRtoUCR,
	t.BasePPOFeesOffFS,
	t.BEClientTOBTableCode,
	t.BEForcePay,
	t.BEPayAuthorization,
	t.BECarrierSeqFlag,
	t.BEProvTypeTableCode,
	t.BEProvSpcl1TableCode,
	t.BEProvLicense,
	t.BEPayAuthTableCode,
	t.PendReasonTableCode,
	t.VocRehab,
	t.EDIAckRequired,
	t.StateRptInd,
	t.BEPatientAcctNum,
	t.AutoDup,
	t.UseAllowOnDup,
	t.URImportUsed,
	t.URProgStartDate,
	t.URImportCtrlNum,
	t.URImportCtrlGroup,
	t.UCRSource,
	t.UCRMarkup2,
	t.NGDTableCode,
	t.BESubProductTableCode,
	t.CountryTableCode,
	t.BERefPhys,
	t.BEPmtWarnDays,
	t.GeoState,
	t.BEDisableDOICheck,
	t.DelayDays,
	t.BEValidateTotal,
	t.BEFastMatch,
	t.BEPriorBillDefault,
	t.BEClientDueDays,
	t.BEAutoCalcDueDate,
	t.UCRSource2,
	t.UCRPercentile2,
	t.BEProvSpcl2TableCode,
	t.FeeRateCntrlEx,
	t.FeeRateCntrlIn,
	t.BECollisionProvBills,
	t.BECollisionBills,
	t.SupplyMarkup,
	t.BECollisionProviders,
	t.DefaultCoPayDeduct,
	t.AutoBundling,
	t.BEValidateBillClaimICD9,
	t.EnableGenericReprice,
	t.BESubProdFeeInfo,
	t.DenyNonInjDrugs,
	t.BECollisionDosLines,
	t.PPOProfileSiteCode,
	t.PPOProfileID,
	t.BEShowDEAWarning,
	t.BEHideAdjusterColumn,
	t.BEHideCoPayColumn,
	t.BEHideDeductColumn,
	t.BEPaidDate,
	t.BEProcCrossWalk,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.BEConsultDate,
	t.BEShowPharmacyColumns,
	t.BEAdjVerifDates,
	t.FutureDOSMonthLimit,
	t.BEStopAtLineUnits,
	t.BENYNF10Fields,
	t.EnableDRGGrouper,
	t.ApplyCptAmaUcrRules,
	t.BEProvSigOnFile,
	t.BETimeEntry,
	t.SalesTaxExempt,
	t.InvoiceRetailProfile,
	t.InvoiceWholesaleProfile,
	t.BEDefaultTaxZip,
	t.ReceiptHandlingCode,
	t.PaymentHandlingCode,
	t.DefaultRetailSalesTaxZip,
	t.DefaultWholesaleSalesTaxZip,
	t.TxNonSubscrib,
	t.RootClaimLength,
	t.BEDAWTableCode,
	t.EORProfileSeq,
	t.BEOtherBillingProvider,
	t.BEDocCtrlID,
	t.ReportingETL,
	t.ClaimVerification,
	t.ProvVerification,
	t.BEPermitAllowOver,
	t.BEStopAtLineDxRef,
	t.BEQuickInfoCode,
	t.ExcludedSmartClientSelect,
	t.CollisionsSearchBy,
	t.AutoDupIncludeProv,
	t.URProfileID,
	t.ExcludeURDM,
	t.BECollisionURCases,
	t.MUEEdits,
	t.CPTRarity,
	t.ICDRarity,
	t.ICDToCPTRarity,
	t.BEDisablePPOSearch,
	t.BEShowLineExternalIDColumn,
	t.BEShowLinePriorAuthColumn,
	t.SmartGuidelinesFlag,
	t.BEProvBillingLicense,
	t.BEProvFacilityLicense,
	t.VendorProviderSubSet,
	t.DefaultJurisClientCode,
	t.ClientGroupId
FROM src.Client t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Client
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ClientData', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ClientData;
GO

CREATE FUNCTION dbo.if_ClientData(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.TypeCode,
	t.SubType,
	t.SubSeq,
	t.NumData,
	t.TextData,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.ClientData t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		TypeCode,
		SubType,
		SubSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClientData
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		TypeCode,
		SubType,
		SubSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.TypeCode = s.TypeCode
	AND t.SubType = s.SubType
	AND t.SubSeq = s.SubSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ClientInsurer', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ClientInsurer;
GO

CREATE FUNCTION dbo.if_ClientInsurer(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.InsurerType,
	t.EffectiveDate,
	t.InsurerSeq,
	t.TerminationDate
FROM src.ClientInsurer t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		InsurerType,
		EffectiveDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClientInsurer
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		InsurerType,
		EffectiveDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.InsurerType = s.InsurerType
	AND t.EffectiveDate = s.EffectiveDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Drugs', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Drugs;
GO

CREATE FUNCTION dbo.if_Drugs(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.DrugCode,
	t.DrugsDescription,
	t.Disp,
	t.DrugType,
	t.Cat,
	t.UpdateFlag,
	t.Uv,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.Drugs t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DrugCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Drugs
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DrugCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DrugCode = s.DrugCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_EDIXmit', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_EDIXmit;
GO

CREATE FUNCTION dbo.if_EDIXmit(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.EDIXmitSeq,
	t.FileSpec,
	t.FileLocation,
	t.RecommendedPayment,
	t.UserID,
	t.XmitDate,
	t.DateFrom,
	t.DateTo,
	t.EDIType,
	t.EDIPartnerID,
	t.DBVersion,
	t.EDIMapToolSiteCode,
	t.EDIPortType,
	t.EDIMapToolID,
	t.TransmissionStatus,
	t.BatchNumber,
	t.SenderID,
	t.ReceiverID,
	t.ExternalBatchID,
	t.SARelatedBatchID,
	t.AckNoteCode,
	t.AckNote,
	t.ExternalBatchDate,
	t.UserNotes,
	t.ResubmitDate,
	t.ResubmitUserID,
	t.ModDate,
	t.ModUserID
FROM src.EDIXmit t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EDIXmitSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EDIXmit
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EDIXmitSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EDIXmitSeq = s.EDIXmitSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_EntityType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_EntityType;
GO

CREATE FUNCTION dbo.if_EntityType(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.EntityTypeID,
	t.EntityTypeKey,
	t.Description
FROM src.EntityType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EntityTypeID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EntityType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EntityTypeID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EntityTypeID = s.EntityTypeID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_FSProcedure', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_FSProcedure;
GO

CREATE FUNCTION dbo.if_FSProcedure(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.Jurisdiction,
	t.Extension,
	t.ProcedureCode,
	t.FSProcDescription,
	t.Sv,
	t.Star,
	t.Panel,
	t.Ip,
	t.Mult,
	t.AsstSurgeon,
	t.SectionFlag,
	t.Fup,
	t.Bav,
	t.ProcGroup,
	t.ViewType,
	t.UnitValue1,
	t.UnitValue2,
	t.UnitValue3,
	t.UnitValue4,
	t.UnitValue5,
	t.UnitValue6,
	t.UnitValue7,
	t.UnitValue8,
	t.UnitValue9,
	t.UnitValue10,
	t.UnitValue11,
	t.UnitValue12,
	t.ProUnitValue1,
	t.ProUnitValue2,
	t.ProUnitValue3,
	t.ProUnitValue4,
	t.ProUnitValue5,
	t.ProUnitValue6,
	t.ProUnitValue7,
	t.ProUnitValue8,
	t.ProUnitValue9,
	t.ProUnitValue10,
	t.ProUnitValue11,
	t.ProUnitValue12,
	t.TechUnitValue1,
	t.TechUnitValue2,
	t.TechUnitValue3,
	t.TechUnitValue4,
	t.TechUnitValue5,
	t.TechUnitValue6,
	t.TechUnitValue7,
	t.TechUnitValue8,
	t.TechUnitValue9,
	t.TechUnitValue10,
	t.TechUnitValue11,
	t.TechUnitValue12,
	t.SiteCode
FROM src.FSProcedure t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Jurisdiction,
		Extension,
		ProcedureCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.FSProcedure
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Jurisdiction,
		Extension,
		ProcedureCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Jurisdiction = s.Jurisdiction
	AND t.Extension = s.Extension
	AND t.ProcedureCode = s.ProcedureCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_FSProcedureMV', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_FSProcedureMV;
GO

CREATE FUNCTION dbo.if_FSProcedureMV(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.Jurisdiction,
	t.Extension,
	t.ProcedureCode,
	t.EffectiveDate,
	t.TerminationDate,
	t.FSProcDescription,
	t.Sv,
	t.Star,
	t.Panel,
	t.Ip,
	t.Mult,
	t.AsstSurgeon,
	t.SectionFlag,
	t.Fup,
	t.Bav,
	t.ProcGroup,
	t.ViewType,
	t.UnitValue,
	t.ProUnitValue,
	t.TechUnitValue,
	t.SiteCode
FROM src.FSProcedureMV t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Jurisdiction,
		Extension,
		ProcedureCode,
		EffectiveDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.FSProcedureMV
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Jurisdiction,
		Extension,
		ProcedureCode,
		EffectiveDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Jurisdiction = s.Jurisdiction
	AND t.Extension = s.Extension
	AND t.ProcedureCode = s.ProcedureCode
	AND t.EffectiveDate = s.EffectiveDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_FSServiceCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_FSServiceCode;
GO

CREATE FUNCTION dbo.if_FSServiceCode(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.Jurisdiction,
	t.ServiceCode,
	t.GeoAreaCode,
	t.EffectiveDate,
	t.Description,
	t.TermDate,
	t.CodeSource,
	t.CodeGroup
FROM src.FSServiceCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Jurisdiction,
		ServiceCode,
		GeoAreaCode,
		EffectiveDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.FSServiceCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Jurisdiction,
		ServiceCode,
		GeoAreaCode,
		EffectiveDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Jurisdiction = s.Jurisdiction
	AND t.ServiceCode = s.ServiceCode
	AND t.GeoAreaCode = s.GeoAreaCode
	AND t.EffectiveDate = s.EffectiveDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ICD_Diagnosis', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ICD_Diagnosis;
GO

CREATE FUNCTION dbo.if_ICD_Diagnosis(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ICDDiagnosisID,
	t.Code,
	t.ShortDesc,
	t.Description,
	t.Detailed
FROM src.ICD_Diagnosis t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ICDDiagnosisID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ICD_Diagnosis
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ICDDiagnosisID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ICDDiagnosisID = s.ICDDiagnosisID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Insurer', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Insurer;
GO

CREATE FUNCTION dbo.if_Insurer(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.InsurerType,
	t.InsurerSeq,
	t.Jurisdiction,
	t.StateID,
	t.TIN,
	t.AltID,
	t.Name,
	t.Address1,
	t.Address2,
	t.City,
	t.State,
	t.Zip,
	t.PhoneNum,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.FaxNum,
	t.NAICCoCode,
	t.NAICGpCode,
	t.NCCICarrierCode,
	t.NCCIGroupCode
FROM src.Insurer t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		InsurerType,
		InsurerSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Insurer
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		InsurerType,
		InsurerSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.InsurerType = s.InsurerType
	AND t.InsurerSeq = s.InsurerSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Jurisdiction', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Jurisdiction;
GO

CREATE FUNCTION dbo.if_Jurisdiction(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.JurisdictionID,
	t.Name,
	t.POSTableCode,
	t.TOSTableCode,
	t.TOBTableCode,
	t.ProvTypeTableCode,
	t.Hospital,
	t.ProvSpclTableCode,
	t.DaysToPay,
	t.DaysToPayQualify,
	t.OutPatientFS,
	t.ProcFileVer,
	t.AnestUnit,
	t.AnestRndUp,
	t.AnestFormat,
	t.StateMandateSSN,
	t.ICDEdition,
	t.ICD10ComplianceDate,
	t.eBillsDaysToPay,
	t.eBillsDaysToPayQualify,
	t.DisputeDaysToPay,
	t.DisputeDaysToPayQualify
FROM src.Jurisdiction t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		JurisdictionID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Jurisdiction
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		JurisdictionID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.JurisdictionID = s.JurisdictionID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Line', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Line;
GO

CREATE FUNCTION dbo.if_Line(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.BillSeq,
	t.LineSeq,
	t.DupClientCode,
	t.DupBillSeq,
	t.DOS,
	t.ProcType,
	t.PPOOverride,
	t.ClientLineType,
	t.ProvType,
	t.URQtyAllow,
	t.URQtySvd,
	t.DOSTo,
	t.URAllow,
	t.URCaseSeq,
	t.RevenueCode,
	t.ProcBilled,
	t.URReviewSeq,
	t.URPriority,
	t.ProcCode,
	t.Units,
	t.AllowUnits,
	t.Charge,
	t.BRAllow,
	t.PPOAllow,
	t.PayOverride,
	t.ProcNew,
	t.AdjAllow,
	t.ReevalAmount,
	t.POS,
	t.DxRefList,
	t.TOS,
	t.ReevalTxtPtr,
	t.FSAmount,
	t.UCAmount,
	t.CoPay,
	t.Deductible,
	t.CostToChargeRatio,
	t.RXNumber,
	t.DaysSupply,
	t.DxRef,
	t.ExternalID,
	t.ItemCostInvoiced,
	t.ItemCostAdditional,
	t.Refill,
	t.ProvSecondaryID,
	t.Certification,
	t.ReevalTxtSrc,
	t.BasisOfCost,
	t.DMEFrequencyCode,
	t.ProvRenderingNPI,
	t.ProvSecondaryIDQualifier,
	t.PaidProcCode,
	t.PaidProcType,
	t.URStatus,
	t.URWorkflowStatus,
	t.OverrideAllowUnits,
	t.LineSeqOrgRev,
	t.ODGFlag,
	t.CompoundDrugIndicator,
	t.PriorAuthNum,
	t.ReevalParagraphJurisdiction
FROM src.Line t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Line
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.LineSeq = s.LineSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_LineMod', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_LineMod;
GO

CREATE FUNCTION dbo.if_LineMod(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.BillSeq,
	t.LineSeq,
	t.ModSeq,
	t.UserEntered,
	t.ModSiteCode,
	t.Modifier,
	t.ReductionCode,
	t.ModSubset,
	t.ModUserID,
	t.ModDate,
	t.ReasonClientCode,
	t.ReasonBillSeq,
	t.ReasonLineSeq,
	t.ReasonType,
	t.ReasonValue
FROM src.LineMod t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq,
		ModSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.LineMod
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq,
		ModSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.LineSeq = s.LineSeq
	AND t.ModSeq = s.ModSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_LineReduction', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_LineReduction;
GO

CREATE FUNCTION dbo.if_LineReduction(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.BillSeq,
	t.LineSeq,
	t.ReductionCode,
	t.ReductionAmount,
	t.OverrideAmount,
	t.ModUserID
FROM src.LineReduction t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq,
		ReductionCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.LineReduction
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq,
		ReductionCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.LineSeq = s.LineSeq
	AND t.ReductionCode = s.ReductionCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_MedicareICQM', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_MedicareICQM;
GO

CREATE FUNCTION dbo.if_MedicareICQM(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.Jurisdiction,
	t.MdicqmSeq,
	t.ProviderNum,
	t.ProvSuffix,
	t.ServiceCode,
	t.HCPCS,
	t.Revenue,
	t.MedicareICQMDescription,
	t.IP1995,
	t.OP1995,
	t.IP1996,
	t.OP1996,
	t.IP1997,
	t.OP1997,
	t.IP1998,
	t.OP1998,
	t.NPI
FROM src.MedicareICQM t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Jurisdiction,
		MdicqmSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareICQM
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Jurisdiction,
		MdicqmSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Jurisdiction = s.Jurisdiction
	AND t.MdicqmSeq = s.MdicqmSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Modifier', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Modifier;
GO

CREATE FUNCTION dbo.if_Modifier(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.Jurisdiction,
	t.Code,
	t.SiteCode,
	t.Func,
	t.Val,
	t.ModType,
	t.GroupCode,
	t.ModDescription,
	t.ModComment1,
	t.ModComment2,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID,
	t.Statute,
	t.Remark1,
	t.RemarkQualifier1,
	t.Remark2,
	t.RemarkQualifier2,
	t.Remark3,
	t.RemarkQualifier3,
	t.Remark4,
	t.RemarkQualifier4,
	t.CBREReasonID
FROM src.Modifier t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Jurisdiction,
		Code,
		SiteCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Modifier
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Jurisdiction,
		Code,
		SiteCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Jurisdiction = s.Jurisdiction
	AND t.Code = s.Code
	AND t.SiteCode = s.SiteCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ODGData', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ODGData;
GO

CREATE FUNCTION dbo.if_ODGData(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ICDDiagnosisID,
	t.ProcedureCode,
	t.ICDDescription,
	t.ProcedureDescription,
	t.IncidenceRate,
	t.ProcedureFrequency,
	t.Visits25Perc,
	t.Visits50Perc,
	t.Visits75Perc,
	t.VisitsMean,
	t.CostsMean,
	t.AutoApprovalCode,
	t.PaymentFlag,
	t.CostPerVisit
FROM src.ODGData t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ICDDiagnosisID,
		ProcedureCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ODGData
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ICDDiagnosisID,
		ProcedureCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ICDDiagnosisID = s.ICDDiagnosisID
	AND t.ProcedureCode = s.ProcedureCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Pend', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Pend;
GO

CREATE FUNCTION dbo.if_Pend(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.BillSeq,
	t.PendSeq,
	t.PendDate,
	t.ReleaseFlag,
	t.PendToID,
	t.Priority,
	t.ReleaseDate,
	t.ReasonCode,
	t.PendByUserID,
	t.ReleaseByUserID,
	t.AutoPendFlag,
	t.RuleID,
	t.WFTaskSeq,
	t.ReleasedByExternalUserName
FROM src.Pend t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		PendSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Pend
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		PendSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.PendSeq = s.PendSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Policy', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Policy;
GO

CREATE FUNCTION dbo.if_Policy(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClaimSysSubSet,
	t.PolicySeq,
	t.Name,
	t.ExternalID,
	t.PolicyID,
	t.AdminKey,
	t.LocationCode,
	t.Address1,
	t.Address2,
	t.City,
	t.State,
	t.Zip,
	t.PhoneNum,
	t.FaxNum,
	t.EffectiveDate,
	t.TerminationDate,
	t.TIN,
	t.StateTaxID,
	t.DeptIndusRelNum,
	t.EqOppIndicator,
	t.ModUserID,
	t.ModDate,
	t.MCOFlag,
	t.MCOStartDate,
	t.FeeRateCtrlEx,
	t.CreateBy,
	t.FeeRateCtrlIn,
	t.CreateDate,
	t.SelfInsured,
	t.NAICSCode,
	t.MonthlyPremium,
	t.PPOProfileSiteCode,
	t.PPOProfileID,
	t.SalesTaxExempt,
	t.ReceiptHandlingCode,
	t.TxNonSubscrib,
	t.SubdivisionName,
	t.PolicyCoPayAmount,
	t.PolicyCoPayPct,
	t.PolicyDeductible,
	t.PolicyLimitAmount,
	t.PolicyTimeLimit,
	t.PolicyLimitWarningPct,
	t.PolicyLimitResult,
	t.URProfileID
FROM src.Policy t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		PolicySeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Policy
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		PolicySeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.PolicySeq = s.PolicySeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_PPOContract', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPOContract;
GO

CREATE FUNCTION dbo.if_PPOContract(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.PPONetworkID,
	t.PPOContractID,
	t.SiteCode,
	t.TIN,
	t.AlternateTIN,
	t.StartDate,
	t.EndDate,
	t.OPLineItemDefaultDiscount,
	t.CompanyName,
	t.First,
	t.GroupCode,
	t.GroupName,
	t.OPDiscountBaseValue,
	t.OPOffFS,
	t.OPOffUCR,
	t.OPOffCharge,
	t.OPEffectiveDate,
	t.OPAdditionalDiscountOffLink,
	t.OPTerminationDate,
	t.OPUCRPercentile,
	t.OPCondition,
	t.IPDiscountBaseValue,
	t.IPOffFS,
	t.IPOffUCR,
	t.IPOffCharge,
	t.IPEffectiveDate,
	t.IPTerminationDate,
	t.IPCondition,
	t.IPStopCapAmount,
	t.IPStopCapRate,
	t.MinDisc,
	t.MaxDisc,
	t.MedicalPerdiem,
	t.SurgicalPerdiem,
	t.ICUPerdiem,
	t.PsychiatricPerdiem,
	t.MiscParm,
	t.SpcCode,
	t.PPOType,
	t.BillingAddress1,
	t.BillingAddress2,
	t.BillingCity,
	t.BillingState,
	t.BillingZip,
	t.PracticeAddress1,
	t.PracticeAddress2,
	t.PracticeCity,
	t.PracticeState,
	t.PracticeZip,
	t.PhoneNum,
	t.OutFile,
	t.InpatFile,
	t.URCoordinatorFlag,
	t.ExclusivePPOOrgFlag,
	t.StopLossTypeCode,
	t.BR_RNEDiscount,
	t.ModDate,
	t.ExportFlag,
	t.OPManualIndicator,
	t.OPStopCapAmount,
	t.OPStopCapRate,
	t.Specialty1,
	t.Specialty2,
	t.LessorOfThreshold,
	t.BilateralDiscount,
	t.SurgeryDiscount2,
	t.SurgeryDiscount3,
	t.SurgeryDiscount4,
	t.SurgeryDiscount5,
	t.Matrix,
	t.ProvType,
	t.AllInclusive,
	t.Region,
	t.PaymentAddressFlag,
	t.MedicalGroup,
	t.MedicalGroupCode,
	t.RateMode,
	t.PracticeCounty,
	t.FIPSCountyCode,
	t.PrimaryCareFlag,
	t.PPOContractIDOld,
	t.MultiSurg,
	t.BiLevel,
	t.DRGRate,
	t.DRGGreaterThanBC,
	t.DRGMinPercentBC,
	t.CarveOut,
	t.PPOtoFSSeq,
	t.LicenseNum,
	t.MedicareNum,
	t.NPI
FROM src.PPOContract t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPONetworkID,
		PPOContractID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPOContract
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPONetworkID,
		PPOContractID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPONetworkID = s.PPONetworkID
	AND t.PPOContractID = s.PPOContractID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_PPONetwork', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPONetwork;
GO

CREATE FUNCTION dbo.if_PPONetwork(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.PPONetworkID,
	t.Name,
	t.TIN,
	t.Zip,
	t.State,
	t.City,
	t.Street,
	t.PhoneNum,
	t.PPONetworkComment,
	t.AllowMaint,
	t.ReqExtPPO,
	t.DemoRates,
	t.PrintAsProvider,
	t.PPOType,
	t.PPOVersion,
	t.PPOBridgeExists,
	t.UsesDrg,
	t.PPOToOther,
	t.SubNetworkIndicator,
	t.EmailAddress,
	t.WebSite,
	t.BillControlSeq
FROM src.PPONetwork t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPONetworkID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPONetwork
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPONetworkID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPONetworkID = s.PPONetworkID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_PPOProfile', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPOProfile;
GO

CREATE FUNCTION dbo.if_PPOProfile(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.SiteCode,
	t.PPOProfileID,
	t.ProfileDesc,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID,
	t.SmartSearchPageMax,
	t.JurisdictionStackExclusive,
	t.ReevalFullStackWhenOrigAllowNoHit
FROM src.PPOProfile t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SiteCode,
		PPOProfileID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPOProfile
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SiteCode,
		PPOProfileID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SiteCode = s.SiteCode
	AND t.PPOProfileID = s.PPOProfileID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_PPOProfileHistory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPOProfileHistory;
GO

CREATE FUNCTION dbo.if_PPOProfileHistory(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.PPOProfileHistorySeq,
	t.RecordDeleted,
	t.LogDateTime,
	t.loginame,
	t.SiteCode,
	t.PPOProfileID,
	t.ProfileDesc,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID,
	t.SmartSearchPageMax,
	t.JurisdictionStackExclusive,
	t.ReevalFullStackWhenOrigAllowNoHit
FROM src.PPOProfileHistory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPOProfileHistorySeq,
		SiteCode,
		PPOProfileID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPOProfileHistory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPOProfileHistorySeq,
		SiteCode,
		PPOProfileID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPOProfileHistorySeq = s.PPOProfileHistorySeq
	AND t.SiteCode = s.SiteCode
	AND t.PPOProfileID = s.PPOProfileID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_PPOProfileNetworks', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPOProfileNetworks;
GO

CREATE FUNCTION dbo.if_PPOProfileNetworks(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.PPOProfileSiteCode,
	t.PPOProfileID,
	t.ProfileRegionSiteCode,
	t.ProfileRegionID,
	t.NetworkOrder,
	t.PPONetworkID,
	t.SearchLogic,
	t.Verification,
	t.EffectiveDate,
	t.TerminationDate,
	t.JurisdictionInd,
	t.JurisdictionInsurerSeq,
	t.JurisdictionUseOnly,
	t.PPOSSTinReq,
	t.PPOSSLicReq,
	t.DefaultExtendedSearches,
	t.DefaultExtendedFilters,
	t.SeveredTies,
	t.POS
FROM src.PPOProfileNetworks t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPOProfileSiteCode,
		PPOProfileID,
		ProfileRegionSiteCode,
		ProfileRegionID,
		NetworkOrder,
		EffectiveDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPOProfileNetworks
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPOProfileSiteCode,
		PPOProfileID,
		ProfileRegionSiteCode,
		ProfileRegionID,
		NetworkOrder,
		EffectiveDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPOProfileSiteCode = s.PPOProfileSiteCode
	AND t.PPOProfileID = s.PPOProfileID
	AND t.ProfileRegionSiteCode = s.ProfileRegionSiteCode
	AND t.ProfileRegionID = s.ProfileRegionID
	AND t.NetworkOrder = s.NetworkOrder
	AND t.EffectiveDate = s.EffectiveDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_PPOProfileNetworksHistory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPOProfileNetworksHistory;
GO

CREATE FUNCTION dbo.if_PPOProfileNetworksHistory(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.PPOProfileNetworksHistorySeq,
	t.RecordDeleted,
	t.LogDateTime,
	t.loginame,
	t.PPOProfileSiteCode,
	t.PPOProfileID,
	t.ProfileRegionSiteCode,
	t.ProfileRegionID,
	t.NetworkOrder,
	t.PPONetworkID,
	t.SearchLogic,
	t.Verification,
	t.EffectiveDate,
	t.TerminationDate,
	t.JurisdictionInd,
	t.JurisdictionInsurerSeq,
	t.JurisdictionUseOnly,
	t.PPOSSTinReq,
	t.PPOSSLicReq,
	t.DefaultExtendedSearches,
	t.DefaultExtendedFilters,
	t.SeveredTies,
	t.POS
FROM src.PPOProfileNetworksHistory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPOProfileNetworksHistorySeq,
		PPOProfileSiteCode,
		PPOProfileID,
		ProfileRegionSiteCode,
		ProfileRegionID,
		NetworkOrder,
		EffectiveDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPOProfileNetworksHistory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPOProfileNetworksHistorySeq,
		PPOProfileSiteCode,
		PPOProfileID,
		ProfileRegionSiteCode,
		ProfileRegionID,
		NetworkOrder,
		EffectiveDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPOProfileNetworksHistorySeq = s.PPOProfileNetworksHistorySeq
	AND t.PPOProfileSiteCode = s.PPOProfileSiteCode
	AND t.PPOProfileID = s.PPOProfileID
	AND t.ProfileRegionSiteCode = s.ProfileRegionSiteCode
	AND t.ProfileRegionID = s.ProfileRegionID
	AND t.NetworkOrder = s.NetworkOrder
	AND t.EffectiveDate = s.EffectiveDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_PPORateType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPORateType;
GO

CREATE FUNCTION dbo.if_PPORateType(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.RateTypeCode,
	t.PPONetworkID,
	t.Category,
	t.Priority,
	t.VBColor,
	t.RateTypeDescription,
	t.Explanation
FROM src.PPORateType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RateTypeCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPORateType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RateTypeCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RateTypeCode = s.RateTypeCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_PPOSubNetwork', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPOSubNetwork;
GO

CREATE FUNCTION dbo.if_PPOSubNetwork(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.PPONetworkID,
	t.GroupCode,
	t.GroupName,
	t.ExternalID,
	t.SiteCode,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID,
	t.Street1,
	t.Street2,
	t.City,
	t.State,
	t.Zip,
	t.PhoneNum,
	t.EmailAddress,
	t.WebSite,
	t.TIN,
	t.Comment
FROM src.PPOSubNetwork t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPONetworkID,
		GroupCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPOSubNetwork
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPONetworkID,
		GroupCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPONetworkID = s.PPONetworkID
	AND t.GroupCode = s.GroupCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ProfileRegion', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProfileRegion;
GO

CREATE FUNCTION dbo.if_ProfileRegion(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.SiteCode,
	t.ProfileRegionID,
	t.RegionTypeCode,
	t.RegionName
FROM src.ProfileRegion t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SiteCode,
		ProfileRegionID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProfileRegion
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SiteCode,
		ProfileRegionID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SiteCode = s.SiteCode
	AND t.ProfileRegionID = s.ProfileRegionID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ProfileRegionDetail', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProfileRegionDetail;
GO

CREATE FUNCTION dbo.if_ProfileRegionDetail(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ProfileRegionSiteCode,
	t.ProfileRegionID,
	t.ZipCodeFrom,
	t.ZipCodeTo
FROM src.ProfileRegionDetail t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProfileRegionSiteCode,
		ProfileRegionID,
		ZipCodeFrom,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProfileRegionDetail
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProfileRegionSiteCode,
		ProfileRegionID,
		ZipCodeFrom) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProfileRegionSiteCode = s.ProfileRegionSiteCode
	AND t.ProfileRegionID = s.ProfileRegionID
	AND t.ZipCodeFrom = s.ZipCodeFrom
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Provider', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Provider;
GO

CREATE FUNCTION dbo.if_Provider(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ProviderSubSet,
	t.ProviderSeq,
	t.TIN,
	t.TINSuffix,
	t.ExternalID,
	t.Name,
	t.GroupCode,
	t.LicenseNum,
	t.MedicareNum,
	t.PracticeAddressSeq,
	t.BillingAddressSeq,
	t.HospitalSeq,
	t.ProvType,
	t.Specialty1,
	t.Specialty2,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.Status,
	t.ExternalStatus,
	t.ExportDate,
	t.SsnTinIndicator,
	t.PmtDays,
	t.AuthBeginDate,
	t.AuthEndDate,
	t.TaxAddressSeq,
	t.CtrlNum1099,
	t.SurchargeCode,
	t.WorkCompNum,
	t.WorkCompState,
	t.NCPDPID,
	t.EntityType,
	t.LastName,
	t.FirstName,
	t.MiddleName,
	t.Suffix,
	t.NPI,
	t.FacilityNPI,
	t.VerificationGroupID
FROM src.Provider t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderSubSet,
		ProviderSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Provider
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderSubSet,
		ProviderSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderSubSet = s.ProviderSubSet
	AND t.ProviderSeq = s.ProviderSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ProviderAddress', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderAddress;
GO

CREATE FUNCTION dbo.if_ProviderAddress(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ProviderSubSet,
	t.ProviderAddressSeq,
	t.RecType,
	t.Address1,
	t.Address2,
	t.City,
	t.State,
	t.Zip,
	t.PhoneNum,
	t.FaxNum,
	t.ContactFirstName,
	t.ContactLastName,
	t.ContactMiddleInitial,
	t.URFirstName,
	t.URLastName,
	t.URMiddleInitial,
	t.FacilityName,
	t.CountryCode,
	t.MailCode
FROM src.ProviderAddress t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderSubSet,
		ProviderAddressSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderAddress
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderSubSet,
		ProviderAddressSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderSubSet = s.ProviderSubSet
	AND t.ProviderAddressSeq = s.ProviderAddressSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ProviderCluster', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderCluster;
GO

CREATE FUNCTION dbo.if_ProviderCluster(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ProviderSubSet,
	t.ProviderSeq,
	t.OrgOdsCustomerId,
	t.MitchellProviderKey,
	t.ProviderClusterKey,
	t.ProviderType
FROM src.ProviderCluster t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderSubSet,
		ProviderSeq,
		OrgOdsCustomerId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderCluster
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderSubSet,
		ProviderSeq,
		OrgOdsCustomerId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderSubSet = s.ProviderSubSet
	AND t.ProviderSeq = s.ProviderSeq
	AND t.OrgOdsCustomerId = s.OrgOdsCustomerId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ProviderSpecialty', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderSpecialty;
GO

CREATE FUNCTION dbo.if_ProviderSpecialty(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.Id,
	t.Description,
	t.ImplementationDate,
	t.DeactivationDate,
	t.DataSource,
	t.Creator,
	t.CreateDate,
	t.LastUpdater,
	t.LastUpdateDate
FROM src.ProviderSpecialty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Id,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderSpecialty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Id) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Id = s.Id
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ProviderSys', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderSys;
GO

CREATE FUNCTION dbo.if_ProviderSys(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ProviderSubset,
	t.ProviderSubSetDesc,
	t.ProviderAccess,
	t.TaxAddrRequired,
	t.AllowDummyProviders,
	t.CascadeUpdatesOnImport,
	t.RootExtIDOverrideDelimiter
FROM src.ProviderSys t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderSubset,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderSys
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderSubset) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderSubset = s.ProviderSubset
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ReductionType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ReductionType;
GO

CREATE FUNCTION dbo.if_ReductionType(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ReductionCode,
	t.ReductionDescription,
	t.BEOverride,
	t.BEMsg,
	t.Abbreviation,
	t.DefaultMessageCode,
	t.DefaultDenialMessageCode
FROM src.ReductionType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReductionCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ReductionType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReductionCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReductionCode = s.ReductionCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Region', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Region;
GO

CREATE FUNCTION dbo.if_Region(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.Jurisdiction,
	t.Extension,
	t.EndZip,
	t.Beg,
	t.Region,
	t.RegionDescription
FROM src.Region t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Jurisdiction,
		Extension,
		EndZip,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Region
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Jurisdiction,
		Extension,
		EndZip) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Jurisdiction = s.Jurisdiction
	AND t.Extension = s.Extension
	AND t.EndZip = s.EndZip
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_TableLookUp', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_TableLookUp;
GO

CREATE FUNCTION dbo.if_TableLookUp(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.TableCode,
	t.TypeCode,
	t.Code,
	t.SiteCode,
	t.OldCode,
	t.ShortDesc,
	t.Source,
	t.Priority,
	t.LongDesc,
	t.OwnerApp,
	t.RecordStatus,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.TableLookUp t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TableCode,
		TypeCode,
		Code,
		SiteCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.TableLookUp
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TableCode,
		TypeCode,
		Code,
		SiteCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TableCode = s.TableCode
	AND t.TypeCode = s.TypeCode
	AND t.Code = s.Code
	AND t.SiteCode = s.SiteCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_UserInfo', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UserInfo;
GO

CREATE FUNCTION dbo.if_UserInfo(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.UserID,
	t.UserPassword,
	t.Name,
	t.SecurityLevel,
	t.EnableAdjusterMenu,
	t.EnableProvAdds,
	t.AllowPosting,
	t.EnableClaimAdds,
	t.EnablePolicyAdds,
	t.EnableInvoiceCreditVoid,
	t.EnableReevaluations,
	t.EnablePPOAccess,
	t.EnableURCommentView,
	t.EnablePendRelease,
	t.EnableXtableUpdate,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.EnablePPOFastMatchAdds,
	t.ExternalID,
	t.EmailAddress,
	t.EmailNotify,
	t.ActiveStatus,
	t.CompanySeq,
	t.NetworkLogin,
	t.AutomaticNetworkLogin,
	t.LastLoggedInDate,
	t.PromptToCreateMCC,
	t.AccessAllWorkQueues,
	t.LandingZoneAccess,
	t.ReviewLevel,
	t.EnableUserMaintenance,
	t.EnableHistoryMaintenance,
	t.EnableClientMaintenance,
	t.FeeAccess,
	t.EnableSalesTaxMaintenance,
	t.BESalesTaxZipCodeAccess,
	t.InvoiceGenAccess,
	t.BEPermitAllowOver,
	t.PermitRereviews,
	t.EditBillControl,
	t.RestrictEORNotes,
	t.UWQAutoNextBill,
	t.UWQDisableOptions,
	t.UWQDisableRules,
	t.PermitCheckReissue,
	t.EnableEDIAutomationMaintenance,
	t.RestrictDiaryNotes,
	t.RestrictExternalDiaryNotes,
	t.BEDeferManualModeMsg,
	t.UserRoleID,
	t.EraseBillTempHistory,
	t.EditPPOProfile,
	t.EnableUrAccess,
	t.CapstoneConfigurationAccess,
	t.PermitUDFDefinition,
	t.EnablePPOProfileEdit,
	t.EnableSupervisorRole
FROM src.UserInfo t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		UserID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UserInfo
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		UserID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.UserID = s.UserID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_WFlow', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_WFlow;
GO

CREATE FUNCTION dbo.if_WFlow(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.WFlowSeq,
	t.Description,
	t.RecordStatus,
	t.EntityTypeCode,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.InitialTaskSeq,
	t.PauseTaskSeq
FROM src.WFlow t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		WFlowSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.WFlow
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		WFlowSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.WFlowSeq = s.WFlowSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_WFQueue', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_WFQueue;
GO

CREATE FUNCTION dbo.if_WFQueue(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.EntityTypeCode,
	t.EntitySubset,
	t.EntitySeq,
	t.WFTaskSeq,
	t.PriorWFTaskSeq,
	t.Status,
	t.Priority,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.TaskMessage,
	t.Parameter1,
	t.ContextID,
	t.PriorStatus
FROM src.WFQueue t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EntityTypeCode,
		EntitySubset,
		EntitySeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.WFQueue
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EntityTypeCode,
		EntitySubset,
		EntitySeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EntityTypeCode = s.EntityTypeCode
	AND t.EntitySubset = s.EntitySubset
	AND t.EntitySeq = s.EntitySeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_WFTask', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_WFTask;
GO

CREATE FUNCTION dbo.if_WFTask(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.WFTaskSeq,
	t.WFLowSeq,
	t.WFTaskRegistrySeq,
	t.Name,
	t.Parameter1,
	t.RecordStatus,
	t.NodeLeft,
	t.NodeTop,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.NoPrior,
	t.NoRestart,
	t.ParameterX,
	t.DefaultPendGroup,
	t.Configuration
FROM src.WFTask t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		WFTaskSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.WFTask
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		WFTaskSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.WFTaskSeq = s.WFTaskSeq
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_WFTaskLink', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_WFTaskLink;
GO

CREATE FUNCTION dbo.if_WFTaskLink(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.FromTaskSeq,
	t.LinkWhen,
	t.ToTaskSeq
FROM src.WFTaskLink t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		FromTaskSeq,
		LinkWhen,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.WFTaskLink
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		FromTaskSeq,
		LinkWhen) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.FromTaskSeq = s.FromTaskSeq
	AND t.LinkWhen = s.LinkWhen
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_WFTaskRegistry', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_WFTaskRegistry;
GO

CREATE FUNCTION dbo.if_WFTaskRegistry(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.WFTaskRegistrySeq,
	t.EntityTypeCode,
	t.Description,
	t.Action,
	t.SmallImageResID,
	t.LargeImageResID,
	t.PersistBefore,
	t.NAction
FROM src.WFTaskRegistry t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		WFTaskRegistrySeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.WFTaskRegistry
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		WFTaskRegistrySeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.WFTaskRegistrySeq = s.WFTaskRegistrySeq
WHERE t.DmlOperation <> 'D';

GO


