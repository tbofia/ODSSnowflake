CREATE OR REPLACE TABLE stg.SENTRY_CRITERIA (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CriteriaID NUMBER(10, 0) NOT NULL
	 , ParentName VARCHAR(50) NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR(150) NULL
	 , Operators VARCHAR(50) NULL
	 , PredefinedValues VARCHAR NULL
	 , ValueDataType VARCHAR(50) NULL
	 , ValueFormat VARCHAR(250) NULL
	 , NullAllowed NUMBER(5, 0) NULL
);

