CREATE TABLE IF NOT EXISTS src.Note (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , NoteId NUMBER(10, 0) NOT NULL
	 , DateCreated TIMESTAMP_LTZ(7) NULL
	 , DateModified TIMESTAMP_LTZ(7) NULL
	 , CreatedBy VARCHAR(15) NULL
	 , ModifiedBy VARCHAR(15) NULL
	 , Flag NUMBER(3, 0) NULL
	 , Content VARCHAR(250) NULL
	 , NoteContext NUMBER(5, 0) NULL
	 , DemandClaimantId NUMBER(10, 0) NULL
);

