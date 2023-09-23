CREATE TABLE IF NOT EXISTS src.AcceptedTreatmentDate (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , AcceptedTreatmentDateId NUMBER(10, 0) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NULL
	 , TreatmentDate TIMESTAMP_LTZ(7) NULL
	 , Comments VARCHAR(255) NULL
	 , TreatmentCategoryId NUMBER(3, 0) NULL
	 , LastUpdatedBy VARCHAR(15) NULL
	 , LastUpdatedDate TIMESTAMP_LTZ(7) NULL
);

