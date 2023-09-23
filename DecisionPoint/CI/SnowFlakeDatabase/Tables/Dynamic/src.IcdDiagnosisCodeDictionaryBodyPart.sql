CREATE TABLE IF NOT EXISTS src.IcdDiagnosisCodeDictionaryBodyPart (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DiagnosisCode VARCHAR(8) NOT NULL
	 , IcdVersion NUMBER(3, 0) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , NcciBodyPartId NUMBER(3, 0) NOT NULL
);

