CREATE OR REPLACE TABLE STG.CLAIM_DETAIL_OPERATIONAL
(
    OdsCustomerId INT NULL,
    CompanyName VARCHAR(100) NULL,
    OfficeName VARCHAR(100) NULL,
    SOJ VARCHAR(2) NULL,
    BillIDNo INT NULL,
    CreateDate DATETIME NULL,
    DateCommitted DATETIME NULL,
    DateRcv DATETIME NULL,
    MitchellReceivedDate DATETIME NULL,
    LINE_NO INT NULL,
	LineType INT NULL,
	NDC VARCHAR(20) NULL,
    DateSaved DATETIME NULL,
    UserId INT NULL,
    lAdjIdNo INT NULL,
    OfficeIdNo INT NULL,
    BillType VARCHAR(12) NULL,
    FirstNurseCompleteDate DATETIME NULL,
    SecondNurseCompleteDate DATETIME NULL,
    ThirdNurseCompleteDate DATETIME NULL,
    MitchellCmptDate DATETIME NULL,
    DateLoss DATETIME NULL,
    PPOReturnedDate DATETIME NULL,
    PPOReceivedDate DATETIME NULL,
    CONSTRAINT PK_CLAIM_DETAIL_BILLLINE PRIMARY KEY (OdsCustomerId, BillIDNo, LINE_NO)
);

