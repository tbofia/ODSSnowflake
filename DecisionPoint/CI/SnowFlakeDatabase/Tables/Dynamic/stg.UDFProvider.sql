CREATE OR REPLACE TABLE stg.UDFProvider (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PvdIdNo NUMBER(10, 0) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
	 , UDFValueText VARCHAR(255) NULL
	 , UDFValueDecimal NUMBER(19, 4) NULL
	 , UDFValueDate DATETIME NULL
);

