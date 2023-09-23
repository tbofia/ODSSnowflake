CREATE OR REPLACE TABLE stg.WFQueue( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EntityTypeCode VARCHAR (2) NULL
	 , EntitySubset VARCHAR (4) NULL
	 , EntitySeq NUMBER (19,0) NULL
	 , WFTaskSeq NUMBER (10,0) NULL
	 , PriorWFTaskSeq NUMBER (10,0) NULL
	 , Status VARCHAR (1) NULL
	 , Priority VARCHAR (1) NULL
	 , CreateUserID VARCHAR (2) NULL
	 , CreateDate DATETIME NULL
	 , ModUserID VARCHAR (2) NULL
	 , ModDate DATETIME NULL
	 , TaskMessage VARCHAR (500) NULL
	 , Parameter1 VARCHAR (35) NULL
	 , ContextID VARCHAR (256) NULL
	 , PriorStatus VARCHAR (1) NULL
 ); 
