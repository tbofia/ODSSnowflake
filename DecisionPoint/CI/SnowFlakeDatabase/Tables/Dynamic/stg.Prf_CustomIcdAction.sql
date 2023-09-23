CREATE OR REPLACE TABLE stg.Prf_CustomIcdAction (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CustomIcdActionId NUMBER(10, 0) NOT NULL
	 , ProfileId NUMBER(10, 0) NULL
	 , IcdVersionId NUMBER(3, 0) NULL
	 , Action NUMBER(5, 0) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
);

