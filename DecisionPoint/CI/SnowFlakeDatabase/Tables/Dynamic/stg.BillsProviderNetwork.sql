CREATE OR REPLACE TABLE stg.BillsProviderNetwork (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , NetworkId NUMBER(10, 0) NULL
	 , NetworkName VARCHAR(50) NULL
);

