CREATE OR REPLACE TABLE stg.AnalysisRuleThreshold (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , AnalysisRuleThresholdId NUMBER(10, 0) NOT NULL
	 , AnalysisRuleId NUMBER(10, 0) NULL
	 , ThresholdKey VARCHAR(50) NULL
	 , ThresholdValue VARCHAR(100) NULL
	 , CreateDate TIMESTAMP_LTZ(7) NULL
	 , LastChangedOn TIMESTAMP_LTZ(7) NULL
);

