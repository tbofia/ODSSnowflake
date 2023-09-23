CREATE TABLE IF NOT EXISTS src.StateSettingsNY (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsNYID NUMBER(10, 0) NOT NULL
	 , NF10PrintDate BOOLEAN NULL
	 , NF10CheckBox1 BOOLEAN NULL
	 , NF10CheckBox18 BOOLEAN NULL
	 , NF10UseUnderwritingCompany BOOLEAN NULL
	 , UnderwritingCompanyUdfId NUMBER(10, 0) NULL
	 , NaicUdfId NUMBER(10, 0) NULL
	 , DisplayNYPrintOptionsWhenZosOrSojIsNY BOOLEAN NULL
	 , NF10DuplicatePrint BOOLEAN NULL
);

