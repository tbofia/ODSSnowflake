CREATE TABLE IF NOT EXISTS src.prf_CTGMaxPenaltyLines (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CTGMaxPenLineID NUMBER(10, 0) NOT NULL
	 , ProfileId NUMBER(10, 0) NULL
	 , DatesBasedOn NUMBER(5, 0) NULL
	 , MaxPenaltyPercent NUMBER(5, 0) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
);

