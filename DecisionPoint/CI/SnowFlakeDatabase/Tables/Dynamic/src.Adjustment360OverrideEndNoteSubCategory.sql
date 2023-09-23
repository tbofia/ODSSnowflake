CREATE TABLE IF NOT EXISTS src.Adjustment360OverrideEndNoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId NUMBER(10, 0) NULL
);

