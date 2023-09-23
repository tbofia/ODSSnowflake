CREATE TABLE IF NOT EXISTS src.SENTRY_ACTION (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ActionID NUMBER(10, 0) NOT NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR(100) NULL
	 , CompatibilityKey VARCHAR(50) NULL
	 , PredefinedValues VARCHAR NULL
	 , ValueDataType VARCHAR(50) NULL
	 , ValueFormat VARCHAR(250) NULL
	 , BillLineAction NUMBER(10, 0) NULL
	 , AnalyzeFlag NUMBER(5, 0) NULL
	 , ActionCategoryIDNo NUMBER(10, 0) NULL
);

