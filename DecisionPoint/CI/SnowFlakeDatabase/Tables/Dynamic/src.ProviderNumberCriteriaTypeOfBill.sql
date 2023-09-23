CREATE TABLE IF NOT EXISTS src.ProviderNumberCriteriaTypeOfBill (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProviderNumberCriteriaId NUMBER(5, 0) NOT NULL
	 , TypeOfBill VARCHAR(4) NOT NULL
	 , MatchingProfileNumber NUMBER(3, 0) NULL
	 , AttributeMatchTypeId NUMBER(3, 0) NULL
);

