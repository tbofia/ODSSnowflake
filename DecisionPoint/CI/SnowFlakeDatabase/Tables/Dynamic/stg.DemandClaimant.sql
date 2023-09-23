CREATE OR REPLACE TABLE stg.DemandClaimant (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NOT NULL
	 , ExternalClaimantId NUMBER(10, 0) NULL
	 , OrganizationId VARCHAR(100) NULL
	 , HeightInInches NUMBER(5, 0) NULL
	 , Weight NUMBER(5, 0) NULL
	 , Occupation VARCHAR(50) NULL
	 , BiReportStatus NUMBER(5, 0) NULL
	 , HasDemandPackage NUMBER(10, 0) NULL
	 , FactsOfLoss VARCHAR(250) NULL
	 , PreExistingConditions VARCHAR(100) NULL
	 , Archived BOOLEAN NULL
);

