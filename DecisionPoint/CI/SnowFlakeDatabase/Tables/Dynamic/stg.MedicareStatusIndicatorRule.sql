CREATE OR REPLACE TABLE stg.MedicareStatusIndicatorRule (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , MedicareStatusIndicatorRuleId NUMBER(10, 0) NOT NULL
	 , MedicareStatusIndicatorRuleName VARCHAR(50) NULL
	 , StatusIndicator VARCHAR(500) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
	 , Endnote NUMBER(10, 0) NULL
	 , EditActionId NUMBER(3, 0) NULL
	 , Comments VARCHAR(1000) NULL
);

