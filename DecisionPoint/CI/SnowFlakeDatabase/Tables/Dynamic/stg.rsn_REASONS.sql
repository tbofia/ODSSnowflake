CREATE OR REPLACE TABLE stg.rsn_REASONS (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , CV_Type VARCHAR(2) NULL
	 , ShortDesc VARCHAR(50) NULL
	 , LongDesc VARCHAR NULL
	 , CategoryIdNo NUMBER(10, 0) NULL
	 , COAIndex NUMBER(5, 0) NULL
	 , OverrideEndnote NUMBER(10, 0) NULL
	 , HardEdit NUMBER(5, 0) NULL
	 , SpecialProcessing BOOLEAN NULL
	 , EndnoteActionId NUMBER(3, 0) NULL
	 , RetainForEapg BOOLEAN NULL
);

