CREATE TABLE IF NOT EXISTS src.BILL_HDR (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER(10, 0) NOT NULL
	 , CMT_HDR_IDNo NUMBER(10, 0) NULL
	 , DateSaved DATETIME NULL
	 , DateRcv DATETIME NULL
	 , InvoiceNumber VARCHAR(40) NULL
	 , InvoiceDate DATETIME NULL
	 , FileNumber VARCHAR(50) NULL
	 , Note VARCHAR(20) NULL
	 , NoLines NUMBER(5, 0) NULL
	 , AmtCharged NUMBER(19, 4) NULL
	 , AmtAllowed NUMBER(19, 4) NULL
	 , ReasonVersion NUMBER(5, 0) NULL
	 , Region VARCHAR(50) NULL
	 , PvdUpdateCounter NUMBER(5, 0) NULL
	 , FeatureID NUMBER(10, 0) NULL
	 , ClaimDateLoss DATETIME NULL
	 , CV_Type VARCHAR(2) NULL
	 , Flags NUMBER(10, 0) NULL
	 , WhoCreate VARCHAR(15) NULL
	 , WhoLast VARCHAR(15) NULL
	 , AcceptAssignment NUMBER(5, 0) NULL
	 , EmergencyService NUMBER(5, 0) NULL
	 , CmtPaidDeductible NUMBER(19, 4) NULL
	 , InsPaidLimit NUMBER(19, 4) NULL
	 , StatusFlag VARCHAR(2) NULL
	 , OfficeId NUMBER(10, 0) NULL
	 , CmtPaidCoPay NUMBER(19, 4) NULL
	 , AmbulanceMethod NUMBER(5, 0) NULL
	 , StatusDate DATETIME NULL
	 , Category NUMBER(10, 0) NULL
	 , CatDesc VARCHAR(1000) NULL
	 , AssignedUser VARCHAR(15) NULL
	 , CreateDate DATETIME NULL
	 , PvdZOS VARCHAR(12) NULL
	 , PPONumberSent NUMBER(5, 0) NULL
	 , AdmissionDate DATETIME NULL
	 , DischargeDate DATETIME NULL
	 , DischargeStatus NUMBER(5, 0) NULL
	 , TypeOfBill VARCHAR(4) NULL
	 , SentryMessage VARCHAR(1000) NULL
	 , AmbulanceZipOfPickup VARCHAR(12) NULL
	 , AmbulanceNumberOfPatients NUMBER(5, 0) NULL
	 , WhoCreateID NUMBER(10, 0) NULL
	 , WhoLastId NUMBER(10, 0) NULL
	 , NYRequestDate DATETIME NULL
	 , NYReceivedDate DATETIME NULL
	 , ImgDocId VARCHAR(50) NULL
	 , PaymentDecision NUMBER(5, 0) NULL
	 , PvdCMSId VARCHAR(6) NULL
	 , PvdNPINo VARCHAR(15) NULL
	 , DischargeHour VARCHAR(2) NULL
	 , PreCertChanged NUMBER(5, 0) NULL
	 , DueDate DATETIME NULL
	 , AttorneyIDNo NUMBER(10, 0) NULL
	 , AssignedGroup NUMBER(10, 0) NULL
	 , LastChangedOn DATETIME NULL
	 , PrePPOAllowed NUMBER(19, 4) NULL
	 , PPSCode NUMBER(5, 0) NULL
	 , SOI NUMBER(5, 0) NULL
	 , StatementStartDate DATETIME NULL
	 , StatementEndDate DATETIME NULL
	 , DeductibleOverride BOOLEAN NULL
	 , AdmissionType NUMBER(3, 0) NULL
	 , CoverageType VARCHAR(2) NULL
	 , PricingProfileId NUMBER(10, 0) NULL
	 , DesignatedPricingState VARCHAR(2) NULL
	 , DateAnalyzed DATETIME NULL
	 , SentToPpoSysId NUMBER(10, 0) NULL
	 , PricingState VARCHAR(2) NULL
	 , BillVpnEligible BOOLEAN NULL
	 , ApportionmentPercentage NUMBER(5, 2) NULL
	 , BillSourceId NUMBER(3, 0) NULL
	 , OutOfStateProviderNumber NUMBER(10, 0) NULL
	 , FloridaDeductibleRuleEligible BOOLEAN NULL
);

