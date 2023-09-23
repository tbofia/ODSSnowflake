CREATE OR REPLACE TABLE stg.prf_CTGPenaltyLines (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CTGPenLineID NUMBER(10, 0) NOT NULL
	 , ProfileId NUMBER(10, 0) NULL
	 , PenaltyType NUMBER(5, 0) NULL
	 , FeeSchedulePercent NUMBER(5, 0) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
	 , TurnAroundTime NUMBER(5, 0) NULL
);

