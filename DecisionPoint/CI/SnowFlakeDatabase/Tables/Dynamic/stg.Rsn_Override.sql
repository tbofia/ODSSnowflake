CREATE OR REPLACE TABLE stg.rsn_Override (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , ShortDesc VARCHAR(50) NULL
	 , LongDesc VARCHAR NULL
	 , CategoryIdNo NUMBER(5, 0) NULL
	 , ClientSpec NUMBER(5, 0) NULL
	 , COAIndex NUMBER(5, 0) NULL
	 , NJPenaltyPct NUMBER(9, 6) NULL
	 , NetworkID NUMBER(10, 0) NULL
	 , SpecialProcessing BOOLEAN NULL
);

