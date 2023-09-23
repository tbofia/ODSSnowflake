CREATE OR REPLACE TABLE stg.ProviderSpecialtyToProvType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProviderType VARCHAR(20) NOT NULL
	 , ProviderType_Desc VARCHAR(80) NULL
	 , Specialty VARCHAR(20) NOT NULL
	 , Specialty_Desc VARCHAR(80) NULL
	 , CreateDate DATETIME NULL
	 , ModifyDate DATETIME NULL
	 , LogicalDelete VARCHAR(1) NULL
);

