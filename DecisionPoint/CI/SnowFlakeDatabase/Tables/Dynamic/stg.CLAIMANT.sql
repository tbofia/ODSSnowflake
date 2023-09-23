CREATE OR REPLACE TABLE stg.CLAIMANT (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CmtIDNo NUMBER(10, 0) NOT NULL
	 , ClaimIDNo NUMBER(10, 0) NULL
	 , CmtSSN VARCHAR(11) NULL
	 , CmtLastName VARCHAR(60) NULL
	 , CmtFirstName VARCHAR(35) NULL
	 , CmtMI VARCHAR(1) NULL
	 , CmtDOB DATETIME NULL
	 , CmtSEX VARCHAR(1) NULL
	 , CmtAddr1 VARCHAR(55) NULL
	 , CmtAddr2 VARCHAR(55) NULL
	 , CmtCity VARCHAR(30) NULL
	 , CmtState VARCHAR(2) NULL
	 , CmtZip VARCHAR(12) NULL
	 , CmtPhone VARCHAR(25) NULL
	 , CmtOccNo VARCHAR(11) NULL
	 , CmtAttorneyNo NUMBER(10, 0) NULL
	 , CmtPolicyLimit NUMBER(19, 4) NULL
	 , CmtStateOfJurisdiction VARCHAR(2) NULL
	 , CmtDeductible NUMBER(19, 4) NULL
	 , CmtCoPaymentPercentage NUMBER(5, 0) NULL
	 , CmtCoPaymentMax NUMBER(19, 4) NULL
	 , CmtPPO_Eligible NUMBER(5, 0) NULL
	 , CmtCoordBenefits NUMBER(5, 0) NULL
	 , CmtFLCopay NUMBER(5, 0) NULL
	 , CmtCOAExport DATETIME NULL
	 , CmtPGFirstName VARCHAR(30) NULL
	 , CmtPGLastName VARCHAR(30) NULL
	 , CmtDedType NUMBER(5, 0) NULL
	 , ExportToClaimIQ NUMBER(5, 0) NULL
	 , CmtInactive NUMBER(5, 0) NULL
	 , CmtPreCertOption NUMBER(5, 0) NULL
	 , CmtPreCertState VARCHAR(2) NULL
	 , CreateDate DATETIME NULL
	 , LastChangedOn DATETIME NULL
	 , OdsParticipant BOOLEAN NULL
	 , CoverageType VARCHAR(2) NULL
	 , DoNotDisplayCoverageTypeOnEOB BOOLEAN NULL
	 , ShowAllocationsOnEob BOOLEAN NULL
	 , SetPreAllocation BOOLEAN NULL
	 , PharmacyEligible NUMBER(3, 0) NULL
	 , SendCardToClaimant NUMBER(3, 0) NULL
	 , ShareCoPayMaximum BOOLEAN NULL
);

