CREATE TABLE IF NOT EXISTS src.ModifierDictionary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ModifierDictionaryId NUMBER(10, 0) NOT NULL
	 , Modifier VARCHAR(2) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
	 , Description VARCHAR(100) NULL
	 , Global BOOLEAN NULL
	 , AnesMedDirect BOOLEAN NULL
	 , AffectsPricing BOOLEAN NULL
	 , IsCoSurgeon BOOLEAN NULL
	 , IsAssistantSurgery BOOLEAN NULL
);

