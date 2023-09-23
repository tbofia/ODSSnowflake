CREATE OR REPLACE TABLE stg.BILLS_CTG_Endnotes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , Line_No NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
	 , RuleType VARCHAR(2) NULL
	 , RuleId NUMBER(10, 0) NULL
	 , PreCertAction NUMBER(5, 0) NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
);

