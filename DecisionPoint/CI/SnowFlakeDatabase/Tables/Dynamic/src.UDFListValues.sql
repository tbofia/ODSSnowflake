CREATE TABLE IF NOT EXISTS src.UDFListValues (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ListValueIdNo NUMBER(10, 0) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NULL
	 , SeqNo NUMBER(5, 0) NULL
	 , ListValue VARCHAR(50) NULL
	 , DefaultValue NUMBER(5, 0) NULL
);

