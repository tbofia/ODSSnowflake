CREATE OR REPLACE TABLE stg.TreatmentCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TreatmentCategoryId NUMBER(3, 0) NOT NULL
	 , Category VARCHAR(50) NULL
	 , Metadata VARCHAR NULL
);

