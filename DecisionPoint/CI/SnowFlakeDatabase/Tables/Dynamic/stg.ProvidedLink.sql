CREATE OR REPLACE TABLE stg.ProvidedLink( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProvidedLinkId NUMBER (10,0) NULL
	 , Title VARCHAR (100) NULL
	 , URL VARCHAR (150) NULL
	 , OrderIndex NUMBER (3,0) NULL
 ); 
