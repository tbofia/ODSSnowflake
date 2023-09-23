CREATE TABLE IF NOT EXISTS src.SurgicalModifierException (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Modifier VARCHAR(2) NOT NULL
	 , State VARCHAR(2) NOT NULL
	 , CoverageType VARCHAR(2) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
);

