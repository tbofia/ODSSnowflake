CREATE TABLE IF NOT EXISTS src.Medispan( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , NDC VARCHAR (11) NOT NULL
	 , DEA VARCHAR (5) NULL
	 , Name1 VARCHAR (25) NULL
	 , Name2 VARCHAR (4) NULL
	 , Name3 VARCHAR (11) NULL
	 , Strength NUMBER (10,0) NULL
	 , Unit NUMBER (10,0) NULL
	 , Pkg VARCHAR (2) NULL
	 , Factor NUMBER (5,0) NULL
	 , GenericDrug VARCHAR (1) NULL
	 , Desicode VARCHAR (1) NULL
	 , Rxotc VARCHAR (1) NULL
	 , GPI VARCHAR (14) NULL
	 , Awp1 NUMBER (10,0) NULL
	 , Awp0 NUMBER (10,0) NULL
	 , Awp2 NUMBER (10,0) NULL
	 , EffectiveDt2 DATETIME NULL
	 , EffectiveDt1 DATETIME NULL
	 , EffectiveDt0 DATETIME NULL
	 , FDAEquivalence VARCHAR (3) NULL
	 , NDCFormat VARCHAR (1) NULL
	 , RestrictDrugs VARCHAR (1) NULL
	 , GPPC VARCHAR (8) NULL
	 , Status VARCHAR (1) NULL
	 , UpdateDate DATETIME NULL
	 , AAWP NUMBER (10,0) NULL
	 , GAWP NUMBER (10,0) NULL
	 , RepackagedCode VARCHAR (2) NULL
 ); 
