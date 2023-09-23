CREATE OR REPLACE TABLE stg.prf_PPO (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PPOSysId NUMBER(10, 0) NOT NULL
	 , ProfileId NUMBER(10, 0) NULL
	 , PPOId NUMBER(10, 0) NULL
	 , bStatus NUMBER(5, 0) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
	 , AutoSend NUMBER(5, 0) NULL
	 , AutoResend NUMBER(5, 0) NULL
	 , BypassMatching NUMBER(5, 0) NULL
	 , UseProviderNetworkEnrollment NUMBER(5, 0) NULL
	 , TieredTypeId NUMBER(5, 0) NULL
	 , Priority NUMBER(5, 0) NULL
	 , PolicyEffectiveDate DATETIME NULL
	 , BillFormType NUMBER(10, 0) NULL
);

