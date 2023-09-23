CREATE OR REPLACE TABLE stg.prf_CTGPenaltyHdr (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CTGPenHdrID NUMBER(10, 0) NOT NULL
	 , ProfileId NUMBER(10, 0) NULL
	 , PenaltyType NUMBER(5, 0) NULL
	 , PayNegRate NUMBER(5, 0) NULL
	 , PayPPORate NUMBER(5, 0) NULL
	 , DatesBasedOn NUMBER(5, 0) NULL
	 , ApplyPenaltyToPharmacy BOOLEAN NULL
	 , ApplyPenaltyCondition BOOLEAN NULL
);

