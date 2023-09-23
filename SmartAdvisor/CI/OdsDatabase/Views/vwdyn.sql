IF OBJECT_ID('dbo.Adjuster', 'V') IS NOT NULL
    DROP VIEW dbo.Adjuster;
GO

CREATE VIEW dbo.Adjuster
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubSet
	,Adjuster
	,FirstName
	,LastName
	,MInitial
	,Title
	,Address1
	,Address2
	,City
	,State
	,Zip
	,PhoneNum
	,PhoneNumExt
	,FaxNum
	,Email
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
FROM src.Adjuster
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.AdjusterPendGroup', 'V') IS NOT NULL
    DROP VIEW dbo.AdjusterPendGroup;
GO

CREATE VIEW dbo.AdjusterPendGroup
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubset
	,Adjuster
	,PendGroupCode
FROM src.AdjusterPendGroup
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Attorney', 'V') IS NOT NULL
    DROP VIEW dbo.Attorney;
GO

CREATE VIEW dbo.Attorney
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubSet
	,AttorneySeq
	,TIN
	,TINSuffix
	,ExternalID
	,Name
	,GroupCode
	,LicenseNum
	,MedicareNum
	,PracticeAddressSeq
	,BillingAddressSeq
	,AttorneyType
	,Specialty1
	,Specialty2
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,Status
	,ExternalStatus
	,ExportDate
	,SsnTinIndicator
	,PmtDays
	,AuthBeginDate
	,AuthEndDate
	,TaxAddressSeq
	,CtrlNum1099
	,SurchargeCode
	,WorkCompNum
	,WorkCompState
FROM src.Attorney
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.AttorneyAddress', 'V') IS NOT NULL
    DROP VIEW dbo.AttorneyAddress;
GO

CREATE VIEW dbo.AttorneyAddress
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubSet
	,AttorneyAddressSeq
	,RecType
	,Address1
	,Address2
	,City
	,State
	,Zip
	,PhoneNum
	,FaxNum
	,ContactFirstName
	,ContactLastName
	,ContactMiddleInitial
	,URFirstName
	,URLastName
	,URMiddleInitial
	,FacilityName
	,CountryCode
	,MailCode
FROM src.AttorneyAddress
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Bill', 'V') IS NOT NULL
    DROP VIEW dbo.Bill;
GO

CREATE VIEW dbo.Bill
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,ClaimSeq
	,ClaimSysSubSet
	,ProviderSeq
	,ProviderSubSet
	,PostDate
	,DOSFirst
	,Invoiced
	,InvoicedPPO
	,CreateUserID
	,CarrierSeqNew
	,DocCtrlType
	,DOSLast
	,PPONetworkID
	,POS
	,ProvType
	,ProvSpecialty1
	,ProvZip
	,ProvState
	,SubmitDate
	,ProvInvoice
	,Region
	,HospitalSeq
	,ModUserID
	,Status
	,StatusPrior
	,BillableLines
	,TotalCharge
	,BRReduction
	,BRFee
	,TotalAllow
	,TotalFee
	,DupClientCode
	,DupBillSeq
	,FupStartDate
	,FupEndDate
	,SendBackMsg1SiteCode
	,SendBackMsg1
	,SendBackMsg2SiteCode
	,SendBackMsg2
	,PPOReduction
	,PPOPrc
	,PPOContractID
	,PPOStatus
	,PPOFee
	,NGDReduction
	,NGDFee
	,URFee
	,OtherData
	,ExternalStatus
	,URFlag
	,Visits
	,TOS
	,TOB
	,SubProductCode
	,ForcePay
	,PmtAuth
	,FlowStatus
	,ConsultDate
	,RcvdDate
	,AdmissionType
	,PaidDate
	,AdmitDate
	,DischargeDate
	,TxBillType
	,RcvdBrDate
	,DueDate
	,Adjuster
	,DOI
	,RetCtrlFlg
	,RetCtrlNum
	,SiteCode
	,SourceID
	,CaseType
	,SubProductID
	,SubProductPrice
	,URReduction
	,ProvLicenseNum
	,ProvMedicareNum
	,ProvSpecialty2
	,PmtExportDate
	,PmtAcceptDate
	,ClientTOB
	,BRFeeNet
	,PPOFeeNet
	,NGDFeeNet
	,URFeeNet
	,SubProductPriceNet
	,BillSeqNewRev
	,BillSeqOrgRev
	,VocPlanSeq
	,ReviewDate
	,AuditDate
	,ReevalAllow
	,CheckNum
	,NegoType
	,DischargeHour
	,UB92TOB
	,MCO
	,DRG
	,PatientAccount
	,ExaminerRevFlag
	,RefProvName
	,PaidAmount
	,AdmissionSource
	,AdmitHour
	,PatientStatus
	,DRGValue
	,CompanySeq
	,TotalCoPay
	,UB92ProcMethod
	,TotalDeductible
	,PolicyCoPayAmount
	,PolicyCoPayPct
	,DocCtrlID
	,ResourceUtilGroup
	,PolicyDeductible
	,PolicyLimit
	,PolicyTimeLimit
	,PolicyWarningPct
	,AppBenefits
	,AppAssignee
	,CreateDate
	,ModDate
	,IncrementValue
	,AdjVerifRequestDate
	,AdjVerifRcvdDate
	,RenderingProvLastName
	,RenderingProvFirstName
	,RenderingProvMiddleName
	,RenderingProvSuffix
	,RereviewCount
	,DRGBilled
	,DRGCalculated
	,ProvRxLicenseNum
	,ProvSigOnFile
	,RefProvFirstName
	,RefProvMiddleName
	,RefProvSuffix
	,RefProvDEANum
	,SendbackMsg1Subset
	,SendbackMsg2Subset
	,PPONetworkJurisdictionInd
	,ManualReductionMode
	,WholesaleSalesTaxZip
	,RetailSalesTaxZip
	,PPONetworkJurisdictionInsurerSeq
	,InvoicedWholesale
	,InvoicedPPOWholesale
	,AdmittingDxRef
	,AdmittingDxCode
	,ProvFacilityNPI
	,ProvBillingNPI
	,ProvRenderingNPI
	,ProvOperatingNPI
	,ProvReferringNPI
	,ProvOther1NPI
	,ProvOther2NPI
	,ProvOperatingLicenseNum
	,EHubID
	,OtherBillingProviderSubset
	,OtherBillingProviderSeq
	,ResubmissionReasonCode
	,ContractType
	,ContractAmount
	,PriorAuthReferralNum1
	,PriorAuthReferralNum2
	,DRGCompositeFactor
	,DRGDischargeFraction
	,DRGInpatientMultiplier
	,DRGWeight
	,EFTPmtMethodCode
	,EFTPmtFormatCode
	,EFTSenderDFIID
	,EFTSenderAcctNum
	,EFTOrigCoSupplCode
	,EFTReceiverDFIID
	,EFTReceiverAcctQual
	,EFTReceiverAcctNum
	,PolicyLimitResult
	,HistoryBatchNumber
	,ProvBillingTaxonomy
	,ProvFacilityTaxonomy
	,ProvRenderingTaxonomy
	,PPOStackList
	,ICDVersion
	,ODGFlag
	,ProvBillLicenseNum
	,ProvFacilityLicenseNum
	,ProvVendorExternalID
	,BRActualClientCode
	,BROverrideClientCode
	,BillReevalReasonCode
	,PaymentClearedDate
	,EstimatedBRClientCode
	,EstimatedBRJuris
	,OverrideFeeControlRetail
	,OverrideFeeControlWholesale
FROM src.Bill
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillControl', 'V') IS NOT NULL
    DROP VIEW dbo.BillControl;
GO

CREATE VIEW dbo.BillControl
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,BillControlSeq
	,ModDate
	,CreateDate
	,Control
	,ExternalID
	,BatchNumber
	,ModUserID
	,ExternalID2
	,Message
FROM src.BillControl
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillControlHistory', 'V') IS NOT NULL
    DROP VIEW dbo.BillControlHistory;
GO

CREATE VIEW dbo.BillControlHistory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillControlHistorySeq
	,ClientCode
	,BillSeq
	,BillControlSeq
	,CreateDate
	,Control
	,ExternalID
	,EDIBatchLogSeq
	,Deleted
	,ModUserID
	,ExternalID2
	,Message
FROM src.BillControlHistory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillData', 'V') IS NOT NULL
    DROP VIEW dbo.BillData;
GO

CREATE VIEW dbo.BillData
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,TypeCode
	,SubType
	,SubSeq
	,NumData
	,TextData
	,ModDate
	,ModUserID
	,CreateDate
	,CreateUserID
FROM src.BillData
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillFee', 'V') IS NOT NULL
    DROP VIEW dbo.BillFee;
GO

CREATE VIEW dbo.BillFee
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,FeeType
	,TransactionType
	,FeeCtrlSource
	,FeeControlSeq
	,FeeAmount
	,InvoiceSeq
	,InvoiceSubSeq
	,PPONetworkID
	,ReductionCode
	,FeeOverride
	,OverrideVerified
	,ExclusiveFee
	,FeeSourceID
	,HandlingFee
FROM src.BillFee
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillICD', 'V') IS NOT NULL
    DROP VIEW dbo.BillICD;
GO

CREATE VIEW dbo.BillICD
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,BillICDSeq
	,CodeType
	,ICDCode
	,CodeDate
	,POA
FROM src.BillICD
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillICDDiagnosis', 'V') IS NOT NULL
    DROP VIEW dbo.BillICDDiagnosis;
GO

CREATE VIEW dbo.BillICDDiagnosis
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,BillDiagnosisSeq
	,ICDDiagnosisID
	,POA
	,BilledICDDiagnosis
	,ICDBillUsageTypeID
FROM src.BillICDDiagnosis
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillICDProcedure', 'V') IS NOT NULL
    DROP VIEW dbo.BillICDProcedure;
GO

CREATE VIEW dbo.BillICDProcedure
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,BillProcedureSeq
	,ICDProcedureID
	,CodeDate
	,BilledICDProcedure
	,ICDBillUsageTypeID
FROM src.BillICDProcedure
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillPPORate', 'V') IS NOT NULL
    DROP VIEW dbo.BillPPORate;
GO

CREATE VIEW dbo.BillPPORate
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,LinkName
	,RateType
	,Applied
FROM src.BillPPORate
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillProvider', 'V') IS NOT NULL
    DROP VIEW dbo.BillProvider;
GO

CREATE VIEW dbo.BillProvider
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,BillProviderSeq
	,Qualifier
	,LastName
	,FirstName
	,MiddleName
	,Suffix
	,NPI
	,LicenseNum
	,DEANum
FROM src.BillProvider
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillReevalReason', 'V') IS NOT NULL
    DROP VIEW dbo.BillReevalReason;
GO

CREATE VIEW dbo.BillReevalReason
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillReevalReasonCode
	,SiteCode
	,BillReevalReasonCategorySeq
	,ShortDescription
	,LongDescription
	,Active
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
FROM src.BillReevalReason
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillRuleFire', 'V') IS NOT NULL
    DROP VIEW dbo.BillRuleFire;
GO

CREATE VIEW dbo.BillRuleFire
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,LineSeq
	,RuleID
	,RuleType
	,DateRuleFired
	,Validated
	,ValidatedUserID
	,DateValidated
	,PendToID
	,RuleSeverity
	,WFTaskSeq
	,ChildTargetSubset
	,ChildTargetSeq
FROM src.BillRuleFire
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Branch', 'V') IS NOT NULL
    DROP VIEW dbo.Branch;
GO

CREATE VIEW dbo.Branch
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubSet
	,BranchSeq
	,Name
	,ExternalID
	,BranchID
	,LocationCode
	,AdminKey
	,Address1
	,Address2
	,City
	,State
	,Zip
	,PhoneNum
	,FaxNum
	,ContactName
	,TIN
	,StateTaxID
	,DIRNum
	,ModUserID
	,ModDate
	,RuleFire
	,FeeRateCntrlEx
	,FeeRateCntrlIn
	,SalesTaxExempt
	,EffectiveDate
	,TerminationDate
FROM src.Branch
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BRERuleCategory', 'V') IS NOT NULL
    DROP VIEW dbo.BRERuleCategory;
GO

CREATE VIEW dbo.BRERuleCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BRERuleCategoryID
	,CategoryDescription
FROM src.BRERuleCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.CityStateZip', 'V') IS NOT NULL
    DROP VIEW dbo.CityStateZip;
GO

CREATE VIEW dbo.CityStateZip
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ZipCode
	,CtyStKey
	,CpyDtlCode
	,ZipClsCode
	,CtyStName
	,CtyStNameAbv
	,CtyStFacCode
	,CtyStMailInd
	,PreLstCtyKey
	,PreLstCtyNme
	,CtyDlvInd
	,AutZoneInd
	,UnqZipInd
	,FinanceNum
	,StateAbbrv
	,CountyNum
	,CountyName
FROM src.CityStateZip
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Claim', 'V') IS NOT NULL
    DROP VIEW dbo.Claim;
GO

CREATE VIEW dbo.Claim
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubSet
	,ClaimSeq
	,ClaimID
	,DOI
	,PatientSSN
	,PatientFirstName
	,PatientLastName
	,PatientMInitial
	,ExternalClaimID
	,PolicyCoPayAmount
	,PolicyCoPayPct
	,PolicyDeductible
	,Status
	,PolicyLimit
	,PolicyID
	,PolicyTimeLimit
	,Adjuster
	,PolicyLimitWarningPct
	,FirstDOS
	,LastDOS
	,LoadDate
	,ModDate
	,ModUserID
	,PatientSex
	,PatientCity
	,PatientDOB
	,PatientStreet2
	,PatientState
	,PatientZip
	,PatientStreet1
	,MMIDate
	,BodyPart1
	,BodyPart2
	,BodyPart3
	,BodyPart4
	,BodyPart5
	,Location
	,NatureInj
	,URFlag
	,CarKnowDate
	,ClaimType
	,CtrlDay
	,MCOChoice
	,ClientCodeDefault
	,CloseDate
	,ReopenDate
	,MedCloseDate
	,MedStipDate
	,LegalStatus1
	,LegalStatus2
	,LegalStatus3
	,Jurisdiction
	,ProductCode
	,PlaintiffAttorneySeq
	,DefendantAttorneySeq
	,BranchID
	,OccCode
	,ClaimSeverity
	,DateLostBegan
	,AccidentEmployment
	,RelationToInsured
	,Policy5Days
	,Policy90Days
	,Job5Days
	,Job90Days
	,LostDays
	,ActualRTWDate
	,MCOTransInd
	,QualifiedInjWorkInd
	,PermStationaryInd
	,HospitalAdmit
	,QualifiedInjWorkDate
	,RetToWorkDate
	,PermStationaryDate
	,MCOFein
	,CreateUserID
	,IDCode
	,IDType
	,MPNOptOutEffectiveDate
	,MPNOptOutTerminationDate
	,MPNOptOutPhysicianName
	,MPNOptOutPhysicianTIN
	,MPNChoice
	,JurisdictionClaimID
	,PolicyLimitResult
	,PatientPrimaryPhone
	,PatientWorkPhone
	,PatientAlternatePhone
	,ICDVersion
	,LastDateofTrauma
	,ClaimAdminClaimNum
	,PatientCountryCode
FROM src.Claim
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ClaimData', 'V') IS NOT NULL
    DROP VIEW dbo.ClaimData;
GO

CREATE VIEW dbo.ClaimData
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubset
	,ClaimSeq
	,TypeCode
	,SubType
	,SubSeq
	,NumData
	,TextData
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
FROM src.ClaimData
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ClaimDiag', 'V') IS NOT NULL
    DROP VIEW dbo.ClaimDiag;
GO

CREATE VIEW dbo.ClaimDiag
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubSet
	,ClaimSeq
	,ClaimDiagSeq
	,DiagCode
FROM src.ClaimDiag
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ClaimICDDiagnosis', 'V') IS NOT NULL
    DROP VIEW dbo.ClaimICDDiagnosis;
GO

CREATE VIEW dbo.ClaimICDDiagnosis
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubSet
	,ClaimSeq
	,ClaimDiagnosisSeq
	,ICDDiagnosisID
FROM src.ClaimICDDiagnosis
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ClaimSys', 'V') IS NOT NULL
    DROP VIEW dbo.ClaimSys;
GO

CREATE VIEW dbo.ClaimSys
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubset
	,ClaimIDMask
	,ClaimAccess
	,ClaimSysDesc
	,PolicyholderReq
	,ValidateBranch
	,ValidatePolicy
	,LglCode1TableCode
	,LglCode2TableCode
	,LglCode3TableCode
	,UROccTableCode
	,Policy5DaysTableCode
	,Policy90DaysTableCode
	,Job5DaysTableCode
	,Job90DaysTableCode
	,HCOTransIndTableCode
	,QualifiedInjWorkTableCode
	,PermStationaryTableCode
	,ValidateAdjuster
	,MCOProgram
	,AdjusterRequired
	,HospitalAdmitTableCode
	,AttorneyTaxAddrRequired
	,BodyPartTableCode
	,PolicyDefaults
	,PolicyCoPayAmount
	,PolicyCoPayPct
	,PolicyDeductible
	,PolicyLimit
	,PolicyTimeLimit
	,PolicyLimitWarningPct
	,RestrictUserAccess
	,BEOverridePermissionFlag
	,RootClaimLength
	,RelateClaimsTotalPolicyDetail
	,PolicyLimitResult
	,EnableClaimClientCodeDefault
	,ReevalCopyDocCtrlID
	,EnableCEPHeaderFieldEdits
	,EnableSmartClientSelection
	,SCSClientSelectionCode
	,SCSProviderSubset
	,SCSClientCodeMask
	,SCSDefaultClient
	,ClaimExternalIDasCarrierClaimID
	,PolicyExternalIDasCarrierPolicyID
	,URProfileID
	,BEUROverridesRequireReviewRef
	,UREntryValidations
	,PendPPOEDIControl
	,BEReevalLineAddDelete
	,CPTGroupToIndividual
	,ClaimExternalIDasClaimAdminClaimNum
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,FinancialAggregation
FROM src.ClaimSys
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ClaimSysData', 'V') IS NOT NULL
    DROP VIEW dbo.ClaimSysData;
GO

CREATE VIEW dbo.ClaimSysData
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubset
	,TypeCode
	,SubType
	,SubSeq
	,NumData
	,TextData
FROM src.ClaimSysData
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Client', 'V') IS NOT NULL
    DROP VIEW dbo.Client;
GO

CREATE VIEW dbo.Client
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,Name
	,Jurisdiction
	,ControlNum
	,PolicyTimeLimit
	,PolicyLimitWarningPct
	,PolicyLimit
	,PolicyDeductible
	,PolicyCoPayPct
	,PolicyCoPayAmount
	,BEDiagnosis
	,InvoiceBRCycle
	,Status
	,InvoiceGroupBy
	,BEDOI
	,DrugMarkUpBrand
	,SupplyLimit
	,InvoicePPOCycle
	,InvoicePPOTax
	,DrugMarkUpGen
	,DrugDispGen
	,DrugDispBrand
	,BEAdjuster
	,InvoiceTax
	,CompanySeq
	,BEMedAlert
	,UCRPercentile
	,ClientComment
	,RemitAttention
	,RemitAddress1
	,RemitAddress2
	,RemitCityStateZip
	,RemitPhone
	,ExternalID
	,BEOther
	,MedAlertDays
	,MedAlertVisits
	,MedAlertMaxCharge
	,MedAlertWarnVisits
	,ProviderSubSet
	,AllowReReview
	,AcctRep
	,ClientType
	,UCRMarkUp
	,InvoiceCombined
	,BESubmitDt
	,BERcvdCarrierDate
	,BERcvdBillReviewDate
	,BEDueDate
	,ProductCode
	,BEProvInvoice
	,ClaimSysSubSet
	,DefaultBRtoUCR
	,BasePPOFeesOffFS
	,BEClientTOBTableCode
	,BEForcePay
	,BEPayAuthorization
	,BECarrierSeqFlag
	,BEProvTypeTableCode
	,BEProvSpcl1TableCode
	,BEProvLicense
	,BEPayAuthTableCode
	,PendReasonTableCode
	,VocRehab
	,EDIAckRequired
	,StateRptInd
	,BEPatientAcctNum
	,AutoDup
	,UseAllowOnDup
	,URImportUsed
	,URProgStartDate
	,URImportCtrlNum
	,URImportCtrlGroup
	,UCRSource
	,UCRMarkup2
	,NGDTableCode
	,BESubProductTableCode
	,CountryTableCode
	,BERefPhys
	,BEPmtWarnDays
	,GeoState
	,BEDisableDOICheck
	,DelayDays
	,BEValidateTotal
	,BEFastMatch
	,BEPriorBillDefault
	,BEClientDueDays
	,BEAutoCalcDueDate
	,UCRSource2
	,UCRPercentile2
	,BEProvSpcl2TableCode
	,FeeRateCntrlEx
	,FeeRateCntrlIn
	,BECollisionProvBills
	,BECollisionBills
	,SupplyMarkup
	,BECollisionProviders
	,DefaultCoPayDeduct
	,AutoBundling
	,BEValidateBillClaimICD9
	,EnableGenericReprice
	,BESubProdFeeInfo
	,DenyNonInjDrugs
	,BECollisionDosLines
	,PPOProfileSiteCode
	,PPOProfileID
	,BEShowDEAWarning
	,BEHideAdjusterColumn
	,BEHideCoPayColumn
	,BEHideDeductColumn
	,BEPaidDate
	,BEProcCrossWalk
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,BEConsultDate
	,BEShowPharmacyColumns
	,BEAdjVerifDates
	,FutureDOSMonthLimit
	,BEStopAtLineUnits
	,BENYNF10Fields
	,EnableDRGGrouper
	,ApplyCptAmaUcrRules
	,BEProvSigOnFile
	,BETimeEntry
	,SalesTaxExempt
	,InvoiceRetailProfile
	,InvoiceWholesaleProfile
	,BEDefaultTaxZip
	,ReceiptHandlingCode
	,PaymentHandlingCode
	,DefaultRetailSalesTaxZip
	,DefaultWholesaleSalesTaxZip
	,TxNonSubscrib
	,RootClaimLength
	,BEDAWTableCode
	,EORProfileSeq
	,BEOtherBillingProvider
	,BEDocCtrlID
	,ReportingETL
	,ClaimVerification
	,ProvVerification
	,BEPermitAllowOver
	,BEStopAtLineDxRef
	,BEQuickInfoCode
	,ExcludedSmartClientSelect
	,CollisionsSearchBy
	,AutoDupIncludeProv
	,URProfileID
	,ExcludeURDM
	,BECollisionURCases
	,MUEEdits
	,CPTRarity
	,ICDRarity
	,ICDToCPTRarity
	,BEDisablePPOSearch
	,BEShowLineExternalIDColumn
	,BEShowLinePriorAuthColumn
	,SmartGuidelinesFlag
	,BEProvBillingLicense
	,BEProvFacilityLicense
	,VendorProviderSubSet
	,DefaultJurisClientCode
	,ClientGroupId
FROM src.Client
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ClientData', 'V') IS NOT NULL
    DROP VIEW dbo.ClientData;
GO

CREATE VIEW dbo.ClientData
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,TypeCode
	,SubType
	,SubSeq
	,NumData
	,TextData
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
FROM src.ClientData
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ClientInsurer', 'V') IS NOT NULL
    DROP VIEW dbo.ClientInsurer;
GO

CREATE VIEW dbo.ClientInsurer
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,InsurerType
	,EffectiveDate
	,InsurerSeq
	,TerminationDate
FROM src.ClientInsurer
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Drugs', 'V') IS NOT NULL
    DROP VIEW dbo.Drugs;
GO

CREATE VIEW dbo.Drugs
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DrugCode
	,DrugsDescription
	,Disp
	,DrugType
	,Cat
	,UpdateFlag
	,Uv
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
FROM src.Drugs
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.EDIXmit', 'V') IS NOT NULL
    DROP VIEW dbo.EDIXmit;
GO

CREATE VIEW dbo.EDIXmit
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EDIXmitSeq
	,FileSpec
	,FileLocation
	,RecommendedPayment
	,UserID
	,XmitDate
	,DateFrom
	,DateTo
	,EDIType
	,EDIPartnerID
	,DBVersion
	,EDIMapToolSiteCode
	,EDIPortType
	,EDIMapToolID
	,TransmissionStatus
	,BatchNumber
	,SenderID
	,ReceiverID
	,ExternalBatchID
	,SARelatedBatchID
	,AckNoteCode
	,AckNote
	,ExternalBatchDate
	,UserNotes
	,ResubmitDate
	,ResubmitUserID
	,ModDate
	,ModUserID
FROM src.EDIXmit
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.EntityType', 'V') IS NOT NULL
    DROP VIEW dbo.EntityType;
GO

CREATE VIEW dbo.EntityType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EntityTypeID
	,EntityTypeKey
	,Description
FROM src.EntityType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.FSProcedure', 'V') IS NOT NULL
    DROP VIEW dbo.FSProcedure;
GO

CREATE VIEW dbo.FSProcedure
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Jurisdiction
	,Extension
	,ProcedureCode
	,FSProcDescription
	,Sv
	,Star
	,Panel
	,Ip
	,Mult
	,AsstSurgeon
	,SectionFlag
	,Fup
	,Bav
	,ProcGroup
	,ViewType
	,UnitValue1
	,UnitValue2
	,UnitValue3
	,UnitValue4
	,UnitValue5
	,UnitValue6
	,UnitValue7
	,UnitValue8
	,UnitValue9
	,UnitValue10
	,UnitValue11
	,UnitValue12
	,ProUnitValue1
	,ProUnitValue2
	,ProUnitValue3
	,ProUnitValue4
	,ProUnitValue5
	,ProUnitValue6
	,ProUnitValue7
	,ProUnitValue8
	,ProUnitValue9
	,ProUnitValue10
	,ProUnitValue11
	,ProUnitValue12
	,TechUnitValue1
	,TechUnitValue2
	,TechUnitValue3
	,TechUnitValue4
	,TechUnitValue5
	,TechUnitValue6
	,TechUnitValue7
	,TechUnitValue8
	,TechUnitValue9
	,TechUnitValue10
	,TechUnitValue11
	,TechUnitValue12
	,SiteCode
FROM src.FSProcedure
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.FSProcedureMV', 'V') IS NOT NULL
    DROP VIEW dbo.FSProcedureMV;
GO

CREATE VIEW dbo.FSProcedureMV
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Jurisdiction
	,Extension
	,ProcedureCode
	,EffectiveDate
	,TerminationDate
	,FSProcDescription
	,Sv
	,Star
	,Panel
	,Ip
	,Mult
	,AsstSurgeon
	,SectionFlag
	,Fup
	,Bav
	,ProcGroup
	,ViewType
	,UnitValue
	,ProUnitValue
	,TechUnitValue
	,SiteCode
FROM src.FSProcedureMV
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.FSServiceCode', 'V') IS NOT NULL
    DROP VIEW dbo.FSServiceCode;
GO

CREATE VIEW dbo.FSServiceCode
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Jurisdiction
	,ServiceCode
	,GeoAreaCode
	,EffectiveDate
	,Description
	,TermDate
	,CodeSource
	,CodeGroup
FROM src.FSServiceCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ICD_Diagnosis', 'V') IS NOT NULL
    DROP VIEW dbo.ICD_Diagnosis;
GO

CREATE VIEW dbo.ICD_Diagnosis
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ICDDiagnosisID
	,Code
	,ShortDesc
	,Description
	,Detailed
FROM src.ICD_Diagnosis
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Insurer', 'V') IS NOT NULL
    DROP VIEW dbo.Insurer;
GO

CREATE VIEW dbo.Insurer
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,InsurerType
	,InsurerSeq
	,Jurisdiction
	,StateID
	,TIN
	,AltID
	,Name
	,Address1
	,Address2
	,City
	,State
	,Zip
	,PhoneNum
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,FaxNum
	,NAICCoCode
	,NAICGpCode
	,NCCICarrierCode
	,NCCIGroupCode
FROM src.Insurer
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Jurisdiction', 'V') IS NOT NULL
    DROP VIEW dbo.Jurisdiction;
GO

CREATE VIEW dbo.Jurisdiction
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,JurisdictionID
	,Name
	,POSTableCode
	,TOSTableCode
	,TOBTableCode
	,ProvTypeTableCode
	,Hospital
	,ProvSpclTableCode
	,DaysToPay
	,DaysToPayQualify
	,OutPatientFS
	,ProcFileVer
	,AnestUnit
	,AnestRndUp
	,AnestFormat
	,StateMandateSSN
	,ICDEdition
	,ICD10ComplianceDate
	,eBillsDaysToPay
	,eBillsDaysToPayQualify
	,DisputeDaysToPay
	,DisputeDaysToPayQualify
FROM src.Jurisdiction
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Line', 'V') IS NOT NULL
    DROP VIEW dbo.Line;
GO

CREATE VIEW dbo.Line
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,LineSeq
	,DupClientCode
	,DupBillSeq
	,DOS
	,ProcType
	,PPOOverride
	,ClientLineType
	,ProvType
	,URQtyAllow
	,URQtySvd
	,DOSTo
	,URAllow
	,URCaseSeq
	,RevenueCode
	,ProcBilled
	,URReviewSeq
	,URPriority
	,ProcCode
	,Units
	,AllowUnits
	,Charge
	,BRAllow
	,PPOAllow
	,PayOverride
	,ProcNew
	,AdjAllow
	,ReevalAmount
	,POS
	,DxRefList
	,TOS
	,ReevalTxtPtr
	,FSAmount
	,UCAmount
	,CoPay
	,Deductible
	,CostToChargeRatio
	,RXNumber
	,DaysSupply
	,DxRef
	,ExternalID
	,ItemCostInvoiced
	,ItemCostAdditional
	,Refill
	,ProvSecondaryID
	,Certification
	,ReevalTxtSrc
	,BasisOfCost
	,DMEFrequencyCode
	,ProvRenderingNPI
	,ProvSecondaryIDQualifier
	,PaidProcCode
	,PaidProcType
	,URStatus
	,URWorkflowStatus
	,OverrideAllowUnits
	,LineSeqOrgRev
	,ODGFlag
	,CompoundDrugIndicator
	,PriorAuthNum
	,ReevalParagraphJurisdiction
FROM src.Line
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.LineMod', 'V') IS NOT NULL
    DROP VIEW dbo.LineMod;
GO

CREATE VIEW dbo.LineMod
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,LineSeq
	,ModSeq
	,UserEntered
	,ModSiteCode
	,Modifier
	,ReductionCode
	,ModSubset
	,ModUserID
	,ModDate
	,ReasonClientCode
	,ReasonBillSeq
	,ReasonLineSeq
	,ReasonType
	,ReasonValue
FROM src.LineMod
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.LineReduction', 'V') IS NOT NULL
    DROP VIEW dbo.LineReduction;
GO

CREATE VIEW dbo.LineReduction
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,LineSeq
	,ReductionCode
	,ReductionAmount
	,OverrideAmount
	,ModUserID
FROM src.LineReduction
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.MedicareICQM', 'V') IS NOT NULL
    DROP VIEW dbo.MedicareICQM;
GO

CREATE VIEW dbo.MedicareICQM
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Jurisdiction
	,MdicqmSeq
	,ProviderNum
	,ProvSuffix
	,ServiceCode
	,HCPCS
	,Revenue
	,MedicareICQMDescription
	,IP1995
	,OP1995
	,IP1996
	,OP1996
	,IP1997
	,OP1997
	,IP1998
	,OP1998
	,NPI
FROM src.MedicareICQM
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Modifier', 'V') IS NOT NULL
    DROP VIEW dbo.Modifier;
GO

CREATE VIEW dbo.Modifier
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Jurisdiction
	,Code
	,SiteCode
	,Func
	,Val
	,ModType
	,GroupCode
	,ModDescription
	,ModComment1
	,ModComment2
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
	,Statute
	,Remark1
	,RemarkQualifier1
	,Remark2
	,RemarkQualifier2
	,Remark3
	,RemarkQualifier3
	,Remark4
	,RemarkQualifier4
	,CBREReasonID
FROM src.Modifier
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ODGData', 'V') IS NOT NULL
    DROP VIEW dbo.ODGData;
GO

CREATE VIEW dbo.ODGData
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ICDDiagnosisID
	,ProcedureCode
	,ICDDescription
	,ProcedureDescription
	,IncidenceRate
	,ProcedureFrequency
	,Visits25Perc
	,Visits50Perc
	,Visits75Perc
	,VisitsMean
	,CostsMean
	,AutoApprovalCode
	,PaymentFlag
	,CostPerVisit
FROM src.ODGData
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Pend', 'V') IS NOT NULL
    DROP VIEW dbo.Pend;
GO

CREATE VIEW dbo.Pend
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,PendSeq
	,PendDate
	,ReleaseFlag
	,PendToID
	,Priority
	,ReleaseDate
	,ReasonCode
	,PendByUserID
	,ReleaseByUserID
	,AutoPendFlag
	,RuleID
	,WFTaskSeq
	,ReleasedByExternalUserName
FROM src.Pend
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Policy', 'V') IS NOT NULL
    DROP VIEW dbo.Policy;
GO

CREATE VIEW dbo.Policy
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubSet
	,PolicySeq
	,Name
	,ExternalID
	,PolicyID
	,AdminKey
	,LocationCode
	,Address1
	,Address2
	,City
	,State
	,Zip
	,PhoneNum
	,FaxNum
	,EffectiveDate
	,TerminationDate
	,TIN
	,StateTaxID
	,DeptIndusRelNum
	,EqOppIndicator
	,ModUserID
	,ModDate
	,MCOFlag
	,MCOStartDate
	,FeeRateCtrlEx
	,CreateBy
	,FeeRateCtrlIn
	,CreateDate
	,SelfInsured
	,NAICSCode
	,MonthlyPremium
	,PPOProfileSiteCode
	,PPOProfileID
	,SalesTaxExempt
	,ReceiptHandlingCode
	,TxNonSubscrib
	,SubdivisionName
	,PolicyCoPayAmount
	,PolicyCoPayPct
	,PolicyDeductible
	,PolicyLimitAmount
	,PolicyTimeLimit
	,PolicyLimitWarningPct
	,PolicyLimitResult
	,URProfileID
FROM src.Policy
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.PPOContract', 'V') IS NOT NULL
    DROP VIEW dbo.PPOContract;
GO

CREATE VIEW dbo.PPOContract
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PPONetworkID
	,PPOContractID
	,SiteCode
	,TIN
	,AlternateTIN
	,StartDate
	,EndDate
	,OPLineItemDefaultDiscount
	,CompanyName
	,First
	,GroupCode
	,GroupName
	,OPDiscountBaseValue
	,OPOffFS
	,OPOffUCR
	,OPOffCharge
	,OPEffectiveDate
	,OPAdditionalDiscountOffLink
	,OPTerminationDate
	,OPUCRPercentile
	,OPCondition
	,IPDiscountBaseValue
	,IPOffFS
	,IPOffUCR
	,IPOffCharge
	,IPEffectiveDate
	,IPTerminationDate
	,IPCondition
	,IPStopCapAmount
	,IPStopCapRate
	,MinDisc
	,MaxDisc
	,MedicalPerdiem
	,SurgicalPerdiem
	,ICUPerdiem
	,PsychiatricPerdiem
	,MiscParm
	,SpcCode
	,PPOType
	,BillingAddress1
	,BillingAddress2
	,BillingCity
	,BillingState
	,BillingZip
	,PracticeAddress1
	,PracticeAddress2
	,PracticeCity
	,PracticeState
	,PracticeZip
	,PhoneNum
	,OutFile
	,InpatFile
	,URCoordinatorFlag
	,ExclusivePPOOrgFlag
	,StopLossTypeCode
	,BR_RNEDiscount
	,ModDate
	,ExportFlag
	,OPManualIndicator
	,OPStopCapAmount
	,OPStopCapRate
	,Specialty1
	,Specialty2
	,LessorOfThreshold
	,BilateralDiscount
	,SurgeryDiscount2
	,SurgeryDiscount3
	,SurgeryDiscount4
	,SurgeryDiscount5
	,Matrix
	,ProvType
	,AllInclusive
	,Region
	,PaymentAddressFlag
	,MedicalGroup
	,MedicalGroupCode
	,RateMode
	,PracticeCounty
	,FIPSCountyCode
	,PrimaryCareFlag
	,PPOContractIDOld
	,MultiSurg
	,BiLevel
	,DRGRate
	,DRGGreaterThanBC
	,DRGMinPercentBC
	,CarveOut
	,PPOtoFSSeq
	,LicenseNum
	,MedicareNum
	,NPI
FROM src.PPOContract
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.PPONetwork', 'V') IS NOT NULL
    DROP VIEW dbo.PPONetwork;
GO

CREATE VIEW dbo.PPONetwork
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PPONetworkID
	,Name
	,TIN
	,Zip
	,State
	,City
	,Street
	,PhoneNum
	,PPONetworkComment
	,AllowMaint
	,ReqExtPPO
	,DemoRates
	,PrintAsProvider
	,PPOType
	,PPOVersion
	,PPOBridgeExists
	,UsesDrg
	,PPOToOther
	,SubNetworkIndicator
	,EmailAddress
	,WebSite
	,BillControlSeq
FROM src.PPONetwork
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.PPOProfile', 'V') IS NOT NULL
    DROP VIEW dbo.PPOProfile;
GO

CREATE VIEW dbo.PPOProfile
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SiteCode
	,PPOProfileID
	,ProfileDesc
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
	,SmartSearchPageMax
	,JurisdictionStackExclusive
	,ReevalFullStackWhenOrigAllowNoHit
FROM src.PPOProfile
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.PPOProfileHistory', 'V') IS NOT NULL
    DROP VIEW dbo.PPOProfileHistory;
GO

CREATE VIEW dbo.PPOProfileHistory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PPOProfileHistorySeq
	,RecordDeleted
	,LogDateTime
	,loginame
	,SiteCode
	,PPOProfileID
	,ProfileDesc
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
	,SmartSearchPageMax
	,JurisdictionStackExclusive
	,ReevalFullStackWhenOrigAllowNoHit
FROM src.PPOProfileHistory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.PPOProfileNetworks', 'V') IS NOT NULL
    DROP VIEW dbo.PPOProfileNetworks;
GO

CREATE VIEW dbo.PPOProfileNetworks
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PPOProfileSiteCode
	,PPOProfileID
	,ProfileRegionSiteCode
	,ProfileRegionID
	,NetworkOrder
	,PPONetworkID
	,SearchLogic
	,Verification
	,EffectiveDate
	,TerminationDate
	,JurisdictionInd
	,JurisdictionInsurerSeq
	,JurisdictionUseOnly
	,PPOSSTinReq
	,PPOSSLicReq
	,DefaultExtendedSearches
	,DefaultExtendedFilters
	,SeveredTies
	,POS
FROM src.PPOProfileNetworks
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.PPOProfileNetworksHistory', 'V') IS NOT NULL
    DROP VIEW dbo.PPOProfileNetworksHistory;
GO

CREATE VIEW dbo.PPOProfileNetworksHistory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PPOProfileNetworksHistorySeq
	,RecordDeleted
	,LogDateTime
	,loginame
	,PPOProfileSiteCode
	,PPOProfileID
	,ProfileRegionSiteCode
	,ProfileRegionID
	,NetworkOrder
	,PPONetworkID
	,SearchLogic
	,Verification
	,EffectiveDate
	,TerminationDate
	,JurisdictionInd
	,JurisdictionInsurerSeq
	,JurisdictionUseOnly
	,PPOSSTinReq
	,PPOSSLicReq
	,DefaultExtendedSearches
	,DefaultExtendedFilters
	,SeveredTies
	,POS
FROM src.PPOProfileNetworksHistory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.PPORateType', 'V') IS NOT NULL
    DROP VIEW dbo.PPORateType;
GO

CREATE VIEW dbo.PPORateType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RateTypeCode
	,PPONetworkID
	,Category
	,Priority
	,VBColor
	,RateTypeDescription
	,Explanation
FROM src.PPORateType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.PPOSubNetwork', 'V') IS NOT NULL
    DROP VIEW dbo.PPOSubNetwork;
GO

CREATE VIEW dbo.PPOSubNetwork
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PPONetworkID
	,GroupCode
	,GroupName
	,ExternalID
	,SiteCode
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
	,Street1
	,Street2
	,City
	,State
	,Zip
	,PhoneNum
	,EmailAddress
	,WebSite
	,TIN
	,Comment
FROM src.PPOSubNetwork
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ProfileRegion', 'V') IS NOT NULL
    DROP VIEW dbo.ProfileRegion;
GO

CREATE VIEW dbo.ProfileRegion
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SiteCode
	,ProfileRegionID
	,RegionTypeCode
	,RegionName
FROM src.ProfileRegion
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ProfileRegionDetail', 'V') IS NOT NULL
    DROP VIEW dbo.ProfileRegionDetail;
GO

CREATE VIEW dbo.ProfileRegionDetail
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProfileRegionSiteCode
	,ProfileRegionID
	,ZipCodeFrom
	,ZipCodeTo
FROM src.ProfileRegionDetail
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Provider', 'V') IS NOT NULL
    DROP VIEW dbo.Provider;
GO

CREATE VIEW dbo.Provider
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderSubSet
	,ProviderSeq
	,TIN
	,TINSuffix
	,ExternalID
	,Name
	,GroupCode
	,LicenseNum
	,MedicareNum
	,PracticeAddressSeq
	,BillingAddressSeq
	,HospitalSeq
	,ProvType
	,Specialty1
	,Specialty2
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,Status
	,ExternalStatus
	,ExportDate
	,SsnTinIndicator
	,PmtDays
	,AuthBeginDate
	,AuthEndDate
	,TaxAddressSeq
	,CtrlNum1099
	,SurchargeCode
	,WorkCompNum
	,WorkCompState
	,NCPDPID
	,EntityType
	,LastName
	,FirstName
	,MiddleName
	,Suffix
	,NPI
	,FacilityNPI
	,VerificationGroupID
FROM src.Provider
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ProviderAddress', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderAddress;
GO

CREATE VIEW dbo.ProviderAddress
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderSubSet
	,ProviderAddressSeq
	,RecType
	,Address1
	,Address2
	,City
	,State
	,Zip
	,PhoneNum
	,FaxNum
	,ContactFirstName
	,ContactLastName
	,ContactMiddleInitial
	,URFirstName
	,URLastName
	,URMiddleInitial
	,FacilityName
	,CountryCode
	,MailCode
FROM src.ProviderAddress
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ProviderCluster', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderCluster;
GO

CREATE VIEW dbo.ProviderCluster
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderSubSet
	,ProviderSeq
	,OrgOdsCustomerId
	,MitchellProviderKey
	,ProviderClusterKey
	,ProviderType
FROM src.ProviderCluster
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ProviderSpecialty', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderSpecialty;
GO

CREATE VIEW dbo.ProviderSpecialty
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Id
	,Description
	,ImplementationDate
	,DeactivationDate
	,DataSource
	,Creator
	,CreateDate
	,LastUpdater
	,LastUpdateDate
FROM src.ProviderSpecialty
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ProviderSys', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderSys;
GO

CREATE VIEW dbo.ProviderSys
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderSubset
	,ProviderSubSetDesc
	,ProviderAccess
	,TaxAddrRequired
	,AllowDummyProviders
	,CascadeUpdatesOnImport
	,RootExtIDOverrideDelimiter
FROM src.ProviderSys
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ReductionType', 'V') IS NOT NULL
    DROP VIEW dbo.ReductionType;
GO

CREATE VIEW dbo.ReductionType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReductionCode
	,ReductionDescription
	,BEOverride
	,BEMsg
	,Abbreviation
	,DefaultMessageCode
	,DefaultDenialMessageCode
FROM src.ReductionType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Region', 'V') IS NOT NULL
    DROP VIEW dbo.Region;
GO

CREATE VIEW dbo.Region
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Jurisdiction
	,Extension
	,EndZip
	,Beg
	,Region
	,RegionDescription
FROM src.Region
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.TableLookUp', 'V') IS NOT NULL
    DROP VIEW dbo.TableLookUp;
GO

CREATE VIEW dbo.TableLookUp
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,TableCode
	,TypeCode
	,Code
	,SiteCode
	,OldCode
	,ShortDesc
	,Source
	,Priority
	,LongDesc
	,OwnerApp
	,RecordStatus
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
FROM src.TableLookUp
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.UserInfo', 'V') IS NOT NULL
    DROP VIEW dbo.UserInfo;
GO

CREATE VIEW dbo.UserInfo
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,UserID
	,UserPassword
	,Name
	,SecurityLevel
	,EnableAdjusterMenu
	,EnableProvAdds
	,AllowPosting
	,EnableClaimAdds
	,EnablePolicyAdds
	,EnableInvoiceCreditVoid
	,EnableReevaluations
	,EnablePPOAccess
	,EnableURCommentView
	,EnablePendRelease
	,EnableXtableUpdate
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,EnablePPOFastMatchAdds
	,ExternalID
	,EmailAddress
	,EmailNotify
	,ActiveStatus
	,CompanySeq
	,NetworkLogin
	,AutomaticNetworkLogin
	,LastLoggedInDate
	,PromptToCreateMCC
	,AccessAllWorkQueues
	,LandingZoneAccess
	,ReviewLevel
	,EnableUserMaintenance
	,EnableHistoryMaintenance
	,EnableClientMaintenance
	,FeeAccess
	,EnableSalesTaxMaintenance
	,BESalesTaxZipCodeAccess
	,InvoiceGenAccess
	,BEPermitAllowOver
	,PermitRereviews
	,EditBillControl
	,RestrictEORNotes
	,UWQAutoNextBill
	,UWQDisableOptions
	,UWQDisableRules
	,PermitCheckReissue
	,EnableEDIAutomationMaintenance
	,RestrictDiaryNotes
	,RestrictExternalDiaryNotes
	,BEDeferManualModeMsg
	,UserRoleID
	,EraseBillTempHistory
	,EditPPOProfile
	,EnableUrAccess
	,CapstoneConfigurationAccess
	,PermitUDFDefinition
	,EnablePPOProfileEdit
	,EnableSupervisorRole
FROM src.UserInfo
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.WFlow', 'V') IS NOT NULL
    DROP VIEW dbo.WFlow;
GO

CREATE VIEW dbo.WFlow
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,WFlowSeq
	,Description
	,RecordStatus
	,EntityTypeCode
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,InitialTaskSeq
	,PauseTaskSeq
FROM src.WFlow
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.WFQueue', 'V') IS NOT NULL
    DROP VIEW dbo.WFQueue;
GO

CREATE VIEW dbo.WFQueue
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EntityTypeCode
	,EntitySubset
	,EntitySeq
	,WFTaskSeq
	,PriorWFTaskSeq
	,Status
	,Priority
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,TaskMessage
	,Parameter1
	,ContextID
	,PriorStatus
FROM src.WFQueue
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.WFTask', 'V') IS NOT NULL
    DROP VIEW dbo.WFTask;
GO

CREATE VIEW dbo.WFTask
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,WFTaskSeq
	,WFLowSeq
	,WFTaskRegistrySeq
	,Name
	,Parameter1
	,RecordStatus
	,NodeLeft
	,NodeTop
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,NoPrior
	,NoRestart
	,ParameterX
	,DefaultPendGroup
	,Configuration
FROM src.WFTask
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.WFTaskLink', 'V') IS NOT NULL
    DROP VIEW dbo.WFTaskLink;
GO

CREATE VIEW dbo.WFTaskLink
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,FromTaskSeq
	,LinkWhen
	,ToTaskSeq
FROM src.WFTaskLink
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.WFTaskRegistry', 'V') IS NOT NULL
    DROP VIEW dbo.WFTaskRegistry;
GO

CREATE VIEW dbo.WFTaskRegistry
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,WFTaskRegistrySeq
	,EntityTypeCode
	,Description
	,Action
	,SmallImageResID
	,LargeImageResID
	,PersistBefore
	,NAction
FROM src.WFTaskRegistry
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


