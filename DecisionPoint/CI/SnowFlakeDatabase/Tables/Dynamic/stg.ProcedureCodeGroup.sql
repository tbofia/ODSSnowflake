CREATE OR REPLACE TABLE stg.ProcedureCodeGroup (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProcedureCode VARCHAR(7) NOT NULL
	 , MajorCategory VARCHAR(500) NULL
	 , MinorCategory VARCHAR(500) NULL
);

