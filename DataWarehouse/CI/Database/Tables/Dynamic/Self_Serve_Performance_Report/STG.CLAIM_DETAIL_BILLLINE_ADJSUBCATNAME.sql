CREATE OR REPLACE TABLE STG.CLAIM_DETAIL_BILLLINE_ADJSUBCATNAME
(
    OdsCustomerId INT NULL,
    BillID INT NULL,
    BillLine INT NULL,
    ReductionType VARCHAR(100) NULL,
    AdjSubCatName VARCHAR(50) NULL,
    Adjustment DECIMAL(19, 9) NULL,
	runDate DATETIME,
    CONSTRAINT PK_CLAIM_DETAIL_BILLLINE_ADJSUBCATNAME PRIMARY KEY (OdsCustomerId, BillID, BillLine, AdjSubCatName)
);
