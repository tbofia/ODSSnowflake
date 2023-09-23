CREATE TABLE IF NOT EXISTS src.ModifierToProcedureCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProcedureCode VARCHAR(5) NOT NULL
	 , Modifier VARCHAR(2) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , SojFlag NUMBER(5, 0) NULL
	 , RequiresGuidelineReview BOOLEAN NULL
	 , Reference VARCHAR(255) NULL
	 , Comments VARCHAR(255) NULL
);

