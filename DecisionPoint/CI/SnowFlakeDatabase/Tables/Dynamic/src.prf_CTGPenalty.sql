CREATE TABLE IF NOT EXISTS src.prf_CTGPenalty (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CTGPenID NUMBER(10, 0) NOT NULL
	 , ProfileId NUMBER(10, 0) NULL
	 , ApplyPreCerts NUMBER(5, 0) NULL
	 , NoPrecertLogged NUMBER(5, 0) NULL
	 , MaxTotalPenalty NUMBER(5, 0) NULL
	 , TurnTimeForAppeals NUMBER(5, 0) NULL
	 , ApplyEndnoteForPercert NUMBER(5, 0) NULL
	 , ApplyEndnoteForCarePath NUMBER(5, 0) NULL
	 , ExemptPrecertPenalty NUMBER(5, 0) NULL
	 , ApplyNetworkPenalty BOOLEAN NULL
);

