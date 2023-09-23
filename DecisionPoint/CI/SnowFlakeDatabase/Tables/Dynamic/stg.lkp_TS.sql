CREATE OR REPLACE TABLE stg.lkp_TS (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ShortName VARCHAR(2) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , LongName VARCHAR(100) NULL
	 , Global NUMBER(5, 0) NULL
	 , AnesMedDirect NUMBER(5, 0) NULL
	 , AffectsPricing NUMBER(5, 0) NULL
	 , IsAssistantSurgery BOOLEAN NULL
	 , IsCoSurgeon BOOLEAN NULL
);

