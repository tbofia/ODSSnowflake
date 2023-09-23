CREATE OR REPLACE TABLE stg.Bill( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ClientCode VARCHAR (4) NULL
	 , BillSeq NUMBER (10,0) NULL
	 , ClaimSeq NUMBER (10,0) NULL
	 , ClaimSysSubSet VARCHAR (4) NULL
	 , ProviderSeq NUMBER (19,0) NULL
	 , ProviderSubSet VARCHAR (4) NULL
	 , PostDate DATETIME NULL
	 , DOSFirst DATETIME NULL
	 , Invoiced VARCHAR (1) NULL
	 , InvoicedPPO VARCHAR (1) NULL
	 , CreateUserID VARCHAR (2) NULL
	 , CarrierSeqNew VARCHAR (30) NULL
	 , DocCtrlType VARCHAR (2) NULL
	 , DOSLast DATETIME NULL
	 , PPONetworkID VARCHAR (2) NULL
	 , POS VARCHAR (2) NULL
	 , ProvType VARCHAR (3) NULL
	 , ProvSpecialty1 VARCHAR (8) NULL
	 , ProvZip VARCHAR (9) NULL
	 , ProvState VARCHAR (2) NULL
	 , SubmitDate DATETIME NULL
	 , ProvInvoice VARCHAR (14) NULL
	 , Region NUMBER (5,0) NULL
	 , HospitalSeq NUMBER (10,0) NULL
	 , ModUserID VARCHAR (2) NULL
	 , Status NUMBER (5,0) NULL
	 , StatusPrior NUMBER (5,0) NULL
	 , BillableLines NUMBER (5,0) NULL
	 , TotalCharge NUMBER (19,4) NULL
	 , BRReduction NUMBER (19,4) NULL
	 , BRFee NUMBER (19,4) NULL
	 , TotalAllow NUMBER (19,4) NULL
	 , TotalFee NUMBER (19,4) NULL
	 , DupClientCode VARCHAR (4) NULL
	 , DupBillSeq NUMBER (10,0) NULL
	 , FupStartDate DATETIME NULL
	 , FupEndDate DATETIME NULL
	 , SendBackMsg1SiteCode VARCHAR (3) NULL
	 , SendBackMsg1 VARCHAR (6) NULL
	 , SendBackMsg2SiteCode VARCHAR (3) NULL
	 , SendBackMsg2 VARCHAR (6) NULL
	 , PPOReduction NUMBER (19,4) NULL
	 , PPOPrc NUMBER (5,0) NULL
	 , PPOContractID VARCHAR (30) NULL
	 , PPOStatus VARCHAR (1) NULL
	 , PPOFee NUMBER (19,4) NULL
	 , NGDReduction NUMBER (19,4) NULL
	 , NGDFee NUMBER (19,4) NULL
	 , URFee NUMBER (19,4) NULL
	 , OtherData VARCHAR (30) NULL
	 , ExternalStatus VARCHAR (1) NULL
	 , URFlag VARCHAR (1) NULL
	 , Visits NUMBER (5,0) NULL
	 , TOS VARCHAR (2) NULL
	 , TOB VARCHAR (1) NULL
	 , SubProductCode VARCHAR (1) NULL
	 , ForcePay VARCHAR (1) NULL
	 , PmtAuth VARCHAR (4) NULL
	 , FlowStatus VARCHAR (1) NULL
	 , ConsultDate DATETIME NULL
	 , RcvdDate DATETIME NULL
	 , AdmissionType VARCHAR (1) NULL
	 , PaidDate DATETIME NULL
	 , AdmitDate DATETIME NULL
	 , DischargeDate DATETIME NULL
	 , TxBillType VARCHAR (1) NULL
	 , RcvdBrDate DATETIME NULL
	 , DueDate DATETIME NULL
	 , Adjuster VARCHAR (25) NULL
	 , DOI DATETIME NULL
	 , RetCtrlFlg VARCHAR (1) NULL
	 , RetCtrlNum VARCHAR (9) NULL
	 , SiteCode VARCHAR (3) NULL
	 , SourceID VARCHAR (2) NULL
	 , CaseType VARCHAR (1) NULL
	 , SubProductID VARCHAR (30) NULL
	 , SubProductPrice NUMBER (19,4) NULL
	 , URReduction NUMBER (19,4) NULL
	 , ProvLicenseNum VARCHAR (30) NULL
	 , ProvMedicareNum VARCHAR (20) NULL
	 , ProvSpecialty2 VARCHAR (8) NULL
	 , PmtExportDate DATETIME NULL
	 , PmtAcceptDate DATETIME NULL
	 , ClientTOB VARCHAR (5) NULL
	 , BRFeeNet NUMBER (19,4) NULL
	 , PPOFeeNet NUMBER (19,4) NULL
	 , NGDFeeNet NUMBER (19,4) NULL
	 , URFeeNet NUMBER (19,4) NULL
	 , SubProductPriceNet NUMBER (19,4) NULL
	 , BillSeqNewRev NUMBER (10,0) NULL
	 , BillSeqOrgRev NUMBER (10,0) NULL
	 , VocPlanSeq NUMBER (5,0) NULL
	 , ReviewDate DATETIME NULL
	 , AuditDate DATETIME NULL
	 , ReevalAllow NUMBER (19,4) NULL
	 , CheckNum VARCHAR (30) NULL
	 , NegoType VARCHAR (2) NULL
	 , DischargeHour VARCHAR (2) NULL
	 , UB92TOB VARCHAR (3) NULL
	 , MCO VARCHAR (10) NULL
	 , DRG VARCHAR (3) NULL
	 , PatientAccount VARCHAR (20) NULL
	 , ExaminerRevFlag VARCHAR (1) NULL
	 , RefProvName VARCHAR (40) NULL
	 , PaidAmount NUMBER (19,4) NULL
	 , AdmissionSource VARCHAR (1) NULL
	 , AdmitHour VARCHAR (2) NULL
	 , PatientStatus VARCHAR (2) NULL
	 , DRGValue NUMBER (19,4) NULL
	 , CompanySeq NUMBER (5,0) NULL
	 , TotalCoPay NUMBER (19,4) NULL
	 , UB92ProcMethod VARCHAR (1) NULL
	 , TotalDeductible NUMBER (19,4) NULL
	 , PolicyCoPayAmount NUMBER (19,4) NULL
	 , PolicyCoPayPct NUMBER (5,0) NULL
	 , DocCtrlID VARCHAR (50) NULL
	 , ResourceUtilGroup VARCHAR (4) NULL
	 , PolicyDeductible NUMBER (19,4) NULL
	 , PolicyLimit NUMBER (19,4) NULL
	 , PolicyTimeLimit NUMBER (5,0) NULL
	 , PolicyWarningPct NUMBER (5,0) NULL
	 , AppBenefits VARCHAR (1) NULL
	 , AppAssignee VARCHAR (1) NULL
	 , CreateDate DATETIME NULL
	 , ModDate DATETIME NULL
	 , IncrementValue NUMBER (5,0) NULL
	 , AdjVerifRequestDate DATETIME NULL
	 , AdjVerifRcvdDate DATETIME NULL
	 , RenderingProvLastName VARCHAR (35) NULL
	 , RenderingProvFirstName VARCHAR (25) NULL
	 , RenderingProvMiddleName VARCHAR (25) NULL
	 , RenderingProvSuffix VARCHAR (10) NULL
	 , RereviewCount NUMBER (5,0) NULL
	 , DRGBilled VARCHAR (3) NULL
	 , DRGCalculated VARCHAR (3) NULL
	 , ProvRxLicenseNum VARCHAR (30) NULL
	 , ProvSigOnFile VARCHAR (1) NULL
	 , RefProvFirstName VARCHAR (30) NULL
	 , RefProvMiddleName VARCHAR (25) NULL
	 , RefProvSuffix VARCHAR (10) NULL
	 , RefProvDEANum VARCHAR (9) NULL
	 , SendbackMsg1Subset VARCHAR (2) NULL
	 , SendbackMsg2Subset VARCHAR (2) NULL
	 , PPONetworkJurisdictionInd VARCHAR (1) NULL
	 , ManualReductionMode NUMBER (5,0) NULL
	 , WholesaleSalesTaxZip VARCHAR (9) NULL
	 , RetailSalesTaxZip VARCHAR (9) NULL
	 , PPONetworkJurisdictionInsurerSeq NUMBER (10,0) NULL
	 , InvoicedWholesale VARCHAR (1) NULL
	 , InvoicedPPOWholesale VARCHAR (1) NULL
	 , AdmittingDxRef NUMBER (5,0) NULL
	 , AdmittingDxCode VARCHAR (8) NULL
	 , ProvFacilityNPI VARCHAR (10) NULL
	 , ProvBillingNPI VARCHAR (10) NULL
	 , ProvRenderingNPI VARCHAR (10) NULL
	 , ProvOperatingNPI VARCHAR (10) NULL
	 , ProvReferringNPI VARCHAR (10) NULL
	 , ProvOther1NPI VARCHAR (10) NULL
	 , ProvOther2NPI VARCHAR (10) NULL
	 , ProvOperatingLicenseNum VARCHAR (30) NULL
	 , EHubID VARCHAR (50) NULL
	 , OtherBillingProviderSubset VARCHAR (4) NULL
	 , OtherBillingProviderSeq NUMBER (19,0) NULL
	 , ResubmissionReasonCode VARCHAR (2) NULL
	 , ContractType VARCHAR (2) NULL
	 , ContractAmount NUMBER (19,4) NULL
	 , PriorAuthReferralNum1 VARCHAR (30) NULL
	 , PriorAuthReferralNum2 VARCHAR (30) NULL
	 , DRGCompositeFactor NUMBER (19,4) NULL
	 , DRGDischargeFraction NUMBER (19,4) NULL
	 , DRGInpatientMultiplier NUMBER (19,4) NULL
	 , DRGWeight NUMBER (19,4) NULL
	 , EFTPmtMethodCode VARCHAR (3) NULL
	 , EFTPmtFormatCode VARCHAR (10) NULL
	 , EFTSenderDFIID VARCHAR (27) NULL
	 , EFTSenderAcctNum VARCHAR (50) NULL
	 , EFTOrigCoSupplCode VARCHAR (24) NULL
	 , EFTReceiverDFIID VARCHAR (27) NULL
	 , EFTReceiverAcctQual VARCHAR (3) NULL
	 , EFTReceiverAcctNum VARCHAR (50) NULL
	 , PolicyLimitResult VARCHAR (1) NULL
	 , HistoryBatchNumber NUMBER (10,0) NULL
	 , ProvBillingTaxonomy VARCHAR (11) NULL
	 , ProvFacilityTaxonomy VARCHAR (11) NULL
	 , ProvRenderingTaxonomy VARCHAR (11) NULL
	 , PPOStackList VARCHAR (255) NULL
	 , ICDVersion NUMBER (5,0) NULL
	 , ODGFlag NUMBER (5,0) NULL
	 , ProvBillLicenseNum VARCHAR (30) NULL
	 , ProvFacilityLicenseNum VARCHAR (30) NULL
	 , ProvVendorExternalID VARCHAR (30) NULL
	 , BRActualClientCode VARCHAR (4) NULL
	 , BROverrideClientCode VARCHAR (4) NULL
	 , BillReevalReasonCode VARCHAR (30) NULL
	 , PaymentClearedDate DATETIME NULL
	 , EstimatedBRClientCode VARCHAR (4) NULL
	 , EstimatedBRJuris VARCHAR (2) NULL
	 , OverrideFeeControlRetail VARCHAR (4) NULL
	 , OverrideFeeControlWholesale VARCHAR (4) NULL
	 , StatementFromDate DATETIME NULL
	 , StatementThroughDate DATETIME NULL
 ); 
