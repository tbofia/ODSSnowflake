CREATE TABLE IF NOT EXISTS src.ny_specialty (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RatingCode VARCHAR(12) NOT NULL
	 , Desc_ VARCHAR(70) NULL
	 , CbreSpecialtyCode VARCHAR(12) NULL
);

