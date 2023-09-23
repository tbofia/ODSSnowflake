CREATE OR REPLACE TABLE stg.ApportionmentEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ApportionmentEndnote NUMBER(10, 0) NOT NULL
	 , ShortDescription VARCHAR(50) NULL
	 , LongDescription VARCHAR(500) NULL
);

