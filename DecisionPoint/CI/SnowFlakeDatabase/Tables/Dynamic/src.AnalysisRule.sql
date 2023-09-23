CREATE TABLE IF NOT EXISTS src.AnalysisRule (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , AnalysisRuleId NUMBER(10, 0) NOT NULL
	 , Title VARCHAR(200) NULL
	 , AssemblyQualifiedName VARCHAR(200) NULL
	 , MethodToInvoke VARCHAR(50) NULL
	 , DisplayMessage VARCHAR(200) NULL
	 , DisplayOrder NUMBER(10, 0) NULL
	 , IsActive BOOLEAN NULL
	 , CreateDate TIMESTAMP_LTZ(7) NULL
	 , LastChangedOn TIMESTAMP_LTZ(7) NULL
	 , MessageToken VARCHAR(200) NULL
);

