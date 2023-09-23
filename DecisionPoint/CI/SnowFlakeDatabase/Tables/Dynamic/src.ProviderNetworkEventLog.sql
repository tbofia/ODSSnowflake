CREATE TABLE IF NOT EXISTS src.ProviderNetworkEventLog (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , IDField NUMBER(10, 0) NOT NULL
	 , LogDate DATETIME NULL
	 , EventId NUMBER(10, 0) NULL
	 , ClaimIdNo NUMBER(10, 0) NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , UserId NUMBER(10, 0) NULL
	 , NetworkId NUMBER(10, 0) NULL
	 , FileName VARCHAR(255) NULL
	 , ExtraText VARCHAR(1000) NULL
	 , ProcessInfo NUMBER(5, 0) NULL
	 , TieredTypeID NUMBER(5, 0) NULL
	 , TierNumber NUMBER(5, 0) NULL
);

