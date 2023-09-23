CREATE OR REPLACE TABLE stg.prf_COMPANY (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CompanyId NUMBER(10, 0) NOT NULL
	 , CompanyName VARCHAR(50) NULL
	 , LastChangedOn DATETIME NULL
);

