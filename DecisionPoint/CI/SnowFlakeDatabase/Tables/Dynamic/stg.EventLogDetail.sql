CREATE OR REPLACE TABLE stg.EventLogDetail (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EventLogDetailId NUMBER(10, 0) NOT NULL
	 , EventLogId NUMBER(10, 0) NULL
	 , PropertyName VARCHAR(50) NULL
	 , OldValue VARCHAR NULL
	 , NewValue VARCHAR NULL
);

