CREATE TABLE IF NOT EXISTS src.ProviderNumberCriteria (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProviderNumberCriteriaId NUMBER(5, 0) NOT NULL
	 , ProviderNumber NUMBER(10, 0) NULL
	 , Priority NUMBER(3, 0) NULL
	 , FeeScheduleTable VARCHAR(1) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
);

