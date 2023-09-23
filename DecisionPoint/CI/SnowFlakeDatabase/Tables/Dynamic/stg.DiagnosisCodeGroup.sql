CREATE OR REPLACE TABLE stg.DiagnosisCodeGroup (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DiagnosisCode VARCHAR(8) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , MajorCategory VARCHAR(500) NULL
	 , MinorCategory VARCHAR(500) NULL
);

