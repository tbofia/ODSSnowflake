CREATE TABLE IF NOT EXISTS src.ModifierByState (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , State VARCHAR(2) NOT NULL
	 , ProcedureServiceCategoryId NUMBER(3, 0) NOT NULL
	 , ModifierDictionaryId NUMBER(10, 0) NOT NULL
);

