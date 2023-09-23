CREATE OR REPLACE TABLE stg.Vpn (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , VpnId NUMBER(5, 0) NOT NULL
	 , NetworkName VARCHAR(50) NULL
	 , PendAndSend BOOLEAN NULL
	 , BypassMatching BOOLEAN NULL
	 , AllowsResends BOOLEAN NULL
	 , OdsEligible BOOLEAN NULL
);

