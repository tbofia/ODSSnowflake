CREATE OR REPLACE TABLE stg.ProcedureServiceCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProcedureServiceCategoryId NUMBER(3, 0) NOT NULL
	 , ProcedureServiceCategoryName VARCHAR(50) NULL
	 , ProcedureServiceCategoryDescription VARCHAR(100) NULL
	 , LegacyTableName VARCHAR(100) NULL
	 , LegacyBitValue NUMBER(10, 0) NULL
);

