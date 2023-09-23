CREATE TABLE IF NOT EXISTS src.ServiceCodeGroup( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , SiteCode VARCHAR (3) NOT NULL
	 , GroupType VARCHAR (8) NOT NULL
	 , Family VARCHAR (8) NOT NULL
	 , Revision VARCHAR (4) NOT NULL
	 , GroupCode VARCHAR (8) NOT NULL
	 , CodeOrder NUMBER (10,0) NOT NULL
	 , ServiceCode VARCHAR (12) NOT NULL
	 , ServiceCodeType VARCHAR (8) NULL
	 , LinkGroupType VARCHAR (8) NULL
	 , LinkGroupFamily VARCHAR (8) NULL
	 , CodeLevel NUMBER (5,0) NULL
	 , GlobalPriority NUMBER (10,0) NULL
	 , Active VARCHAR (1) NULL
	 , Comment VARCHAR (2000) NULL
	 , CustomParameters VARCHAR (4000) NULL
	 , CreateDate DATETIME NULL
	 , CreateUserID VARCHAR (2) NULL
	 , ModDate DATETIME NULL
	 , ModUserID VARCHAR (2) NULL
 ); 
