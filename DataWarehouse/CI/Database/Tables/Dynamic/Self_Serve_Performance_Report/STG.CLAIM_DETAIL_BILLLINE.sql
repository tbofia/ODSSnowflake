CREATE OR REPLACE TABLE STG.CLAIM_DETAIL_BILLLINE
(
    OdsCustomerId INT NULL,
    CustomerName VARCHAR(100) NULL,
    Company VARCHAR(100) NULL,
    Office VARCHAR(100) NULL,
    SOJ VARCHAR(2) NULL,
    ClaimCoverageType VARCHAR(5) NULL,
    BillCoverageType VARCHAR(5) NULL,
    FormType VARCHAR(12) NULL,
    ClaimNo VARCHAR(255) NULL,
    ClaimantID INT NULL,
    ProviderTIN VARCHAR(15) NULL,
    BillID INT NULL,
    BillCreateDate DATETIME NULL,
    BillCommitDate DATETIME NULL,
    MitchellCompleteDate DATETIME NULL,
    ClaimCreateDate DATETIME NULL,
    ClaimDateofLoss DATETIME NULL,
    ExpectedRecoveryDate DATETIME NULL,
    BillLine INT NULL,
	LineType INT NULL,
	NDC VARCHAR(20) NULL,
    ProcedureCode VARCHAR(15) NULL,
    ProcedureCodeDescription VARCHAR NULL,
    ProcedureCodeMajorGroup VARCHAR(100) NULL,
    DuplicateBillFlag SMALLINT NULL,
    DuplicateLineFlag SMALLINT NULL,
	NETWORKNAME VARCHAR(50) NULL,
	CMTZIP VARCHAR(12) NULL,
	LINESTARTDATEOFSERVICE DATETIME NULL,
	LINEENDDATEOFSERVICE DATETIME NULL,
	PVDLASTNAME VARCHAR(60) NULL,
	PVDFIRSTNAME VARCHAR(35) NULL,
	PVDGROUP VARCHAR(60) NULL,
	PVDZOS VARCHAR(12) NULL,
	PVDSTATE VARCHAR(2) NULL,
	PVDSPC_LIST VARCHAR(8000) NULL,
	CMTDOB DATETIME NULL,
	DX VARCHAR(8) NULL,
	DXCODEDESCRIPTION VARCHAR(8000) NULL,
	ICDVERSION INT NULL,
	DXMAJORGROUP VARCHAR(8000) NULL,
	MODIFIER VARCHAR(14) NULL,
	MODIFIERDESCRIPTION VARCHAR(8000) NULL,
	TYPEOFBILL VARCHAR(4) NULL,
	DESCRIPTION VARCHAR(8000) NULL,
	REVCODE VARCHAR(4) NULL,
	POSCODE VARCHAR(4) NULL,
	AdjustorId INT NULL,
	UserId INT NULL,
	PPOReceivedDate DATETIME NULL,
	PPOReturnedDate DATETIME NULL,
	CarrierReceivedDate DATETIME NULL,
	MitchellReceivedDate DATETIME NULL,
	OverrideDateTime DATETIME NULL,
	FirstNurseCompleteDate DATETIME NULL,
	SecondNurseCompleteDate DATETIME NULL,
	ThirdNurseCompleteDate DATETIME NULL,
    ProviderCharges DECIMAL(19, 9) NULL, 
    TotalAllowed DECIMAL(19, 9) NULL,
    TotalUnits REAL NULL,
    ExpectedRecoveryDuration INT NULL,
    CompanyId INT NULL,
    OfficeId INT NULL,
	EBILL_FLAG BOOLEAN NULL,
	ADJUSTOR_LAST_NAME VARCHAR(30) NULL,
	ADJUSTOR_FIRST_NAME VARCHAR(30) NULL,
    CONSTRAINT PK_CLAIM_DETAIL_BILLLINE PRIMARY KEY (OdsCustomerId, BillID, BillLine)
);

