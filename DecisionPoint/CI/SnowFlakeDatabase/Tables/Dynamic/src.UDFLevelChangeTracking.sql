CREATE TABLE IF NOT EXISTS src.UDFLevelChangeTracking (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , UDFLevelChangeTrackingId NUMBER(10, 0) NOT NULL
	 , EntityType NUMBER(10, 0) NULL
	 , EntityId NUMBER(10, 0) NULL
	 , CorrelationId VARCHAR(50) NULL
	 , UDFId NUMBER(10, 0) NULL
	 , PreviousValue VARCHAR NULL
	 , UpdatedValue VARCHAR NULL
	 , UserId NUMBER(10, 0) NULL
	 , ChangeDate DATETIME NULL
);

