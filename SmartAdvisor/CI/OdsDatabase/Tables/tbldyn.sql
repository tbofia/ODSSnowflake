IF OBJECT_ID('adm.AppVersion', 'U') IS NULL
BEGIN

    CREATE TABLE adm.AppVersion
        (
            AppVersionId INT IDENTITY(1, 1) ,
            AppVersion VARCHAR(10) NULL ,
            AppVersionDate DATETIME2(7) NULL,
			ProductKey VARCHAR(100) NULL
        );

    ALTER TABLE adm.AppVersion ADD 
    CONSTRAINT PK_AppVersion PRIMARY KEY CLUSTERED (AppVersionId);

END
GO

-- Add Product Key Column
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'adm.AppVersion')
						AND NAME = 'ProductKey' )
	BEGIN
		ALTER TABLE adm.AppVersion ADD ProductKey VARCHAR(100) NULL ;
	END ; 
GO
IF OBJECT_ID('adm.LoadStatus', 'U') IS NULL
BEGIN
CREATE TABLE adm.LoadStatus
(	JobRunId INT IDENTITY(1,1) NOT NULL,
	JobName VARCHAR(MAX) NOT NULL,
	Status VARCHAR(5) NOT NULL,
	NoOfCustomers INT NULL,
	StartDate DATETIME NOT NULL,
	EndDate DATETIME NULL 
	)
END
GO

SET NOCOUNT ON;
IF OBJECT_ID('adm.PostingGroupAudit', 'U') IS NULL
BEGIN
    CREATE TABLE adm.PostingGroupAudit
        (
            PostingGroupAuditId INT IDENTITY(1, 1) ,
            OltpPostingGroupAuditId INT NOT NULL,
            PostingGroupId TINYINT NOT NULL ,
            CustomerId INT NOT NULL,
            Status VARCHAR(2) NOT NULL ,
            DataExtractTypeId INT NOT NULL ,
            OdsVersion VARCHAR(10) NULL ,
            SnapshotCreateDate DATETIME2(7) NULL ,
            SnapshotDropDate DATETIME2(7) NULL ,
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE adm.PostingGroupAudit ADD 
    CONSTRAINT PK_PostingGroupAudit PRIMARY KEY CLUSTERED (PostingGroupAuditId);
END
GO

-- Rename AppVersion Column.
IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.PostingGroupAudit')
                        AND NAME = 'AppVersion' )
BEGIN
    EXEC sp_RENAME 'adm.PostingGroupAudit.AppVersion', 'OdsVersion', 'COLUMN'
END
GO

-- Rename IsIncremental Column
IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.PostingGroupAudit')
                        AND NAME = 'IsIncremental' )
BEGIN
    EXEC sp_RENAME 'adm.PostingGroupAudit.IsIncremental', 'DataExtractTypeId', 'COLUMN'
END
GO

-- Rename SnapshotDropDate Column
IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.PostingGroupAudit')
                        AND NAME = 'SnapshotDropDate' )
BEGIN
    EXEC sp_RENAME 'adm.PostingGroupAudit.SnapshotDropDate', 'CoreDBVersionId', 'COLUMN'
END
GO

-- Change Datatype to INT Note. Have to change to Varchar first because cannot directly alter from Datetime2 to int
IF EXISTS ( SELECT 1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'adm.PostingGroupAudit')
                    AND c.name = 'CoreDBVersionId'
                    AND NOT t.name = 'INT' 
					)
    BEGIN
        ALTER TABLE adm.PostingGroupAudit ALTER COLUMN CoreDBVersionId VARCHAR NULL; 

		ALTER TABLE adm.PostingGroupAudit ALTER COLUMN CoreDBVersionId INT NULL;
    END;
GO
IF OBJECT_ID('adm.ProcessAudit', 'U') IS NULL
BEGIN
    CREATE TABLE adm.ProcessAudit
        (
            ProcessAuditId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
			TotalRecordsInSource BIGINT NULL,
			TotalRecordsInTarget BIGINT NULL,
			TotalDeletedRecords INT NULL,
			ControlRowCount INT NULL ,
            ExtractRowCount INT NULL,
            UpdateRowCount INT NULL,
            LoadRowCount INT NULL,
            ExtractDate DATETIME2(7) NULL ,
            LastUpdateDate DATETIME2(7) NULL ,
            LoadDate DATETIME2(7) NULL, 
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE adm.ProcessAudit ADD 
    CONSTRAINT PK_ProcessAudit PRIMARY KEY CLUSTERED (ProcessAuditId);

END
GO

-- Adding New Column to store Records count from control file
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.ProcessAudit')
                        AND NAME = 'ControlRowCount' )
    BEGIN
	BEGIN TRANSACTION 
	BEGIN TRY 

	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,ExtractRowCount AS ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	INTO #ProcessAudit
	FROM adm.ProcessAudit;
	
	DROP TABLE  adm.ProcessAudit;
	
	CREATE TABLE adm.ProcessAudit
        (
            ProcessAuditId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
			ControlRowCount INT NULL,
            ExtractRowCount INT NULL,
            UpdateRowCount INT NULL,
            LoadRowCount INT NULL,
            ExtractDate DATETIME2(7) NULL ,
            LastUpdateDate DATETIME2(7) NULL ,
            LoadDate DATETIME2(7) NULL, 
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE adm.ProcessAudit ADD 
    CONSTRAINT PK_ProcessAudit PRIMARY KEY CLUSTERED (ProcessAuditId);

  	SET IDENTITY_INSERT adm.ProcessAudit ON;
	INSERT INTO adm.ProcessAudit(
		   ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate)
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	FROM #ProcessAudit; 
	SET IDENTITY_INSERT adm.ProcessAudit OFF; 
	DROP TABLE #ProcessAudit;
	COMMIT
	END TRY
	BEGIN CATCH
	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	ROLLBACK
	END CATCH
	END;
GO

-- Adding New Column to store Records count from in Source
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.ProcessAudit')
                        AND NAME = 'TotalRecordsInSource' ) 
    BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,NULL AS TotalRecordsInSource
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	INTO #ProcessAudit
	FROM adm.ProcessAudit;
	
	DROP TABLE  adm.ProcessAudit;
	
	CREATE TABLE adm.ProcessAudit
        (
            ProcessAuditId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
			TotalRecordsInSource BIGINT NULL,
			ControlRowCount INT NULL,
            ExtractRowCount INT NULL,
            UpdateRowCount INT NULL,
            LoadRowCount INT NULL,
            ExtractDate DATETIME2(7) NULL ,
            LastUpdateDate DATETIME2(7) NULL ,
            LoadDate DATETIME2(7) NULL, 
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE adm.ProcessAudit ADD 
    CONSTRAINT PK_ProcessAudit PRIMARY KEY CLUSTERED (ProcessAuditId);

  	SET IDENTITY_INSERT adm.ProcessAudit ON;
	INSERT INTO adm.ProcessAudit(
		   ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate)
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	FROM #ProcessAudit; 
	SET IDENTITY_INSERT adm.ProcessAudit OFF; 
	DROP TABLE #ProcessAudit;
	COMMIT
	END TRY
	BEGIN CATCH
	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	ROLLBACK
	END CATCH
	END;
GO

-- Adding New Column to store Records count from in Source
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.ProcessAudit')
                        AND NAME = 'TotalRecordsInTarget' )
    BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,NULL AS TotalRecordsInTarget
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	INTO #ProcessAudit
	FROM adm.ProcessAudit;
	
	DROP TABLE  adm.ProcessAudit;
	
	CREATE TABLE adm.ProcessAudit
        (
            ProcessAuditId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
			TotalRecordsInSource BIGINT NULL,
			TotalRecordsInTarget BIGINT NULL,
			ControlRowCount INT NULL,
            ExtractRowCount INT NULL,
            UpdateRowCount INT NULL,
            LoadRowCount INT NULL,
            ExtractDate DATETIME2(7) NULL ,
            LastUpdateDate DATETIME2(7) NULL ,
            LoadDate DATETIME2(7) NULL, 
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE adm.ProcessAudit ADD 
    CONSTRAINT PK_ProcessAudit PRIMARY KEY CLUSTERED (ProcessAuditId);

  	SET IDENTITY_INSERT adm.ProcessAudit ON;
	INSERT INTO adm.ProcessAudit(
		   ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,TotalRecordsInTarget
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate)
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,TotalRecordsInTarget
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	FROM #ProcessAudit; 
	SET IDENTITY_INSERT adm.ProcessAudit OFF; 
	DROP TABLE #ProcessAudit;
	COMMIT
	END TRY
	BEGIN CATCH
	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	ROLLBACK
	END CATCH
	END;
GO


-- Adding New Column to store Number of deleted records
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.ProcessAudit')
                        AND NAME = 'TotalDeletedRecords' )

    BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,TotalRecordsInTarget
		  ,NULL AS TotalDeletedRecords
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	INTO  #ProcessAudit
	FROM adm.ProcessAudit;
	
	DROP TABLE  adm.ProcessAudit;
	
	CREATE TABLE adm.ProcessAudit
        (
            ProcessAuditId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Status VARCHAR(2) NOT NULL ,
			TotalRecordsInSource BIGINT NULL,
			TotalRecordsInTarget BIGINT NULL,
			TotalDeletedRecords INT NULL,
			ControlRowCount INT NULL,
            ExtractRowCount INT NULL,
            UpdateRowCount INT NULL,
            LoadRowCount INT NULL,
            ExtractDate DATETIME2(7) NULL ,
            LastUpdateDate DATETIME2(7) NULL ,
            LoadDate DATETIME2(7) NULL, 
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE adm.ProcessAudit ADD 
    CONSTRAINT PK_ProcessAudit PRIMARY KEY CLUSTERED (ProcessAuditId);

  	SET IDENTITY_INSERT adm.ProcessAudit ON;
	INSERT INTO adm.ProcessAudit(
		   ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,TotalRecordsInTarget
		  ,TotalDeletedRecords
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate)
	SELECT ProcessAuditId
		  ,PostingGroupAuditId
		  ,ProcessId
		  ,Status
		  ,TotalRecordsInSource
		  ,TotalRecordsInTarget
		  ,TotalDeletedRecords
		  ,ControlRowCount
		  ,ExtractRowCount
		  ,UpdateRowCount
		  ,LoadRowCount
		  ,ExtractDate
		  ,LastUpdateDate
		  ,LoadDate
		  ,CreateDate
		  ,LastChangeDate
	FROM #ProcessAudit; 
	SET IDENTITY_INSERT adm.ProcessAudit OFF; 
	DROP TABLE #ProcessAudit;
	COMMIT
	END TRY
	BEGIN CATCH
	IF OBJECT_ID('tempdb..#ProcessAudit') IS NOT NULL DROP TABLE #ProcessAudit
	ROLLBACK
	END CATCH
	END;
GO




IF OBJECT_ID('src.Adjuster', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Adjuster
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubSet CHAR (4) NOT NULL ,
			  Adjuster VARCHAR (25) NOT NULL ,
			  FirstName VARCHAR (20) NULL ,
			  LastName VARCHAR (20) NULL ,
			  MInitial CHAR (1) NULL ,
			  Title VARCHAR (20) NULL ,
			  Address1 VARCHAR (30) NULL ,
			  Address2 VARCHAR (30) NULL ,
			  City VARCHAR (20) NULL ,
			  State CHAR (2) NULL ,
			  Zip VARCHAR (9) NULL ,
			  PhoneNum VARCHAR (20) NULL ,
			  PhoneNumExt VARCHAR (10) NULL ,
			  FaxNum VARCHAR (20) NULL ,
			  Email VARCHAR (128) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Adjuster ADD 
     CONSTRAINT PK_Adjuster PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubSet, Adjuster) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Adjuster ON src.Adjuster   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.AdjusterPendGroup', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.AdjusterPendGroup
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubset CHAR (4) NOT NULL ,
			  Adjuster VARCHAR (25) NOT NULL ,
			  PendGroupCode VARCHAR (12) NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.AdjusterPendGroup ADD 
     CONSTRAINT PK_AdjusterPendGroup PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubset, Adjuster, PendGroupCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_AdjusterPendGroup ON src.AdjusterPendGroup   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Attorney', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Attorney
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubSet CHAR (4) NOT NULL ,
			  AttorneySeq BIGINT NOT NULL ,
			  TIN VARCHAR (9) NULL ,
			  TINSuffix VARCHAR (6) NULL ,
			  ExternalID VARCHAR (30) NULL ,
			  Name VARCHAR (50) NULL ,
			  GroupCode VARCHAR (5) NULL ,
			  LicenseNum VARCHAR (30) NULL ,
			  MedicareNum VARCHAR (20) NULL ,
			  PracticeAddressSeq INT NULL ,
			  BillingAddressSeq INT NULL ,
			  AttorneyType CHAR (3) NULL ,
			  Specialty1 VARCHAR (8) NULL ,
			  Specialty2 VARCHAR (8) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  Status CHAR (1) NULL ,
			  ExternalStatus CHAR (1) NULL ,
			  ExportDate DATETIME NULL ,
			  SsnTinIndicator CHAR (1) NULL ,
			  PmtDays SMALLINT NULL ,
			  AuthBeginDate DATETIME NULL ,
			  AuthEndDate DATETIME NULL ,
			  TaxAddressSeq INT NULL ,
			  CtrlNum1099 VARCHAR (4) NULL ,
			  SurchargeCode CHAR (1) NULL ,
			  WorkCompNum VARCHAR (18) NULL ,
			  WorkCompState CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Attorney ADD 
     CONSTRAINT PK_Attorney PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubSet, AttorneySeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Attorney ON src.Attorney   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.AttorneyAddress', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.AttorneyAddress
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubSet CHAR (4) NOT NULL ,
			  AttorneyAddressSeq INT NOT NULL ,
			  RecType CHAR (2) NULL ,
			  Address1 VARCHAR (30) NULL ,
			  Address2 VARCHAR (30) NULL ,
			  City VARCHAR (30) NULL ,
			  State CHAR (2) NULL ,
			  Zip VARCHAR (9) NULL ,
			  PhoneNum VARCHAR (20) NULL ,
			  FaxNum VARCHAR (20) NULL ,
			  ContactFirstName VARCHAR (20) NULL ,
			  ContactLastName VARCHAR (20) NULL ,
			  ContactMiddleInitial CHAR (1) NULL ,
			  URFirstName VARCHAR (20) NULL ,
			  URLastName VARCHAR (20) NULL ,
			  URMiddleInitial CHAR (1) NULL ,
			  FacilityName VARCHAR (30) NULL ,
			  CountryCode CHAR (3) NULL ,
			  MailCode VARCHAR (20) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.AttorneyAddress ADD 
     CONSTRAINT PK_AttorneyAddress PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubSet, AttorneyAddressSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_AttorneyAddress ON src.AttorneyAddress   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Bill', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Bill
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  ClaimSeq INT NULL ,
			  ClaimSysSubSet CHAR (4) NULL ,
			  ProviderSeq BIGINT NULL ,
			  ProviderSubSet CHAR (4) NULL ,
			  PostDate DATETIME NULL ,
			  DOSFirst DATETIME NULL ,
			  Invoiced CHAR (1) NULL ,
			  InvoicedPPO CHAR (1) NULL ,
			  CreateUserID VARCHAR (2) NULL ,
			  CarrierSeqNew VARCHAR (30) NULL ,
			  DocCtrlType CHAR (2) NULL ,
			  DOSLast DATETIME NULL ,
			  PPONetworkID CHAR (2) NULL ,
			  POS CHAR (2) NULL ,
			  ProvType CHAR (3) NULL ,
			  ProvSpecialty1 VARCHAR (8) NULL ,
			  ProvZip VARCHAR (9) NULL ,
			  ProvState CHAR (2) NULL ,
			  SubmitDate DATETIME NULL ,
			  ProvInvoice VARCHAR (14) NULL ,
			  Region SMALLINT NULL ,
			  HospitalSeq INT NULL ,
			  ModUserID VARCHAR (2) NULL ,
			  Status SMALLINT NULL ,
			  StatusPrior SMALLINT NULL ,
			  BillableLines SMALLINT NULL ,
			  TotalCharge MONEY NULL ,
			  BRReduction MONEY NULL ,
			  BRFee MONEY NULL ,
			  TotalAllow MONEY NULL ,
			  TotalFee MONEY NULL ,
			  DupClientCode CHAR (4) NULL ,
			  DupBillSeq INT NULL ,
			  FupStartDate DATETIME NULL ,
			  FupEndDate DATETIME NULL ,
			  SendBackMsg1SiteCode CHAR (3) NULL ,
			  SendBackMsg1 VARCHAR (6) NULL ,
			  SendBackMsg2SiteCode CHAR (3) NULL ,
			  SendBackMsg2 VARCHAR (6) NULL ,
			  PPOReduction MONEY NULL ,
			  PPOPrc SMALLINT NULL ,
			  PPOContractID VARCHAR (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL ,
			  PPOStatus CHAR (1) NULL ,
			  PPOFee MONEY NULL ,
			  NGDReduction MONEY NULL ,
			  NGDFee MONEY NULL ,
			  URFee MONEY NULL ,
			  OtherData VARCHAR (30) NULL ,
			  ExternalStatus CHAR (1) NULL ,
			  URFlag CHAR (1) NULL ,
			  Visits SMALLINT NULL ,
			  TOS CHAR (2) NULL ,
			  TOB CHAR (1) NULL ,
			  SubProductCode CHAR (1) NULL ,
			  ForcePay CHAR (1) NULL ,
			  PmtAuth VARCHAR (4) NULL ,
			  FlowStatus CHAR (1) NULL ,
			  ConsultDate DATETIME NULL ,
			  RcvdDate DATETIME NULL ,
			  AdmissionType CHAR (1) NULL ,
			  PaidDate DATETIME NULL ,
			  AdmitDate DATETIME NULL ,
			  DischargeDate DATETIME NULL ,
			  TxBillType CHAR (1) NULL ,
			  RcvdBrDate DATETIME NULL ,
			  DueDate DATETIME NULL ,
			  Adjuster VARCHAR (25) NULL ,
			  DOI DATETIME NULL ,
			  RetCtrlFlg CHAR (1) NULL ,
			  RetCtrlNum VARCHAR (9) NULL ,
			  SiteCode CHAR (3) NULL ,
			  SourceID CHAR (2) NULL ,
			  CaseType CHAR (1) NULL ,
			  SubProductID VARCHAR (30) NULL ,
			  SubProductPrice MONEY NULL ,
			  URReduction MONEY NULL ,
			  ProvLicenseNum VARCHAR (30) NULL ,
			  ProvMedicareNum VARCHAR (20) NULL ,
			  ProvSpecialty2 VARCHAR (8) NULL ,
			  PmtExportDate DATETIME NULL ,
			  PmtAcceptDate DATETIME NULL ,
			  ClientTOB VARCHAR (5) NULL ,
			  BRFeeNet MONEY NULL ,
			  PPOFeeNet MONEY NULL ,
			  NGDFeeNet MONEY NULL ,
			  URFeeNet MONEY NULL ,
			  SubProductPriceNet MONEY NULL ,
			  BillSeqNewRev INT NULL ,
			  BillSeqOrgRev INT NULL ,
			  VocPlanSeq SMALLINT NULL ,
			  ReviewDate DATETIME NULL ,
			  AuditDate DATETIME NULL ,
			  ReevalAllow MONEY NULL ,
			  CheckNum VARCHAR (30) NULL ,
			  NegoType CHAR (2) NULL ,
			  DischargeHour CHAR (2) NULL ,
			  UB92TOB CHAR (3) NULL ,
			  MCO VARCHAR (10) NULL ,
			  DRG CHAR (3) NULL ,
			  PatientAccount VARCHAR (20) NULL ,
			  ExaminerRevFlag CHAR (1) NULL ,
			  RefProvName VARCHAR (40) NULL ,
			  PaidAmount MONEY NULL ,
			  AdmissionSource CHAR (1) NULL ,
			  AdmitHour CHAR (2) NULL ,
			  PatientStatus CHAR (2) NULL ,
			  DRGValue MONEY NULL ,
			  CompanySeq SMALLINT NULL ,
			  TotalCoPay MONEY NULL ,
			  UB92ProcMethod CHAR (1) NULL ,
			  TotalDeductible MONEY NULL ,
			  PolicyCoPayAmount MONEY NULL ,
			  PolicyCoPayPct SMALLINT NULL ,
			  DocCtrlID VARCHAR (50) NULL ,
			  ResourceUtilGroup VARCHAR (4) NULL ,
			  PolicyDeductible MONEY NULL ,
			  PolicyLimit MONEY NULL ,
			  PolicyTimeLimit SMALLINT NULL ,
			  PolicyWarningPct SMALLINT NULL ,
			  AppBenefits CHAR (1) NULL ,
			  AppAssignee CHAR (1) NULL ,
			  CreateDate DATETIME NULL ,
			  ModDate DATETIME NULL ,
			  IncrementValue SMALLINT NULL ,
			  AdjVerifRequestDate DATETIME NULL ,
			  AdjVerifRcvdDate DATETIME NULL ,
			  RenderingProvLastName VARCHAR (35) NULL ,
			  RenderingProvFirstName VARCHAR (25) NULL ,
			  RenderingProvMiddleName VARCHAR (25) NULL ,
			  RenderingProvSuffix VARCHAR (10) NULL ,
			  RereviewCount SMALLINT NULL ,
			  DRGBilled CHAR (3) NULL ,
			  DRGCalculated CHAR (3) NULL ,
			  ProvRxLicenseNum VARCHAR (30) NULL ,
			  ProvSigOnFile CHAR (1) NULL ,
			  RefProvFirstName VARCHAR (30) NULL ,
			  RefProvMiddleName VARCHAR (25) NULL ,
			  RefProvSuffix VARCHAR (10) NULL ,
			  RefProvDEANum VARCHAR (9) NULL ,
			  SendbackMsg1Subset CHAR (2) NULL ,
			  SendbackMsg2Subset CHAR (2) NULL ,
			  PPONetworkJurisdictionInd CHAR (1) NULL ,
			  ManualReductionMode SMALLINT NULL ,
			  WholesaleSalesTaxZip VARCHAR (9) NULL ,
			  RetailSalesTaxZip VARCHAR (9) NULL ,
			  PPONetworkJurisdictionInsurerSeq INT NULL ,
			  InvoicedWholesale CHAR (1) NULL ,
			  InvoicedPPOWholesale CHAR (1) NULL ,
			  AdmittingDxRef SMALLINT NULL ,
			  AdmittingDxCode VARCHAR (8) NULL ,
			  ProvFacilityNPI VARCHAR (10) NULL ,
			  ProvBillingNPI VARCHAR (10) NULL ,
			  ProvRenderingNPI VARCHAR (10) NULL ,
			  ProvOperatingNPI VARCHAR (10) NULL ,
			  ProvReferringNPI VARCHAR (10) NULL ,
			  ProvOther1NPI VARCHAR (10) NULL ,
			  ProvOther2NPI VARCHAR (10) NULL ,
			  ProvOperatingLicenseNum VARCHAR (30) NULL ,
			  EHubID VARCHAR (50) NULL ,
			  OtherBillingProviderSubset CHAR (4) NULL ,
			  OtherBillingProviderSeq BIGINT NULL ,
			  ResubmissionReasonCode CHAR (2) NULL ,
			  ContractType CHAR (2) NULL ,
			  ContractAmount MONEY NULL ,
			  PriorAuthReferralNum1 VARCHAR (30) NULL ,
			  PriorAuthReferralNum2 VARCHAR (30) NULL ,
			  DRGCompositeFactor MONEY NULL ,
			  DRGDischargeFraction MONEY NULL ,
			  DRGInpatientMultiplier MONEY NULL ,
			  DRGWeight MONEY NULL ,
			  EFTPmtMethodCode VARCHAR (3) NULL ,
			  EFTPmtFormatCode VARCHAR (10) NULL ,
			  EFTSenderDFIID VARCHAR (27) NULL ,
			  EFTSenderAcctNum VARCHAR (50) NULL ,
			  EFTOrigCoSupplCode VARCHAR (24) NULL ,
			  EFTReceiverDFIID VARCHAR (27) NULL ,
			  EFTReceiverAcctQual VARCHAR (3) NULL ,
			  EFTReceiverAcctNum VARCHAR (50) NULL ,
			  PolicyLimitResult CHAR (1) NULL ,
			  HistoryBatchNumber INT NULL ,
			  ProvBillingTaxonomy VARCHAR (11) NULL ,
			  ProvFacilityTaxonomy VARCHAR (11) NULL ,
			  ProvRenderingTaxonomy VARCHAR (11) NULL ,
			  PPOStackList VARCHAR (30) NULL ,
			  ICDVersion SMALLINT NULL ,
			  ODGFlag SMALLINT NULL ,
			  ProvBillLicenseNum VARCHAR (30) NULL ,
			  ProvFacilityLicenseNum VARCHAR (30) NULL ,
			  ProvVendorExternalID VARCHAR (30) NULL ,
			  BRActualClientCode CHAR (4) NULL ,
			  BROverrideClientCode CHAR (4) NULL ,
			  BillReevalReasonCode VARCHAR (30) NULL ,
			  PaymentClearedDate DATETIME NULL ,
			  EstimatedBRClientCode CHAR(4) NULL ,
			  EstimatedBRJuris CHAR(2) NULL ,

			  OverrideFeeControlRetail CHAR(4) NULL ,
			  OverrideFeeControlWholesale CHAR(4) NULL ,

 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Bill ADD 
     CONSTRAINT PK_Bill PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Bill ON src.Bill   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bill')
						AND NAME = 'PaymentClearedDate' )
	BEGIN
		ALTER TABLE src.Bill ADD PaymentClearedDate DATETIME NULL ;
	END ; 
GO




IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bill')
						AND NAME = 'EstimatedBRClientCode' )
	BEGIN
		ALTER TABLE src.Bill ADD EstimatedBRClientCode CHAR(4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bill')
						AND NAME = 'EstimatedBRJuris' )
	BEGIN
		ALTER TABLE src.Bill ADD EstimatedBRJuris CHAR(2) NULL ;
	END ; 
GO



IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bill')
						AND NAME = 'OverrideFeeControlRetail' )
	BEGIN
		ALTER TABLE src.Bill ADD OverrideFeeControlRetail CHAR(4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bill')
						AND NAME = 'OverrideFeeControlWholesale' )
	BEGIN
		ALTER TABLE src.Bill ADD OverrideFeeControlWholesale CHAR(4) NULL ;
	END ; 
GO



IF OBJECT_ID('src.BillControl', 'U') IS NULL
    BEGIN
        CREATE TABLE src.BillControl
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ClientCode CHAR(4) NOT NULL,
              BillSeq INT NOT NULL,
              BillControlSeq SMALLINT NOT NULL,
              ModDate DATETIME NULL,
              CreateDate DATETIME NULL,
              Control CHAR(1) NULL,
              ExternalID VARCHAR(50) NULL,
              BatchNumber BIGINT NULL,
              ModUserID CHAR(2) NULL,
              ExternalID2 VARCHAR(50) NULL,
              Message VARCHAR(500) NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.BillControl ADD 
        CONSTRAINT PK_BillControl PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,ClientCode,BillSeq,BillControlSeq) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_BillControl ON src.BillControl REBUILD WITH(STATISTICS_INCREMENTAL = ON);

	END
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.BillControl')
                    AND c.name = 'ExternalID'
                    AND NOT ( t.name = 'VARCHAR'
                              AND c.max_length = 50
                            ) )
    BEGIN
        ALTER TABLE src.BillControl ALTER COLUMN ExternalID VARCHAR(50) NULL;
    END;
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.BillControl')
                    AND c.name = 'ExternalID2'
                    AND NOT ( t.name = 'VARCHAR'
                              AND c.max_length = 50
                            ) )
    BEGIN
        ALTER TABLE src.BillControl ALTER COLUMN ExternalID2 VARCHAR(50) NULL;
    END;
GO

IF OBJECT_ID('src.BillControlHistory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillControlHistory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BillControlHistorySeq BIGINT NOT NULL ,
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  BillControlSeq SMALLINT NOT NULL ,
			  CreateDate DATETIME NULL ,
			  Control CHAR (1) NULL ,
			  ExternalID VARCHAR (50) NULL ,
			  EDIBatchLogSeq BIGINT NULL ,
			  Deleted BIT NULL ,
			  ModUserID CHAR (2) NULL ,
			  ExternalID2 VARCHAR (50) NULL ,
			  Message VARCHAR (500) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillControlHistory ADD 
     CONSTRAINT PK_BillControlHistory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillControlHistorySeq, ClientCode, BillSeq, BillControlSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillControlHistory ON src.BillControlHistory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.BillData', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillData
			(
				OdsPostingGroupAuditId INT NOT NULL ,  
				OdsCustomerId INT NOT NULL , 
				OdsCreateDate DATETIME2(7) NOT NULL ,
				OdsSnapshotDate DATETIME2(7) NOT NULL , 
				OdsRowIsCurrent BIT NOT NULL ,
				OdsHashbytesValue VARBINARY(8000) NULL ,
				DmlOperation CHAR(1) NOT NULL , 
				ClientCode CHAR(4) NOT NULL,
				BillSeq INT NOT NULL,
				TypeCode CHAR(6) NOT NULL,
				SubType CHAR(12) NOT NULL,
				SubSeq SMALLINT NOT NULL,
				NumData NUMERIC(18, 6) NULL,
				TextData VARCHAR(6000) NULL,
				ModDate DATETIME NULL,
				ModUserID CHAR(2) NULL,
				CreateDate DATETIME NULL,
				CreateUserID CHAR(2) NULL,

 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillData ADD 
     CONSTRAINT PK_BillData PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, TypeCode, SubType, SubSeq ) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillData ON src.BillData   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO


IF OBJECT_ID('src.BillFee', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillFee
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  FeeType CHAR (1) NOT NULL ,
			  TransactionType CHAR (6) NOT NULL ,
			  FeeCtrlSource CHAR (1) NULL ,
			  FeeControlSeq INT NULL ,
			  FeeAmount MONEY NULL ,
			  InvoiceSeq BIGINT NULL ,
			  InvoiceSubSeq SMALLINT NULL ,
			  PPONetworkID CHAR (2) NULL ,
			  ReductionCode SMALLINT NULL ,
			  FeeOverride CHAR (1) NULL ,
			  OverrideVerified CHAR (1) NULL ,
			  ExclusiveFee CHAR (1) NULL ,
			  FeeSourceID VARCHAR (20) NULL ,
			  HandlingFee CHAR (1) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillFee ADD 
     CONSTRAINT PK_BillFee PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, FeeType, TransactionType) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillFee ON src.BillFee   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.BillICD', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillICD
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  BillICDSeq SMALLINT NOT NULL ,
			  CodeType CHAR (1) NOT NULL ,
			  ICDCode VARCHAR (8) NULL ,
			  CodeDate DATETIME NULL ,
			  POA CHAR (1) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillICD ADD 
     CONSTRAINT PK_BillICD PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, BillICDSeq, CodeType) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillICD ON src.BillICD   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.BillICDDiagnosis', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillICDDiagnosis
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  BillDiagnosisSeq SMALLINT NOT NULL ,
			  ICDDiagnosisID INT NULL ,
			  POA CHAR (1) NULL ,
			  BilledICDDiagnosis CHAR (8) NULL ,
			  ICDBillUsageTypeID SMALLINT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillICDDiagnosis ADD 
     CONSTRAINT PK_BillICDDiagnosis PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, BillDiagnosisSeq, ICDBillUsageTypeID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillICDDiagnosis ON src.BillICDDiagnosis   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.BillICDProcedure', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillICDProcedure
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  BillProcedureSeq SMALLINT NOT NULL ,
			  ICDProcedureID INT NULL ,
			  CodeDate DATETIME NULL ,
			  BilledICDProcedure CHAR (8) NULL ,
			  ICDBillUsageTypeID SMALLINT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillICDProcedure ADD 
     CONSTRAINT PK_BillICDProcedure PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, BillProcedureSeq, ICDBillUsageTypeID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillICDProcedure ON src.BillICDProcedure   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.BillPPORate', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillPPORate
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  LinkName VARCHAR (12) NOT NULL ,
			  RateType VARCHAR (8) NOT NULL ,
			  Applied CHAR (1) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillPPORate ADD 
     CONSTRAINT PK_BillPPORate PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, LinkName, RateType) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillPPORate ON src.BillPPORate   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.BillProvider', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillProvider
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  BillProviderSeq INT NOT NULL ,
			  Qualifier CHAR (2) NULL ,
			  LastName VARCHAR (40) NULL ,
			  FirstName VARCHAR (30) NULL ,
			  MiddleName VARCHAR (25) NULL ,
			  Suffix VARCHAR (10) NULL ,
			  NPI VARCHAR (10) NULL ,
			  LicenseNum VARCHAR (30) NULL ,
			  DEANum VARCHAR (9) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillProvider ADD 
     CONSTRAINT PK_BillProvider PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, BillProviderSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillProvider ON src.BillProvider   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.BillReevalReason', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillReevalReason
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BillReevalReasonCode VARCHAR (30) NOT NULL ,
			  SiteCode CHAR (3) NOT NULL ,
			  BillReevalReasonCategorySeq INT NULL ,
			  ShortDescription VARCHAR (40) NULL ,
			  LongDescription VARCHAR (255) NULL ,
			  Active BIT NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillReevalReason ADD 
     CONSTRAINT PK_BillReevalReason PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillReevalReasonCode, SiteCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillReevalReason ON src.BillReevalReason   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.BillRuleFire', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillRuleFire
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  LineSeq SMALLINT NOT NULL ,
			  RuleID CHAR (5) NOT NULL ,
			  RuleType CHAR (1) NULL ,
			  DateRuleFired DATETIME NULL ,
			  Validated CHAR (1) NULL ,
			  ValidatedUserID CHAR (2) NULL ,
			  DateValidated DATETIME NULL ,
			  PendToID VARCHAR (13) NULL ,
			  RuleSeverity CHAR (1) NULL ,
			  WFTaskSeq INT NULL ,
			  ChildTargetSubset VARCHAR (4) NOT NULL ,
			  ChildTargetSeq INT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillRuleFire ADD 
     CONSTRAINT PK_BillRuleFire PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, LineSeq, RuleID, ChildTargetSubset, ChildTargetSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillRuleFire ON src.BillRuleFire   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Branch', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Branch
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubSet CHAR (4) NOT NULL ,
			  BranchSeq INT NOT NULL ,
			  Name VARCHAR (60) NULL ,
			  ExternalID VARCHAR (20) NULL ,
			  BranchID VARCHAR (20) NULL ,
			  LocationCode VARCHAR (10) NULL ,
			  AdminKey VARCHAR (40) NULL ,
			  Address1 VARCHAR (30) NULL ,
			  Address2 VARCHAR (30) NULL ,
			  City VARCHAR (20) NULL ,
			  State CHAR (2) NULL ,
			  Zip VARCHAR (9) NULL ,
			  PhoneNum VARCHAR (20) NULL ,
			  FaxNum VARCHAR (20) NULL ,
			  ContactName VARCHAR (30) NULL ,
			  TIN VARCHAR (9) NULL ,
			  StateTaxID VARCHAR (30) NULL ,
			  DIRNum VARCHAR (20) NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  RuleFire VARCHAR (4) NULL ,
			  FeeRateCntrlEx VARCHAR (4) NULL ,
			  FeeRateCntrlIn VARCHAR (4) NULL ,
			  SalesTaxExempt CHAR (1) NULL ,
			  EffectiveDate DATETIME NULL ,
			  TerminationDate DATETIME NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Branch ADD 
     CONSTRAINT PK_Branch PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubSet, BranchSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Branch ON src.Branch   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.BRERuleCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BRERuleCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BRERuleCategoryID VARCHAR (30) NOT NULL ,
			  CategoryDescription VARCHAR (500) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BRERuleCategory ADD 
     CONSTRAINT PK_BRERuleCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BRERuleCategoryID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BRERuleCategory ON src.BRERuleCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.CityStateZip', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.CityStateZip
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ZipCode CHAR (5) NOT NULL ,
			  CtyStKey CHAR (6) NOT NULL ,
			  CpyDtlCode CHAR (1) NULL ,
			  ZipClsCode CHAR (1) NULL ,
			  CtyStName VARCHAR (28) NULL ,
			  CtyStNameAbv VARCHAR (13) NULL ,
			  CtyStFacCode CHAR (1) NULL ,
			  CtyStMailInd CHAR (1) NULL ,
			  PreLstCtyKey VARCHAR (6) NULL ,
			  PreLstCtyNme VARCHAR (28) NULL ,
			  CtyDlvInd CHAR (1) NULL ,
			  AutZoneInd CHAR (1) NULL ,
			  UnqZipInd CHAR (1) NULL ,
			  FinanceNum VARCHAR (6) NULL ,
			  StateAbbrv CHAR (2) NULL ,
			  CountyNum CHAR (3) NULL ,
			  CountyName VARCHAR (25) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.CityStateZip ADD 
     CONSTRAINT PK_CityStateZip PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ZipCode, CtyStKey) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_CityStateZip ON src.CityStateZip   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Claim', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Claim
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubSet CHAR (4) NOT NULL ,
			  ClaimSeq INT NOT NULL ,
			  ClaimID VARCHAR (35) NULL ,
			  DOI DATETIME NULL ,
			  PatientSSN VARCHAR (9) NULL ,
			  PatientFirstName VARCHAR (10) NULL ,
			  PatientLastName VARCHAR (20) NULL ,
			  PatientMInitial CHAR (1) NULL ,
			  ExternalClaimID VARCHAR (35) NULL ,
			  PolicyCoPayAmount MONEY NULL ,
			  PolicyCoPayPct SMALLINT NULL ,
			  PolicyDeductible MONEY NULL ,
			  Status CHAR (1) NULL ,
			  PolicyLimit MONEY NULL ,
			  PolicyID VARCHAR (30) NULL ,
			  PolicyTimeLimit SMALLINT NULL ,
			  Adjuster VARCHAR (25) NULL ,
			  PolicyLimitWarningPct SMALLINT NULL ,
			  FirstDOS DATETIME NULL ,
			  LastDOS DATETIME NULL ,
			  LoadDate DATETIME NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  PatientSex CHAR (1) NULL ,
			  PatientCity VARCHAR (20) NULL ,
			  PatientDOB DATETIME NULL ,
			  PatientStreet2 VARCHAR (30) NULL ,
			  PatientState CHAR (2) NULL ,
			  PatientZip VARCHAR (9) NULL ,
			  PatientStreet1 VARCHAR (30) NULL ,
			  MMIDate DATETIME NULL ,
			  BodyPart1 CHAR (3) NULL ,
			  BodyPart2 CHAR (3) NULL ,
			  BodyPart3 CHAR (3) NULL ,
			  BodyPart4 CHAR (3) NULL ,
			  BodyPart5 CHAR (3) NULL ,
			  Location VARCHAR (10) NULL ,
			  NatureInj CHAR (3) NULL ,
			  URFlag CHAR (1) NULL ,
			  CarKnowDate DATETIME NULL ,
			  ClaimType CHAR (2) NULL ,
			  CtrlDay SMALLINT NULL ,
			  MCOChoice CHAR (2) NULL ,
			  ClientCodeDefault VARCHAR (4) NULL ,
			  CloseDate DATETIME NULL ,
			  ReopenDate DATETIME NULL ,
			  MedCloseDate DATETIME NULL ,
			  MedStipDate DATETIME NULL ,
			  LegalStatus1 CHAR (2) NULL ,
			  LegalStatus2 CHAR (2) NULL ,
			  LegalStatus3 CHAR (2) NULL ,
			  Jurisdiction CHAR (2) NULL ,
			  ProductCode CHAR (1) NULL ,
			  PlaintiffAttorneySeq BIGINT NULL ,
			  DefendantAttorneySeq BIGINT NULL ,
			  BranchID VARCHAR (20) NULL ,
			  OccCode CHAR (2) NULL ,
			  ClaimSeverity CHAR (2) NULL ,
			  DateLostBegan DATETIME NULL ,
			  AccidentEmployment CHAR (1) NULL ,
			  RelationToInsured CHAR (1) NULL ,
			  Policy5Days CHAR (2) NULL ,
			  Policy90Days CHAR (2) NULL ,
			  Job5Days CHAR (2) NULL ,
			  Job90Days CHAR (2) NULL ,
			  LostDays SMALLINT NULL ,
			  ActualRTWDate DATETIME NULL ,
			  MCOTransInd CHAR (2) NULL ,
			  QualifiedInjWorkInd CHAR (2) NULL ,
			  PermStationaryInd CHAR (2) NULL ,
			  HospitalAdmit CHAR (2) NULL ,
			  QualifiedInjWorkDate DATETIME NULL ,
			  RetToWorkDate DATETIME NULL ,
			  PermStationaryDate DATETIME NULL ,
			  MCOFein VARCHAR (9) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  IDCode VARCHAR (80) NULL ,
			  IDType VARCHAR (2) NULL ,
			  MPNOptOutEffectiveDate DATETIME NULL ,
			  MPNOptOutTerminationDate DATETIME NULL ,
			  MPNOptOutPhysicianName VARCHAR (50) NULL ,
			  MPNOptOutPhysicianTIN VARCHAR (9) NULL ,
			  MPNChoice CHAR (2) NULL ,
			  JurisdictionClaimID VARCHAR (35) NULL ,
			  PolicyLimitResult CHAR (1) NULL ,
			  PatientPrimaryPhone VARCHAR (20) NULL ,
			  PatientWorkPhone VARCHAR (20) NULL ,
			  PatientAlternatePhone VARCHAR (20) NULL ,
			  ICDVersion SMALLINT NULL ,
			  LastDateofTrauma DATETIME NULL ,
			  ClaimAdminClaimNum VARCHAR (35) NULL ,
			  PatientCountryCode CHAR (3) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Claim ADD 
     CONSTRAINT PK_Claim PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubSet, ClaimSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Claim ON src.Claim   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ClaimData', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClaimData
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubset CHAR (4) NOT NULL ,
			  ClaimSeq INT NOT NULL ,
			  TypeCode CHAR (6) NOT NULL ,
			  SubType CHAR (12) NOT NULL ,
			  SubSeq SMALLINT NOT NULL ,
			  NumData NUMERIC (18,6) NULL ,
			  TextData VARCHAR (6000) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClaimData ADD 
     CONSTRAINT PK_ClaimData PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubset, ClaimSeq, TypeCode, SubType, SubSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClaimData ON src.ClaimData   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ClaimDiag', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClaimDiag
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubSet CHAR (4) NOT NULL ,
			  ClaimSeq INT NOT NULL ,
			  ClaimDiagSeq SMALLINT NOT NULL ,
			  DiagCode VARCHAR (8) NULL ,
			 
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClaimDiag ADD 
     CONSTRAINT PK_ClaimDiag PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubSet, ClaimSeq, ClaimDiagSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClaimDiag ON src.ClaimDiag   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO


IF OBJECT_ID('src.ClaimICDDiagnosis', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClaimICDDiagnosis
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubSet CHAR (4) NOT NULL ,
			  ClaimSeq INT NOT NULL ,
			  ClaimDiagnosisSeq SMALLINT NOT NULL ,
			  ICDDiagnosisID INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClaimICDDiagnosis ADD 
     CONSTRAINT PK_ClaimICDDiagnosis PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubSet, ClaimSeq, ClaimDiagnosisSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClaimICDDiagnosis ON src.ClaimICDDiagnosis   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ClaimSys', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClaimSys
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubset CHAR (4) NOT NULL ,
			  ClaimIDMask VARCHAR (35) NULL ,
			  ClaimAccess CHAR (1) NULL ,
			  ClaimSysDesc VARCHAR (30) NULL ,
			  PolicyholderReq CHAR (1) NULL ,
			  ValidateBranch CHAR (1) NULL ,
			  ValidatePolicy CHAR (1) NULL ,
			  LglCode1TableCode CHAR (2) NULL ,
			  LglCode2TableCode CHAR (2) NULL ,
			  LglCode3TableCode CHAR (2) NULL ,
			  UROccTableCode CHAR (2) NULL ,
			  Policy5DaysTableCode CHAR (2) NULL ,
			  Policy90DaysTableCode CHAR (2) NULL ,
			  Job5DaysTableCode CHAR (2) NULL ,
			  Job90DaysTableCode CHAR (2) NULL ,
			  HCOTransIndTableCode CHAR (2) NULL ,
			  QualifiedInjWorkTableCode CHAR (2) NULL ,
			  PermStationaryTableCode CHAR (2) NULL ,
			  ValidateAdjuster CHAR (1) NULL ,
			  MCOProgram CHAR (1) NULL ,
			  AdjusterRequired CHAR (1) NULL ,
			  HospitalAdmitTableCode CHAR (2) NULL ,
			  AttorneyTaxAddrRequired CHAR (1) NULL ,
			  BodyPartTableCode CHAR (2) NULL ,
			  PolicyDefaults CHAR (1) NULL ,
			  PolicyCoPayAmount MONEY NULL ,
			  PolicyCoPayPct SMALLINT NULL ,
			  PolicyDeductible MONEY NULL ,
			  PolicyLimit MONEY NULL ,
			  PolicyTimeLimit SMALLINT NULL ,
			  PolicyLimitWarningPct SMALLINT NULL ,
			  RestrictUserAccess CHAR (1) NULL ,
			  BEOverridePermissionFlag CHAR (1) NULL ,
			  RootClaimLength SMALLINT NULL ,
			  RelateClaimsTotalPolicyDetail CHAR (1) NULL ,
			  PolicyLimitResult CHAR (1) NULL ,
			  EnableClaimClientCodeDefault CHAR (1) NULL ,
			  ReevalCopyDocCtrlID CHAR (1) NULL ,
			  EnableCEPHeaderFieldEdits CHAR (1) NULL ,
			  EnableSmartClientSelection CHAR (1) NULL ,
			  SCSClientSelectionCode CHAR (12) NULL ,
			  SCSProviderSubset CHAR (4) NULL ,
			  SCSClientCodeMask CHAR (4) NULL ,
			  SCSDefaultClient CHAR (4) NULL ,
			  ClaimExternalIDasCarrierClaimID CHAR (1) NULL ,
			  PolicyExternalIDasCarrierPolicyID CHAR (1) NULL ,
			  URProfileID VARCHAR (8) NULL ,
			  BEUROverridesRequireReviewRef CHAR (1) NULL ,
			  UREntryValidations CHAR (1) NULL ,
			  PendPPOEDIControl CHAR (1) NULL ,
			  BEReevalLineAddDelete CHAR (1) NULL ,
			  CPTGroupToIndividual CHAR (1) NULL ,
			  ClaimExternalIDasClaimAdminClaimNum CHAR (1) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  FinancialAggregation XML NULL ,

 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClaimSys ADD 
     CONSTRAINT PK_ClaimSys PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubset) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClaimSys ON src.ClaimSys   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.ClaimSys')
						AND NAME = 'FinancialAggregation' )
	BEGIN
		ALTER TABLE src.ClaimSys ADD FinancialAggregation XML NULL ;
	END ; 
GO



IF OBJECT_ID('src.ClaimSysData', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClaimSysData
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubset CHAR (4) NOT NULL ,
			  TypeCode CHAR (6) NOT NULL ,
			  SubType CHAR (12) NOT NULL ,
			  SubSeq SMALLINT NOT NULL ,
			  NumData NUMERIC (18,6) NULL ,
			  TextData VARCHAR (6000) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClaimSysData ADD 
     CONSTRAINT PK_ClaimSysData PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubset, TypeCode, SubType, SubSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClaimSysData ON src.ClaimSysData   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Client', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Client
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  Name VARCHAR (30) NULL ,
			  Jurisdiction CHAR (2) NULL ,
			  ControlNum VARCHAR (20) NULL ,
			  PolicyTimeLimit SMALLINT NULL ,
			  PolicyLimitWarningPct SMALLINT NULL ,
			  PolicyLimit MONEY NULL ,
			  PolicyDeductible MONEY NULL ,
			  PolicyCoPayPct SMALLINT NULL ,
			  PolicyCoPayAmount MONEY NULL ,
			  BEDiagnosis CHAR (1) NULL ,
			  InvoiceBRCycle CHAR (1) NULL ,
			  Status CHAR (1) NULL ,
			  InvoiceGroupBy CHAR (1) NULL ,
			  BEDOI CHAR (1) NULL ,
			  DrugMarkUpBrand SMALLINT NULL ,
			  SupplyLimit SMALLINT NULL ,
			  InvoicePPOCycle CHAR (1) NULL ,
			  InvoicePPOTax SMALLINT NULL ,
			  DrugMarkUpGen SMALLINT NULL ,
			  DrugDispGen SMALLINT NULL ,
			  DrugDispBrand SMALLINT NULL ,
			  BEAdjuster CHAR (1) NULL ,
			  InvoiceTax SMALLINT NULL ,
			  CompanySeq SMALLINT NULL ,
			  BEMedAlert CHAR (1) NULL ,
			  UCRPercentile SMALLINT NULL ,
			  ClientComment VARCHAR (6000) NULL ,
			  RemitAttention VARCHAR (30) NULL ,
			  RemitAddress1 VARCHAR (30) NULL ,
			  RemitAddress2 VARCHAR (30) NULL ,
			  RemitCityStateZip VARCHAR (30) NULL ,
			  RemitPhone VARCHAR (12) NULL ,
			  ExternalID VARCHAR (10) NULL ,
			  BEOther CHAR (1) NULL ,
			  MedAlertDays SMALLINT NULL ,
			  MedAlertVisits SMALLINT NULL ,
			  MedAlertMaxCharge MONEY NULL ,
			  MedAlertWarnVisits SMALLINT NULL ,
			  ProviderSubSet CHAR (4) NULL ,
			  AllowReReview CHAR (1) NULL ,
			  AcctRep CHAR (2) NULL ,
			  ClientType CHAR (1) NULL ,
			  UCRMarkUp SMALLINT NULL ,
			  InvoiceCombined CHAR (1) NULL ,
			  BESubmitDt CHAR (1) NULL ,
			  BERcvdCarrierDate CHAR (1) NULL ,
			  BERcvdBillReviewDate CHAR (1) NULL ,
			  BEDueDate CHAR (1) NULL ,
			  ProductCode CHAR (1) NULL ,
			  BEProvInvoice CHAR (1) NULL ,
			  ClaimSysSubSet CHAR (4) NULL ,
			  DefaultBRtoUCR CHAR (1) NULL ,
			  BasePPOFeesOffFS CHAR (1) NULL ,
			  BEClientTOBTableCode CHAR (2) NULL ,
			  BEForcePay CHAR (1) NULL ,
			  BEPayAuthorization CHAR (1) NULL ,
			  BECarrierSeqFlag CHAR (1) NULL ,
			  BEProvTypeTableCode CHAR (2) NULL ,
			  BEProvSpcl1TableCode CHAR (2) NULL ,
			  BEProvLicense CHAR (1) NULL ,
			  BEPayAuthTableCode CHAR (2) NULL ,
			  PendReasonTableCode CHAR (2) NULL ,
			  VocRehab CHAR (1) NULL ,
			  EDIAckRequired CHAR (1) NULL ,
			  StateRptInd CHAR (1) NULL ,
			  BEPatientAcctNum CHAR (1) NULL ,
			  AutoDup CHAR (1) NULL ,
			  UseAllowOnDup CHAR (1) NULL ,
			  URImportUsed CHAR (1) NULL ,
			  URProgStartDate CHAR (1) NULL ,
			  URImportCtrlNum CHAR (4) NULL ,
			  URImportCtrlGroup CHAR (4) NULL ,
			  UCRSource CHAR (1) NULL ,
			  UCRMarkup2 SMALLINT NULL ,
			  NGDTableCode CHAR (2) NULL ,
			  BESubProductTableCode CHAR (2) NULL ,
			  CountryTableCode CHAR (2) NULL ,
			  BERefPhys CHAR (1) NULL ,
			  BEPmtWarnDays SMALLINT NULL ,
			  GeoState CHAR (2) NULL ,
			  BEDisableDOICheck CHAR (1) NULL ,
			  DelayDays SMALLINT NULL ,
			  BEValidateTotal CHAR (1) NULL ,
			  BEFastMatch CHAR (1) NULL ,
			  BEPriorBillDefault CHAR (1) NULL ,
			  BEClientDueDays SMALLINT NULL ,
			  BEAutoCalcDueDate CHAR (1) NULL ,
			  UCRSource2 CHAR (1) NULL ,
			  UCRPercentile2 SMALLINT NULL ,
			  BEProvSpcl2TableCode CHAR (2) NULL ,
			  FeeRateCntrlEx CHAR (4) NULL ,
			  FeeRateCntrlIn CHAR (4) NULL ,
			  BECollisionProvBills CHAR (1) NULL ,
			  BECollisionBills CHAR (1) NULL ,
			  SupplyMarkup SMALLINT NULL ,
			  BECollisionProviders CHAR (1) NULL ,
			  DefaultCoPayDeduct CHAR (1) NULL ,
			  AutoBundling CHAR (1) NULL ,
			  BEValidateBillClaimICD9 CHAR (1) NULL ,
			  EnableGenericReprice CHAR (1) NULL ,
			  BESubProdFeeInfo CHAR (1) NULL ,
			  DenyNonInjDrugs CHAR (1) NULL ,
			  BECollisionDosLines CHAR (1) NULL ,
			  PPOProfileSiteCode CHAR (3) NULL ,
			  PPOProfileID INT NULL ,
			  BEShowDEAWarning CHAR (1) NULL ,
			  BEHideAdjusterColumn CHAR (1) NULL ,
			  BEHideCoPayColumn CHAR (1) NULL ,
			  BEHideDeductColumn CHAR (1) NULL ,
			  BEPaidDate CHAR (1) NULL ,
			  BEProcCrossWalk CHAR (1) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  BEConsultDate CHAR (1) NULL ,
			  BEShowPharmacyColumns CHAR (1) NULL ,
			  BEAdjVerifDates CHAR (1) NULL ,
			  FutureDOSMonthLimit SMALLINT NULL ,
			  BEStopAtLineUnits CHAR (1) NULL ,
			  BENYNF10Fields CHAR (1) NULL ,
			  EnableDRGGrouper CHAR (1) NULL ,
			  ApplyCptAmaUcrRules CHAR (1) NULL ,
			  BEProvSigOnFile CHAR (1) NULL ,
			  BETimeEntry CHAR (1) NULL ,
			  SalesTaxExempt CHAR (1) NULL ,
			  InvoiceRetailProfile CHAR (4) NULL ,
			  InvoiceWholesaleProfile CHAR (4) NULL ,
			  BEDefaultTaxZip CHAR (1) NULL ,
			  ReceiptHandlingCode CHAR (1) NULL ,
			  PaymentHandlingCode CHAR (1) NULL ,
			  DefaultRetailSalesTaxZip VARCHAR (9) NULL ,
			  DefaultWholesaleSalesTaxZip VARCHAR (9) NULL ,
			  TxNonSubscrib CHAR (1) NULL ,
			  RootClaimLength SMALLINT NULL ,
			  BEDAWTableCode VARCHAR (4) NULL ,
			  EORProfileSeq INT NULL ,
			  BEOtherBillingProvider CHAR (1) NULL ,
			  BEDocCtrlID CHAR (1) NULL ,
			  ReportingETL CHAR (1) NULL ,
			  ClaimVerification CHAR (1) NULL ,
			  ProvVerification CHAR (1) NULL ,
			  BEPermitAllowOver CHAR (1) NULL ,
			  BEStopAtLineDxRef CHAR (1) NULL ,
			  BEQuickInfoCode CHAR (12) NULL ,
			  ExcludedSmartClientSelect CHAR (1) NULL ,
			  CollisionsSearchBy CHAR (1) NULL ,
			  AutoDupIncludeProv CHAR (1) NULL ,
			  URProfileID VARCHAR (8) NULL ,
			  ExcludeURDM CHAR (1) NULL ,
			  BECollisionURCases CHAR (1) NULL ,
			  MUEEdits CHAR (1) NULL ,
			  CPTRarity NUMERIC (5,2) NULL ,
			  ICDRarity NUMERIC (5,2) NULL ,
			  ICDToCPTRarity NUMERIC (5,2) NULL ,
			  BEDisablePPOSearch CHAR (1) NULL ,
			  BEShowLineExternalIDColumn CHAR (1) NULL ,
			  BEShowLinePriorAuthColumn CHAR (1) NULL ,
			  SmartGuidelinesFlag CHAR (1) NULL ,
			  BEProvBillingLicense CHAR (1) NULL ,
			  BEProvFacilityLicense CHAR (1) NULL ,
			  VendorProviderSubSet CHAR (4) NULL ,
			  DefaultJurisClientCode CHAR (1) NULL ,

 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Client ADD 
     CONSTRAINT PK_Client PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Client ON src.Client   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO

 IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Client')
						AND NAME = 'ClientGroupId' )
	BEGIN
		ALTER TABLE src.Client ADD ClientGroupId INT NULL ;
	END ; 
GO
IF OBJECT_ID('src.ClientData', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClientData
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  TypeCode CHAR (6) NOT NULL ,
			  SubType CHAR (12) NOT NULL ,
			  SubSeq SMALLINT NOT NULL ,
			  NumData NUMERIC (18,6) NULL ,
			  TextData VARCHAR (6000) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClientData ADD 
     CONSTRAINT PK_ClientData PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, TypeCode, SubType, SubSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClientData ON src.ClientData   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ClientInsurer', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClientInsurer
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  InsurerType CHAR (1) NOT NULL ,
			  EffectiveDate DATETIME NOT NULL ,
			  InsurerSeq INT NULL ,
			  TerminationDate DATETIME NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClientInsurer ADD 
     CONSTRAINT PK_ClientInsurer PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, InsurerType, EffectiveDate) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClientInsurer ON src.ClientInsurer   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Drugs', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Drugs
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  DrugCode CHAR (4) NOT NULL ,
			  DrugsDescription VARCHAR (20) NULL ,
			  Disp VARCHAR (20) NULL ,
			  DrugType CHAR (1) NULL ,
			  Cat CHAR (1) NULL ,
			  UpdateFlag CHAR (1) NULL ,
			  Uv INT NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Drugs ADD 
     CONSTRAINT PK_Drugs PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, DrugCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Drugs ON src.Drugs   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.EDIXmit', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.EDIXmit
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  EDIXmitSeq INT NOT NULL ,
			  FileSpec VARCHAR (8000) NULL ,
			  FileLocation VARCHAR (255) NULL ,
			  RecommendedPayment MONEY NULL ,
			  UserID CHAR (2) NULL ,
			  XmitDate DATETIME NULL ,
			  DateFrom DATETIME NULL ,
			  DateTo DATETIME NULL ,
			  EDIType CHAR (1) NULL ,
			  EDIPartnerID CHAR (3) NULL ,
			  DBVersion VARCHAR (20) NULL ,
			  EDIMapToolSiteCode CHAR (3) NULL ,
			  EDIPortType CHAR (1) NULL ,
			  EDIMapToolID INT NULL ,
			  TransmissionStatus CHAR (1) NULL ,
			  BatchNumber INT NULL ,
			  SenderID VARCHAR (20) NULL ,
			  ReceiverID VARCHAR (20) NULL ,
			  ExternalBatchID VARCHAR (50) NULL ,
			  SARelatedBatchID BIGINT NULL ,
			  AckNoteCode CHAR (3) NULL ,
			  AckNote VARCHAR (50) NULL ,
			  ExternalBatchDate DATETIME NULL ,
			  UserNotes VARCHAR (1000) NULL ,
			  ResubmitDate DATETIME NULL ,
			  ResubmitUserID VARCHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID VARCHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.EDIXmit ADD 
     CONSTRAINT PK_EDIXmit PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, EDIXmitSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_EDIXmit ON src.EDIXmit   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.EntityType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.EntityType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  EntityTypeID INT NOT NULL ,
			  EntityTypeKey NVARCHAR (250) NULL ,
			  Description NVARCHAR (MAX) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.EntityType ADD 
     CONSTRAINT PK_EntityType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, EntityTypeID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_EntityType ON src.EntityType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.FSProcedure', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.FSProcedure
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Jurisdiction CHAR (2) NOT NULL ,
			  Extension CHAR (3) NOT NULL ,
			  ProcedureCode CHAR (6) NOT NULL ,
			  FSProcDescription VARCHAR (24) NULL ,
			  Sv CHAR (1) NULL ,
			  Star CHAR (1) NULL ,
			  Panel CHAR (1) NULL ,
			  Ip CHAR (1) NULL ,
			  Mult CHAR (1) NULL ,
			  AsstSurgeon CHAR (1) NULL ,
			  SectionFlag CHAR (1) NULL ,
			  Fup CHAR (3) NULL ,
			  Bav SMALLINT NULL ,
			  ProcGroup CHAR (4) NULL ,
			  ViewType SMALLINT NULL ,
			  UnitValue1 MONEY NULL ,
			  UnitValue2 MONEY NULL ,
			  UnitValue3 MONEY NULL ,
			  UnitValue4 MONEY NULL ,
			  UnitValue5 MONEY NULL ,
			  UnitValue6 MONEY NULL ,
			  UnitValue7 MONEY NULL ,
			  UnitValue8 MONEY NULL ,
			  UnitValue9 MONEY NULL ,
			  UnitValue10 MONEY NULL ,
			  UnitValue11 MONEY NULL ,
			  UnitValue12 MONEY NULL ,
			  ProUnitValue1 MONEY NULL ,
			  ProUnitValue2 MONEY NULL ,
			  ProUnitValue3 MONEY NULL ,
			  ProUnitValue4 MONEY NULL ,
			  ProUnitValue5 MONEY NULL ,
			  ProUnitValue6 MONEY NULL ,
			  ProUnitValue7 MONEY NULL ,
			  ProUnitValue8 MONEY NULL ,
			  ProUnitValue9 MONEY NULL ,
			  ProUnitValue10 MONEY NULL ,
			  ProUnitValue11 MONEY NULL ,
			  ProUnitValue12 MONEY NULL ,
			  TechUnitValue1 MONEY NULL ,
			  TechUnitValue2 MONEY NULL ,
			  TechUnitValue3 MONEY NULL ,
			  TechUnitValue4 MONEY NULL ,
			  TechUnitValue5 MONEY NULL ,
			  TechUnitValue6 MONEY NULL ,
			  TechUnitValue7 MONEY NULL ,
			  TechUnitValue8 MONEY NULL ,
			  TechUnitValue9 MONEY NULL ,
			  TechUnitValue10 MONEY NULL ,
			  TechUnitValue11 MONEY NULL ,
			  TechUnitValue12 MONEY NULL ,
			  SiteCode CHAR (3) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.FSProcedure ADD 
     CONSTRAINT PK_FSProcedure PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Jurisdiction, Extension, ProcedureCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_FSProcedure ON src.FSProcedure   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.FSProcedureMV', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.FSProcedureMV
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Jurisdiction CHAR (2) NOT NULL ,
			  Extension CHAR (3) NOT NULL ,
			  ProcedureCode CHAR (6) NOT NULL ,
			  EffectiveDate DATETIME NOT NULL ,
			  TerminationDate DATETIME NULL ,
			  FSProcDescription VARCHAR (24) NULL ,
			  Sv CHAR (1) NULL ,
			  Star CHAR (1) NULL ,
			  Panel CHAR (1) NULL ,
			  Ip CHAR (1) NULL ,
			  Mult CHAR (1) NULL ,
			  AsstSurgeon CHAR (1) NULL ,
			  SectionFlag CHAR (1) NULL ,
			  Fup CHAR (3) NULL ,
			  Bav SMALLINT NULL ,
			  ProcGroup CHAR (4) NULL ,
			  ViewType SMALLINT NULL ,
			  UnitValue MONEY NULL ,
			  ProUnitValue MONEY NULL ,
			  TechUnitValue MONEY NULL ,
			  SiteCode CHAR (3) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.FSProcedureMV ADD 
     CONSTRAINT PK_FSProcedureMV PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Jurisdiction, Extension, ProcedureCode, EffectiveDate) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_FSProcedureMV ON src.FSProcedureMV   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.FSServiceCode', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.FSServiceCode
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Jurisdiction CHAR (2) NOT NULL ,
			  ServiceCode VARCHAR (30) NOT NULL ,
			  GeoAreaCode VARCHAR (12) NOT NULL ,
			  EffectiveDate DATETIME NOT NULL ,
			  Description VARCHAR (255) NULL ,
			  TermDate DATETIME NULL ,
			  CodeSource VARCHAR (6) NULL ,
			  CodeGroup VARCHAR (12) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.FSServiceCode ADD 
     CONSTRAINT PK_FSServiceCode PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Jurisdiction, ServiceCode, GeoAreaCode, EffectiveDate) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_FSServiceCode ON src.FSServiceCode   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ICD_Diagnosis', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ICD_Diagnosis
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ICDDiagnosisID INT NOT NULL ,
			  Code CHAR (8) NULL ,
			  ShortDesc VARCHAR (60) NULL ,
			  Description VARCHAR (300) NULL ,
			  Detailed BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ICD_Diagnosis ADD 
     CONSTRAINT PK_ICD_Diagnosis PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ICDDiagnosisID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ICD_Diagnosis ON src.ICD_Diagnosis   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Insurer', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Insurer
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  InsurerType CHAR (1) NOT NULL ,
			  InsurerSeq INT NOT NULL ,
			  Jurisdiction CHAR (2) NULL ,
			  StateID VARCHAR (30) NULL ,
			  TIN VARCHAR (9) NULL ,
			  AltID VARCHAR (18) NULL ,
			  Name VARCHAR (30) NULL ,
			  Address1 VARCHAR (30) NULL ,
			  Address2 VARCHAR (30) NULL ,
			  City VARCHAR (20) NULL ,
			  State CHAR (2) NULL ,
			  Zip VARCHAR (9) NULL ,
			  PhoneNum VARCHAR (20) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  FaxNum VARCHAR (20) NULL ,
			  NAICCoCode VARCHAR (6) NULL ,
			  NAICGpCode VARCHAR (30) NULL ,
			  NCCICarrierCode VARCHAR (5) NULL ,
			  NCCIGroupCode VARCHAR (5) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Insurer ADD 
     CONSTRAINT PK_Insurer PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, InsurerType, InsurerSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Insurer ON src.Insurer   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Jurisdiction', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Jurisdiction
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  JurisdictionID CHAR (2) NOT NULL ,
			  Name VARCHAR (30) NULL ,
			  POSTableCode CHAR (2) NULL ,
			  TOSTableCode CHAR (2) NULL ,
			  TOBTableCode CHAR (2) NULL ,
			  ProvTypeTableCode CHAR (2) NULL ,
			  Hospital CHAR (1) NULL ,
			  ProvSpclTableCode CHAR (2) NULL ,
			  DaysToPay SMALLINT NULL ,
			  DaysToPayQualify CHAR (2) NULL ,
			  OutPatientFS CHAR (1) NULL ,
			  ProcFileVer CHAR (1) NULL ,
			  AnestUnit SMALLINT NULL ,
			  AnestRndUp SMALLINT NULL ,
			  AnestFormat CHAR (1) NULL ,
			  StateMandateSSN CHAR (1) NULL ,
			  ICDEdition SMALLINT NULL ,
			  ICD10ComplianceDate DATETIME NULL ,
			  eBillsDaysToPay SMALLINT NULL ,
			  eBillsDaysToPayQualify CHAR (2) NULL ,
			  DisputeDaysToPay SMALLINT NULL ,
			  DisputeDaysToPayQualify CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Jurisdiction ADD 
     CONSTRAINT PK_Jurisdiction PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, JurisdictionID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Jurisdiction ON src.Jurisdiction   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Line', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Line
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  LineSeq SMALLINT NOT NULL ,
			  DupClientCode CHAR (4) NULL ,
			  DupBillSeq INT NULL ,
			  DOS DATETIME NULL ,
			  ProcType CHAR (1) NULL ,
			  PPOOverride MONEY NULL ,
			  ClientLineType VARCHAR (5) NULL ,
			  ProvType CHAR (3) NULL ,
			  URQtyAllow SMALLINT NULL ,
			  URQtySvd SMALLINT NULL ,
			  DOSTo DATETIME NULL ,
			  URAllow MONEY NULL ,
			  URCaseSeq INT NULL ,
			  RevenueCode CHAR (4) NULL ,
			  ProcBilled VARCHAR (30) NULL ,
			  URReviewSeq SMALLINT NULL ,
			  URPriority SMALLINT NULL ,
			  ProcCode VARCHAR (30) NULL ,
			  Units DECIMAL(11,3) NULL ,
			  AllowUnits DECIMAL(11,3) NULL ,
			  Charge MONEY NULL ,
			  BRAllow MONEY NULL ,
			  PPOAllow MONEY NULL ,
			  PayOverride MONEY NULL ,
			  ProcNew VARCHAR (30) NULL ,
			  AdjAllow MONEY NULL ,
			  ReevalAmount MONEY NULL ,
			  POS CHAR (2) NULL ,
			  DxRefList VARCHAR (30) NULL ,
			  TOS CHAR (2) NULL ,
			  ReevalTxtPtr SMALLINT NULL ,
			  FSAmount MONEY NULL ,
			  UCAmount MONEY NULL ,
			  CoPay MONEY NULL ,
			  Deductible MONEY NULL ,
			  CostToChargeRatio FLOAT NULL ,
			  RXNumber VARCHAR (20) NULL ,
			  DaysSupply SMALLINT NULL ,
			  DxRef VARCHAR (4) NULL ,
			  ExternalID VARCHAR (30) NULL ,
			  ItemCostInvoiced MONEY NULL ,
			  ItemCostAdditional MONEY NULL ,
			  Refill CHAR (1) NULL ,
			  ProvSecondaryID VARCHAR (30) NULL ,
			  Certification CHAR (1) NULL ,
			  ReevalTxtSrc VARCHAR (3) NULL ,
			  BasisOfCost CHAR (1) NULL ,
			  DMEFrequencyCode CHAR (1) NULL ,
			  ProvRenderingNPI VARCHAR (10) NULL ,
			  ProvSecondaryIDQualifier CHAR (2) NULL ,
			  PaidProcCode VARCHAR (30) NULL ,
			  PaidProcType VARCHAR (3) NULL ,
			  URStatus CHAR (1) NULL ,
			  URWorkflowStatus CHAR (1) NULL ,
			  OverrideAllowUnits DECIMAL(11,3) NULL ,
			  LineSeqOrgRev SMALLINT NULL ,
			  ODGFlag SMALLINT NULL ,
			  CompoundDrugIndicator CHAR (1) NULL ,
			  PriorAuthNum VARCHAR (50) NULL ,
			  ReevalParagraphJurisdiction CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Line ADD 
     CONSTRAINT PK_Line PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, LineSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Line ON src.Line   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.Line')
					AND c.name = 'Units' 
					AND NOT ( t.name = 'DECIMAL' 
						 AND c.precision = CAST(PARSENAME(REPLACE('11,3',',','.'),2) AS INT) 
						 AND c.scale = CAST(PARSENAME(REPLACE('11,3',',','.'),1) AS INT) 
						   ) ) 
	BEGIN
		ALTER TABLE src.Line ALTER COLUMN Units DECIMAL(11,3) NULL ;
	END ; 
GO
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.Line')
					AND c.name = 'AllowUnits' 
					AND NOT ( t.name = 'DECIMAL' 
						 AND c.precision = CAST(PARSENAME(REPLACE('11,3',',','.'),2) AS INT) 
						 AND c.scale = CAST(PARSENAME(REPLACE('11,3',',','.'),1) AS INT) 
						   ) ) 
	BEGIN
		ALTER TABLE src.Line ALTER COLUMN AllowUnits DECIMAL(11,3) NULL ;
	END ; 
GO
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.Line')
					AND c.name = 'OverrideAllowUnits' 
					AND NOT ( t.name = 'DECIMAL' 
						 AND c.precision = CAST(PARSENAME(REPLACE('11,3',',','.'),2) AS INT) 
						 AND c.scale = CAST(PARSENAME(REPLACE('11,3',',','.'),1) AS INT) 
						   ) ) 
	BEGIN
		ALTER TABLE src.Line ALTER COLUMN OverrideAllowUnits DECIMAL(11,3) NULL ;
	END ; 
GO


IF OBJECT_ID('src.LineMod', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.LineMod
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  LineSeq SMALLINT NOT NULL ,
			  ModSeq SMALLINT NOT NULL ,
			  UserEntered CHAR (1) NULL ,
			  ModSiteCode CHAR (3) NULL ,
			  Modifier VARCHAR (6) NULL ,
			  ReductionCode SMALLINT NULL ,
			  ModSubset CHAR (2) NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ReasonClientCode CHAR (4) NULL ,
			  ReasonBillSeq INT NULL ,
			  ReasonLineSeq SMALLINT NULL ,
			  ReasonType CHAR (1) NULL ,
			  ReasonValue VARCHAR (30) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.LineMod ADD 
     CONSTRAINT PK_LineMod PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, LineSeq, ModSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_LineMod ON src.LineMod   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.LineReduction', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.LineReduction
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  LineSeq SMALLINT NOT NULL ,
			  ReductionCode SMALLINT NOT NULL ,
			  ReductionAmount MONEY NULL ,
			  OverrideAmount MONEY NULL ,
			  ModUserID CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.LineReduction ADD 
     CONSTRAINT PK_LineReduction PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, LineSeq, ReductionCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_LineReduction ON src.LineReduction   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.MedicareICQM', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.MedicareICQM
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Jurisdiction CHAR (2) NOT NULL ,
			  MdicqmSeq INT NOT NULL ,
			  ProviderNum VARCHAR (6) NULL ,
			  ProvSuffix CHAR (1) NULL ,
			  ServiceCode VARCHAR (25) NULL ,
			  HCPCS VARCHAR (5) NULL ,
			  Revenue CHAR (3) NULL ,
			  MedicareICQMDescription VARCHAR (40) NULL ,
			  IP1995 INT NULL ,
			  OP1995 INT NULL ,
			  IP1996 INT NULL ,
			  OP1996 INT NULL ,
			  IP1997 INT NULL ,
			  OP1997 INT NULL ,
			  IP1998 INT NULL ,
			  OP1998 INT NULL ,
			  NPI VARCHAR (10) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.MedicareICQM ADD 
     CONSTRAINT PK_MedicareICQM PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Jurisdiction, MdicqmSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_MedicareICQM ON src.MedicareICQM   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Modifier', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Modifier
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Jurisdiction CHAR (2) NOT NULL ,
			  Code VARCHAR (6) NOT NULL ,
			  SiteCode CHAR (3) NOT NULL ,
			  Func CHAR (1) NULL ,
			  Val CHAR (3) NULL ,
			  ModType CHAR (1) NULL ,
			  GroupCode CHAR (2) NULL ,
			  ModDescription VARCHAR (30) NULL ,
			  ModComment1 VARCHAR (70) NULL ,
			  ModComment2 VARCHAR (70) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  Statute VARCHAR (30) NULL ,
			  Remark1 VARCHAR (6) NULL ,
			  RemarkQualifier1 VARCHAR (2) NULL ,
			  Remark2 VARCHAR (6) NULL ,
			  RemarkQualifier2 VARCHAR (2) NULL ,
			  Remark3 VARCHAR (6) NULL ,
			  RemarkQualifier3 VARCHAR (2) NULL ,
			  Remark4 VARCHAR (6) NULL ,
			  RemarkQualifier4 VARCHAR (2) NULL ,
			  CBREReasonID INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Modifier ADD 
     CONSTRAINT PK_Modifier PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Jurisdiction, Code, SiteCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Modifier ON src.Modifier   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ODGData', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ODGData
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ICDDiagnosisID INT NOT NULL ,
			  ProcedureCode VARCHAR (30) NOT NULL ,
			  ICDDescription VARCHAR (300) NULL ,
			  ProcedureDescription VARCHAR (800) NULL ,
			  IncidenceRate MONEY NULL ,
			  ProcedureFrequency MONEY NULL ,
			  Visits25Perc SMALLINT NULL ,
			  Visits50Perc SMALLINT NULL ,
			  Visits75Perc SMALLINT NULL ,
			  VisitsMean MONEY NULL ,
			  CostsMean MONEY NULL ,
			  AutoApprovalCode VARCHAR (5) NULL ,
			  PaymentFlag SMALLINT NULL ,
			  CostPerVisit MONEY NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ODGData ADD 
     CONSTRAINT PK_ODGData PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ICDDiagnosisID, ProcedureCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ODGData ON src.ODGData   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Pend', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Pend
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  PendSeq SMALLINT NOT NULL ,
			  PendDate DATETIME NULL ,
			  ReleaseFlag CHAR (1) NULL ,
			  PendToID VARCHAR (13) NULL ,
			  Priority CHAR (1) NULL ,
			  ReleaseDate DATETIME NULL ,
			  ReasonCode VARCHAR (8) NULL ,
			  PendByUserID CHAR (2) NULL ,
			  ReleaseByUserID CHAR (2) NULL ,
			  AutoPendFlag CHAR (1) NULL ,
			  RuleID CHAR (5) NULL ,
			  WFTaskSeq INT NULL ,
			  ReleasedByExternalUserName VARCHAR (128) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Pend ADD 
     CONSTRAINT PK_Pend PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, PendSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Pend ON src.Pend   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Policy', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Policy
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubSet CHAR (4) NOT NULL ,
			  PolicySeq INT NOT NULL ,
			  Name VARCHAR (60) NULL ,
			  ExternalID VARCHAR (20) NULL ,
			  PolicyID VARCHAR (30) NULL ,
			  AdminKey VARCHAR (40) NULL ,
			  LocationCode VARCHAR (10) NULL ,
			  Address1 VARCHAR (30) NULL ,
			  Address2 VARCHAR (30) NULL ,
			  City VARCHAR (20) NULL ,
			  State CHAR (2) NULL ,
			  Zip VARCHAR (9) NULL ,
			  PhoneNum VARCHAR (20) NULL ,
			  FaxNum VARCHAR (20) NULL ,
			  EffectiveDate DATETIME NULL ,
			  TerminationDate DATETIME NULL ,
			  TIN VARCHAR (9) NULL ,
			  StateTaxID VARCHAR (30) NULL ,
			  DeptIndusRelNum VARCHAR (20) NULL ,
			  EqOppIndicator CHAR (1) NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  MCOFlag CHAR (1) NULL ,
			  MCOStartDate DATETIME NULL ,
			  FeeRateCtrlEx CHAR (4) NULL ,
			  CreateBy CHAR (2) NULL ,
			  FeeRateCtrlIn CHAR (4) NULL ,
			  CreateDate DATETIME NULL ,
			  SelfInsured CHAR (1) NULL ,
			  NAICSCode VARCHAR (15) NULL ,
			  MonthlyPremium MONEY NULL ,
			  PPOProfileSiteCode CHAR (3) NULL ,
			  PPOProfileID INT NULL ,
			  SalesTaxExempt CHAR (1) NULL ,
			  ReceiptHandlingCode CHAR (1) NULL ,
			  TxNonSubscrib CHAR (1) NULL ,
			  SubdivisionName VARCHAR (60) NULL ,
			  PolicyCoPayAmount MONEY NULL ,
			  PolicyCoPayPct SMALLINT NULL ,
			  PolicyDeductible MONEY NULL ,
			  PolicyLimitAmount MONEY NULL ,
			  PolicyTimeLimit SMALLINT NULL ,
			  PolicyLimitWarningPct SMALLINT NULL ,
			  PolicyLimitResult CHAR (1) NULL ,
			  URProfileID VARCHAR (8) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Policy ADD 
     CONSTRAINT PK_Policy PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubSet, PolicySeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Policy ON src.Policy   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.PPOContract', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PPOContract
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  PPONetworkID CHAR (2) NOT NULL ,
			  PPOContractID VARCHAR (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL ,
			  SiteCode CHAR (3) NULL ,
			  TIN VARCHAR (9) NULL ,
			  AlternateTIN VARCHAR (9) NULL ,
			  StartDate DATETIME NULL ,
			  EndDate DATETIME NULL ,
			  OPLineItemDefaultDiscount SMALLINT NULL ,
			  CompanyName VARCHAR (35) NULL ,
			  First VARCHAR (35) NULL ,
			  GroupCode CHAR (3) NULL ,
			  GroupName VARCHAR (40) NULL ,
			  OPDiscountBaseValue CHAR (1) NULL ,
			  OPOffFS SMALLINT NULL ,
			  OPOffUCR SMALLINT NULL ,
			  OPOffCharge SMALLINT NULL ,
			  OPEffectiveDate DATETIME NULL ,
			  OPAdditionalDiscountOffLink SMALLINT NULL ,
			  OPTerminationDate DATETIME NULL ,
			  OPUCRPercentile SMALLINT NULL ,
			  OPCondition CHAR (2) NULL ,
			  IPDiscountBaseValue CHAR (1) NULL ,
			  IPOffFS SMALLINT NULL ,
			  IPOffUCR SMALLINT NULL ,
			  IPOffCharge SMALLINT NULL ,
			  IPEffectiveDate DATETIME NULL ,
			  IPTerminationDate DATETIME NULL ,
			  IPCondition CHAR (2) NULL ,
			  IPStopCapAmount MONEY NULL ,
			  IPStopCapRate SMALLINT NULL ,
			  MinDisc SMALLMONEY NULL ,
			  MaxDisc SMALLMONEY NULL ,
			  MedicalPerdiem SMALLMONEY NULL ,
			  SurgicalPerdiem SMALLMONEY NULL ,
			  ICUPerdiem SMALLMONEY NULL ,
			  PsychiatricPerdiem SMALLMONEY NULL ,
			  MiscParm CHAR (2) NULL ,
			  SpcCode CHAR (1) NULL ,
			  PPOType CHAR (1) NULL ,
			  BillingAddress1 VARCHAR (30) NULL ,
			  BillingAddress2 VARCHAR (30) NULL ,
			  BillingCity VARCHAR (20) NULL ,
			  BillingState CHAR (2) NULL ,
			  BillingZip VARCHAR (9) NULL ,
			  PracticeAddress1 VARCHAR (30) NULL ,
			  PracticeAddress2 VARCHAR (30) NULL ,
			  PracticeCity VARCHAR (20) NULL ,
			  PracticeState CHAR (2) NULL ,
			  PracticeZip VARCHAR (9) NULL ,
			  PhoneNum VARCHAR (10) NULL ,
			  OutFile VARCHAR (12) NULL ,
			  InpatFile VARCHAR (12) NULL ,
			  URCoordinatorFlag CHAR (1) NULL ,
			  ExclusivePPOOrgFlag CHAR (1) NULL ,
			  StopLossTypeCode VARCHAR (4) NULL ,
			  BR_RNEDiscount SMALLINT NULL ,
			  ModDate DATETIME NULL ,
			  ExportFlag CHAR (1) NULL ,
			  OPManualIndicator CHAR (1) NULL ,
			  OPStopCapAmount MONEY NULL ,
			  OPStopCapRate SMALLINT NULL ,
			  Specialty1 VARCHAR (4) NULL ,
			  Specialty2 VARCHAR (4) NULL ,
			  LessorOfThreshold SMALLINT NULL ,
			  BilateralDiscount SMALLINT NULL ,
			  SurgeryDiscount2 SMALLINT NULL ,
			  SurgeryDiscount3 SMALLINT NULL ,
			  SurgeryDiscount4 SMALLINT NULL ,
			  SurgeryDiscount5 SMALLINT NULL ,
			  Matrix CHAR (1) NULL ,
			  ProvType VARCHAR (5) NULL ,
			  AllInclusive CHAR (1) NULL ,
			  Region VARCHAR (4) NULL ,
			  PaymentAddressFlag CHAR (1) NULL ,
			  MedicalGroup CHAR (1) NULL ,
			  MedicalGroupCode VARCHAR (4) NULL ,
			  RateMode CHAR (1) NULL ,
			  PracticeCounty VARCHAR (25) NULL ,
			  FIPSCountyCode CHAR (3) NULL ,
			  PrimaryCareFlag CHAR (1) NULL ,
			  PPOContractIDOld VARCHAR (14) NULL ,
			  MultiSurg CHAR (1) NULL ,
			  BiLevel CHAR (1) NULL ,
			  DRGRate SMALLMONEY NULL ,
			  DRGGreaterThanBC SMALLINT NULL ,
			  DRGMinPercentBC SMALLINT NULL ,
			  CarveOut CHAR (1) NULL ,
			  PPOtoFSSeq INT NULL ,
			  LicenseNum VARCHAR (30) NULL ,
			  MedicareNum VARCHAR (20) NULL ,
			  NPI VARCHAR (10) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PPOContract ADD 
     CONSTRAINT PK_PPOContract PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PPONetworkID, PPOContractID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PPOContract ON src.PPOContract   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.PPONetwork', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PPONetwork
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  PPONetworkID CHAR (2) NOT NULL ,
			  Name VARCHAR (30) NULL ,
			  TIN VARCHAR (10) NULL ,
			  Zip VARCHAR (10) NULL ,
			  State CHAR (2) NULL ,
			  City VARCHAR (15) NULL ,
			  Street VARCHAR (30) NULL ,
			  PhoneNum VARCHAR (20) NULL ,
			  PPONetworkComment VARCHAR (6000) NULL ,
			  AllowMaint CHAR (1) NULL ,
			  ReqExtPPO CHAR (1) NULL ,
			  DemoRates CHAR (1) NULL ,
			  PrintAsProvider CHAR (1) NULL ,
			  PPOType CHAR (3) NULL ,
			  PPOVersion CHAR (1) NULL ,
			  PPOBridgeExists CHAR (1) NULL ,
			  UsesDrg CHAR (1) NULL ,
			  PPOToOther CHAR (1) NULL ,
			  SubNetworkIndicator CHAR (1) NULL ,
			  EmailAddress VARCHAR (255) NULL ,
			  WebSite VARCHAR (255) NULL ,
			  BillControlSeq SMALLINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PPONetwork ADD 
     CONSTRAINT PK_PPONetwork PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PPONetworkID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PPONetwork ON src.PPONetwork   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.PPOProfile', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PPOProfile
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  SiteCode CHAR (3) NOT NULL ,
			  PPOProfileID INT NOT NULL ,
			  ProfileDesc VARCHAR (50) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  SmartSearchPageMax SMALLINT NULL ,
			  JurisdictionStackExclusive CHAR (1) NULL ,
			  ReevalFullStackWhenOrigAllowNoHit CHAR (1) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PPOProfile ADD 
     CONSTRAINT PK_PPOProfile PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, SiteCode, PPOProfileID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PPOProfile ON src.PPOProfile   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.PPOProfileHistory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PPOProfileHistory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  PPOProfileHistorySeq BIGINT NOT NULL ,
			  RecordDeleted BIT NULL ,
			  LogDateTime DATETIME NULL ,
			  loginame NVARCHAR (256) NULL ,
			  SiteCode CHAR (3) NOT NULL ,
			  PPOProfileID INT NOT NULL ,
			  ProfileDesc VARCHAR (50) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  SmartSearchPageMax SMALLINT NULL ,
			  JurisdictionStackExclusive CHAR (1) NULL ,
			  ReevalFullStackWhenOrigAllowNoHit CHAR (1) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PPOProfileHistory ADD 
     CONSTRAINT PK_PPOProfileHistory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PPOProfileHistorySeq, SiteCode, PPOProfileID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PPOProfileHistory ON src.PPOProfileHistory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.PPOProfileNetworks', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PPOProfileNetworks
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  PPOProfileSiteCode CHAR (3) NOT NULL ,
			  PPOProfileID INT NOT NULL ,
			  ProfileRegionSiteCode CHAR (3) NOT NULL ,
			  ProfileRegionID INT NOT NULL ,
			  NetworkOrder SMALLINT NOT NULL ,
			  PPONetworkID CHAR (2) NULL ,
			  SearchLogic CHAR (1) NULL ,
			  Verification CHAR (1) NULL ,
			  EffectiveDate DATETIME NOT NULL ,
			  TerminationDate DATETIME NULL ,
			  JurisdictionInd CHAR (1) NULL ,
			  JurisdictionInsurerSeq INT NULL ,
			  JurisdictionUseOnly CHAR (1) NULL ,
			  PPOSSTinReq CHAR (1) NULL ,
			  PPOSSLicReq CHAR (1) NULL ,
			  DefaultExtendedSearches SMALLINT NULL ,
			  DefaultExtendedFilters SMALLINT NULL ,
			  SeveredTies CHAR (1) NULL ,
			  POS VARCHAR (500) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PPOProfileNetworks ADD 
     CONSTRAINT PK_PPOProfileNetworks PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PPOProfileSiteCode, PPOProfileID, ProfileRegionSiteCode, ProfileRegionID, NetworkOrder, EffectiveDate) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PPOProfileNetworks ON src.PPOProfileNetworks   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.PPOProfileNetworksHistory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PPOProfileNetworksHistory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  PPOProfileNetworksHistorySeq BIGINT NOT NULL ,
			  RecordDeleted BIT NULL ,
			  LogDateTime DATETIME NULL ,
			  loginame NVARCHAR (256) NULL ,
			  PPOProfileSiteCode CHAR (3) NOT NULL ,
			  PPOProfileID INT NOT NULL ,
			  ProfileRegionSiteCode CHAR (3) NOT NULL ,
			  ProfileRegionID INT NOT NULL ,
			  NetworkOrder SMALLINT NOT NULL ,
			  PPONetworkID CHAR (2) NULL ,
			  SearchLogic CHAR (1) NULL ,
			  Verification CHAR (1) NULL ,
			  EffectiveDate DATETIME NOT NULL ,
			  TerminationDate DATETIME NULL ,
			  JurisdictionInd CHAR (1) NULL ,
			  JurisdictionInsurerSeq INT NULL ,
			  JurisdictionUseOnly CHAR (1) NULL ,
			  PPOSSTinReq CHAR (1) NULL ,
			  PPOSSLicReq CHAR (1) NULL ,
			  DefaultExtendedSearches SMALLINT NULL ,
			  DefaultExtendedFilters SMALLINT NULL ,
			  SeveredTies CHAR (1) NULL ,
			  POS VARCHAR (500) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PPOProfileNetworksHistory ADD 
     CONSTRAINT PK_PPOProfileNetworksHistory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PPOProfileNetworksHistorySeq, PPOProfileSiteCode, PPOProfileID, ProfileRegionSiteCode, ProfileRegionID, NetworkOrder, EffectiveDate) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PPOProfileNetworksHistory ON src.PPOProfileNetworksHistory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.PPORateType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PPORateType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RateTypeCode CHAR (8) NOT NULL ,
			  PPONetworkID CHAR (2) NULL ,
			  Category CHAR (1) NULL ,
			  Priority CHAR (1) NULL ,
			  VBColor SMALLINT NULL ,
			  RateTypeDescription VARCHAR (70) NULL ,
			  Explanation VARCHAR (6000) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PPORateType ADD 
     CONSTRAINT PK_PPORateType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RateTypeCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PPORateType ON src.PPORateType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.PPOSubNetwork', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PPOSubNetwork
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  PPONetworkID CHAR (2) NOT NULL ,
			  GroupCode CHAR (3) NOT NULL ,
			  GroupName VARCHAR (40) NULL ,
			  ExternalID VARCHAR (30) NULL ,
			  SiteCode CHAR (3) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID VARCHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID VARCHAR (2) NULL ,
			  Street1 VARCHAR (30) NULL ,
			  Street2 VARCHAR (30) NULL ,
			  City VARCHAR (15) NULL ,
			  State CHAR (2) NULL ,
			  Zip VARCHAR (10) NULL ,
			  PhoneNum VARCHAR (20) NULL ,
			  EmailAddress VARCHAR (255) NULL ,
			  WebSite VARCHAR (255) NULL ,
			  TIN VARCHAR (9) NULL ,
			  Comment VARCHAR (4000) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PPOSubNetwork ADD 
     CONSTRAINT PK_PPOSubNetwork PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PPONetworkID, GroupCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PPOSubNetwork ON src.PPOSubNetwork   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ProfileRegion', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProfileRegion
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  SiteCode CHAR (3) NOT NULL ,
			  ProfileRegionID INT NOT NULL ,
			  RegionTypeCode CHAR (2) NULL ,
			  RegionName VARCHAR (50) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProfileRegion ADD 
     CONSTRAINT PK_ProfileRegion PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, SiteCode, ProfileRegionID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProfileRegion ON src.ProfileRegion   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ProfileRegionDetail', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProfileRegionDetail
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProfileRegionSiteCode CHAR (3) NOT NULL ,
			  ProfileRegionID INT NOT NULL ,
			  ZipCodeFrom CHAR (5) NOT NULL ,
			  ZipCodeTo CHAR (5) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProfileRegionDetail ADD 
     CONSTRAINT PK_ProfileRegionDetail PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProfileRegionSiteCode, ProfileRegionID, ZipCodeFrom) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProfileRegionDetail ON src.ProfileRegionDetail   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Provider', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Provider
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProviderSubSet CHAR (4) NOT NULL ,
			  ProviderSeq BIGINT NOT NULL ,
			  TIN VARCHAR (9) NULL ,
			  TINSuffix VARCHAR (6) NULL ,
			  ExternalID VARCHAR (30) NULL ,
			  Name VARCHAR (50) NULL ,
			  GroupCode VARCHAR (5) NULL ,
			  LicenseNum VARCHAR (30) NULL ,
			  MedicareNum VARCHAR (20) NULL ,
			  PracticeAddressSeq INT NULL ,
			  BillingAddressSeq INT NULL ,
			  HospitalSeq INT NULL ,
			  ProvType CHAR (3) NULL ,
			  Specialty1 VARCHAR (8) NULL ,
			  Specialty2 VARCHAR (8) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  Status CHAR (1) NULL ,
			  ExternalStatus CHAR (1) NULL ,
			  ExportDate DATETIME NULL ,
			  SsnTinIndicator CHAR (1) NULL ,
			  PmtDays SMALLINT NULL ,
			  AuthBeginDate DATETIME NULL ,
			  AuthEndDate DATETIME NULL ,
			  TaxAddressSeq INT NULL ,
			  CtrlNum1099 VARCHAR (4) NULL ,
			  SurchargeCode CHAR (1) NULL ,
			  WorkCompNum VARCHAR (18) NULL ,
			  WorkCompState CHAR (2) NULL ,
			  NCPDPID VARCHAR (10) NULL ,
			  EntityType CHAR (1) NULL ,
			  LastName VARCHAR (35) NULL ,
			  FirstName VARCHAR (25) NULL ,
			  MiddleName VARCHAR (25) NULL ,
			  Suffix VARCHAR (10) NULL ,
			  NPI VARCHAR (10) NULL ,
			  FacilityNPI VARCHAR (10) NULL ,
			  VerificationGroupID VARCHAR(30) NULL ,

 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Provider ADD 
     CONSTRAINT PK_Provider PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderSubSet, ProviderSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Provider ON src.Provider   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Provider')
						AND NAME = 'VerificationGroupID' )
	BEGIN
		ALTER TABLE src.Provider ADD VerificationGroupID VARCHAR(30) NULL ;
	END ; 
GO



IF OBJECT_ID('src.ProviderAddress', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProviderAddress
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProviderSubSet CHAR (4) NOT NULL ,
			  ProviderAddressSeq INT NOT NULL ,
			  RecType CHAR (2) NULL ,
			  Address1 VARCHAR (30) NULL ,
			  Address2 VARCHAR (30) NULL ,
			  City VARCHAR (30) NULL ,
			  State CHAR (2) NULL ,
			  Zip VARCHAR (9) NULL ,
			  PhoneNum VARCHAR (20) NULL ,
			  FaxNum VARCHAR (20) NULL ,
			  ContactFirstName VARCHAR (20) NULL ,
			  ContactLastName VARCHAR (20) NULL ,
			  ContactMiddleInitial CHAR (1) NULL ,
			  URFirstName VARCHAR (20) NULL ,
			  URLastName VARCHAR (20) NULL ,
			  URMiddleInitial CHAR (1) NULL ,
			  FacilityName VARCHAR (30) NULL ,
			  CountryCode CHAR (3) NULL ,
			  MailCode VARCHAR (20) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProviderAddress ADD 
     CONSTRAINT PK_ProviderAddress PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderSubSet, ProviderAddressSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProviderAddress ON src.ProviderAddress   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ProviderCluster', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ProviderCluster
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  ProviderSubSet CHAR(4) NOT NULL,
			  ProviderSeq BIGINT NOT NULL, 
			  OrgOdsCustomerId INT NOT NULL,
			  MitchellProviderKey VARCHAR(200) NULL,
			  ProviderClusterKey VARCHAR(200) NULL,
			  ProviderType VARCHAR(30) NULL,

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ProviderCluster ADD 
        CONSTRAINT PK_ProviderCluster PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,ProviderSubSet , ProviderSeq ,OrgOdsCustomerId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_ProviderCluster ON src.ProviderCluster REBUILD WITH(STATISTICS_INCREMENTAL = ON);

	END
GO

IF OBJECT_ID('src.ProviderSpecialty', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProviderSpecialty
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Id UNIQUEIDENTIFIER NOT NULL ,
			  Description NVARCHAR (MAX) NULL ,
			  ImplementationDate SMALLDATETIME NULL ,
			  DeactivationDate SMALLDATETIME NULL ,
			  DataSource UNIQUEIDENTIFIER NULL ,
			  Creator NVARCHAR (16) NULL ,
			  CreateDate SMALLDATETIME NULL ,
			  LastUpdater NVARCHAR (16) NULL ,
			  LastUpdateDate SMALLDATETIME NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProviderSpecialty ADD 
     CONSTRAINT PK_ProviderSpecialty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Id) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProviderSpecialty ON src.ProviderSpecialty   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.ProviderSpecialty')
					AND c.name = 'Creator' 
					AND NOT ( t.name = 'NVARCHAR' 
						 AND c.max_length = '128'
						   ) ) 
	BEGIN
		ALTER TABLE src.ProviderSpecialty ALTER COLUMN Creator NVARCHAR(128) NULL ;
	END ; 
GO
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.ProviderSpecialty')
					AND c.name = 'LastUpdater' 
					AND NOT ( t.name = 'NVARCHAR' 
						 AND c.max_length = '128'
						   ) ) 
	BEGIN
		ALTER TABLE src.ProviderSpecialty ALTER COLUMN LastUpdater NVARCHAR(128) NULL ;
	END ; 
GO


IF OBJECT_ID('src.ProviderSys', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProviderSys
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProviderSubset CHAR (4) NOT NULL ,
			  ProviderSubSetDesc VARCHAR (30) NULL ,
			  ProviderAccess CHAR (1) NULL ,
			  TaxAddrRequired CHAR (1) NULL ,
			  AllowDummyProviders CHAR (1) NULL ,
			  CascadeUpdatesOnImport CHAR (1) NULL ,
			  RootExtIDOverrideDelimiter CHAR (1) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProviderSys ADD 
     CONSTRAINT PK_ProviderSys PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderSubset) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProviderSys ON src.ProviderSys   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.ReductionType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ReductionType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ReductionCode SMALLINT NOT NULL ,
			  ReductionDescription VARCHAR (50) NULL ,
			  BEOverride CHAR (1) NULL ,
			  BEMsg CHAR (1) NULL ,
			  Abbreviation VARCHAR (8) NULL ,
			  DefaultMessageCode VARCHAR (6) NULL ,
			  DefaultDenialMessageCode VARCHAR (6) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ReductionType ADD 
     CONSTRAINT PK_ReductionType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReductionCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ReductionType ON src.ReductionType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.Region', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Region
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Jurisdiction CHAR (2) NOT NULL ,
			  Extension CHAR (3) NOT NULL ,
			  EndZip CHAR (5) NOT NULL ,
			  Beg VARCHAR (5) NULL ,
			  Region SMALLINT NULL ,
			  RegionDescription VARCHAR (4) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Region ADD 
     CONSTRAINT PK_Region PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Jurisdiction, Extension, EndZip) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Region ON src.Region   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.TableLookUp', 'U') IS NULL
    BEGIN
        CREATE TABLE src.TableLookUp
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              TableCode CHAR(4) NOT NULL,
              TypeCode CHAR(4) NOT NULL,
              Code CHAR(12) NOT NULL,
              SiteCode CHAR(3) NOT NULL,
              OldCode VARCHAR(12) NULL,
              ShortDesc VARCHAR(40) NULL,
              Source CHAR(1) NULL,
              Priority SMALLINT NULL,
              LongDesc VARCHAR(6000) NULL,
              OwnerApp CHAR(1) NULL,
              RecordStatus CHAR(1) NULL,
			  CreateDate DATETIME NULL,
			  CreateUserID CHAR(2) NULL,
			  ModDate DATETIME NULL,
			  ModUserID VARCHAR(2) NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.TableLookUp ADD 
        CONSTRAINT PK_TableLookUp PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,TableCode,TypeCode,Code,SiteCode) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_TableLookUp ON src.TableLookUp REBUILD WITH(STATISTICS_INCREMENTAL = ON);

	END
GO

IF OBJECT_ID('src.UserInfo', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.UserInfo
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  UserID CHAR (2) NOT NULL ,
			  UserPassword VARCHAR (35) NULL ,
			  Name VARCHAR (30) NULL ,
			  SecurityLevel CHAR (1) NULL ,
			  EnableAdjusterMenu CHAR (1) NULL ,
			  EnableProvAdds CHAR (1) NULL ,
			  AllowPosting CHAR (1) NULL ,
			  EnableClaimAdds CHAR (1) NULL ,
			  EnablePolicyAdds CHAR (1) NULL ,
			  EnableInvoiceCreditVoid CHAR (1) NULL ,
			  EnableReevaluations CHAR (1) NULL ,
			  EnablePPOAccess CHAR (1) NULL ,
			  EnableURCommentView CHAR (1) NULL ,
			  EnablePendRelease CHAR (1) NULL ,
			  EnableXtableUpdate CHAR (1) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  EnablePPOFastMatchAdds CHAR (1) NULL ,
			  ExternalID VARCHAR (30) NULL ,
			  EmailAddress VARCHAR (255) NULL ,
			  EmailNotify CHAR (1) NULL ,
			  ActiveStatus CHAR (1) NULL ,
			  CompanySeq SMALLINT NULL ,
			  NetworkLogin VARCHAR (50) NULL ,
			  AutomaticNetworkLogin CHAR (1) NULL ,
			  LastLoggedInDate DATETIME NULL ,
			  PromptToCreateMCC CHAR (1) NULL ,
			  AccessAllWorkQueues CHAR (1) NULL ,
			  LandingZoneAccess CHAR (1) NULL ,
			  ReviewLevel TINYINT NULL ,
			  EnableUserMaintenance CHAR (1) NULL ,
			  EnableHistoryMaintenance CHAR (1) NULL ,
			  EnableClientMaintenance CHAR (1) NULL ,
			  FeeAccess CHAR (1) NULL ,
			  EnableSalesTaxMaintenance CHAR (1) NULL ,
			  BESalesTaxZipCodeAccess CHAR (1) NULL ,
			  InvoiceGenAccess CHAR (1) NULL ,
			  BEPermitAllowOver CHAR (1) NULL ,
			  PermitRereviews CHAR (1) NULL ,
			  EditBillControl CHAR (1) NULL ,
			  RestrictEORNotes CHAR (1) NULL ,
			  UWQAutoNextBill CHAR (1) NULL ,
			  UWQDisableOptions CHAR (1) NULL ,
			  UWQDisableRules CHAR (1) NULL ,
			  PermitCheckReissue CHAR (1) NULL ,
			  EnableEDIAutomationMaintenance CHAR (1) NULL ,
			  RestrictDiaryNotes CHAR (1) NULL ,
			  RestrictExternalDiaryNotes CHAR (1) NULL ,
			  BEDeferManualModeMsg CHAR (1) NULL ,
			  UserRoleID INT NULL ,
			  EraseBillTempHistory CHAR (1) NULL ,
			  EditPPOProfile CHAR (1) NULL ,
			  EnableUrAccess CHAR (1) NULL ,
			  CapstoneConfigurationAccess CHAR (1) NULL ,
			  PermitUDFDefinition CHAR (1) NULL ,
			  EnablePPOProfileEdit CHAR (1) NULL ,
			  EnableSupervisorRole CHAR (1) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.UserInfo ADD 
     CONSTRAINT PK_UserInfo PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, UserID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_UserInfo ON src.UserInfo   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.WFlow', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.WFlow
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  WFlowSeq INT NOT NULL ,
			  Description VARCHAR (50) NULL ,
			  RecordStatus CHAR (1) NULL ,
			  EntityTypeCode CHAR (2) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  InitialTaskSeq INT NULL ,
			  PauseTaskSeq INT NULL ,

 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.WFlow ADD 
     CONSTRAINT PK_WFlow PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, WFlowSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_WFlow ON src.WFlow   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.WFlow')
						AND NAME = 'PauseTaskSeq' )
	BEGIN
		ALTER TABLE src.WFlow ADD PauseTaskSeq INT NULL ;
	END ; 
GO



IF OBJECT_ID('src.WFQueue', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.WFQueue
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  EntityTypeCode CHAR (2) NOT NULL ,
			  EntitySubset CHAR (4) NOT NULL ,
			  EntitySeq BIGINT NOT NULL ,
			  WFTaskSeq INT NULL ,
			  PriorWFTaskSeq INT NULL ,
			  Status CHAR (1) NULL ,
			  Priority CHAR (1) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  TaskMessage VARCHAR (500) NULL ,
			  Parameter1 VARCHAR (35) NULL ,
			  ContextID VARCHAR (256) NULL ,
			  PriorStatus CHAR (1) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.WFQueue ADD 
     CONSTRAINT PK_WFQueue PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, EntityTypeCode, EntitySubset, EntitySeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_WFQueue ON src.WFQueue   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.WFTask', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.WFTask
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  WFTaskSeq INT NOT NULL ,
			  WFLowSeq INT NULL ,
			  WFTaskRegistrySeq INT NULL ,
			  Name VARCHAR (35) NULL ,
			  Parameter1 VARCHAR (35) NULL ,
			  RecordStatus CHAR (1) NULL ,
			  NodeLeft NUMERIC (8,2) NULL ,
			  NodeTop NUMERIC (8,2) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  NoPrior CHAR (1) NULL ,
			  NoRestart CHAR (1) NULL ,
			  ParameterX VARCHAR (2000) NULL ,
			  DefaultPendGroup VARCHAR (12) NULL ,
			  Configuration NVARCHAR (2000) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.WFTask ADD 
     CONSTRAINT PK_WFTask PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, WFTaskSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_WFTask ON src.WFTask   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.WFTaskLink', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.WFTaskLink
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  FromTaskSeq INT NOT NULL ,
			  LinkWhen SMALLINT NOT NULL ,
			  ToTaskSeq INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.WFTaskLink ADD 
     CONSTRAINT PK_WFTaskLink PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, FromTaskSeq, LinkWhen) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_WFTaskLink ON src.WFTaskLink   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('src.WFTaskRegistry', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.WFTaskRegistry
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  WFTaskRegistrySeq INT NOT NULL ,
			  EntityTypeCode CHAR (2) NULL ,
			  Description VARCHAR (50) NULL ,
			  Action VARCHAR (50) NULL ,
			  SmallImageResID INT NULL ,
			  LargeImageResID INT NULL ,
			  PersistBefore CHAR (1) NULL ,
			  NAction VARCHAR (512) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.WFTaskRegistry ADD 
     CONSTRAINT PK_WFTaskRegistry PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, WFTaskRegistrySeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_WFTaskRegistry ON src.WFTaskRegistry   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF OBJECT_ID('stg.Adjuster', 'U') IS NOT NULL 
	DROP TABLE stg.Adjuster  
BEGIN
	CREATE TABLE stg.Adjuster
		(
		  ClaimSysSubSet CHAR (4) NULL,
		  Adjuster VARCHAR (25) NULL,
		  FirstName VARCHAR (20) NULL,
		  LastName VARCHAR (20) NULL,
		  MInitial CHAR (1) NULL,
		  Title VARCHAR (20) NULL,
		  Address1 VARCHAR (30) NULL,
		  Address2 VARCHAR (30) NULL,
		  City VARCHAR (20) NULL,
		  State CHAR (2) NULL,
		  Zip VARCHAR (9) NULL,
		  PhoneNum VARCHAR (20) NULL,
		  PhoneNumExt VARCHAR (10) NULL,
		  FaxNum VARCHAR (20) NULL,
		  Email VARCHAR (128) NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.AdjusterPendGroup', 'U') IS NOT NULL 
	DROP TABLE stg.AdjusterPendGroup  
BEGIN
	CREATE TABLE stg.AdjusterPendGroup
		(
		  ClaimSysSubset CHAR (4) NULL,
		  Adjuster VARCHAR (25) NULL,
		  PendGroupCode VARCHAR (12) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Attorney', 'U') IS NOT NULL 
	DROP TABLE stg.Attorney  
BEGIN
	CREATE TABLE stg.Attorney
		(
		  ClaimSysSubSet CHAR (4) NULL,
		  AttorneySeq BIGINT NULL,
		  TIN VARCHAR (9) NULL,
		  TINSuffix VARCHAR (6) NULL,
		  ExternalID VARCHAR (30) NULL,
		  Name VARCHAR (50) NULL,
		  GroupCode VARCHAR (5) NULL,
		  LicenseNum VARCHAR (30) NULL,
		  MedicareNum VARCHAR (20) NULL,
		  PracticeAddressSeq INT NULL,
		  BillingAddressSeq INT NULL,
		  AttorneyType CHAR (3) NULL,
		  Specialty1 VARCHAR (8) NULL,
		  Specialty2 VARCHAR (8) NULL,
		  CreateUserID CHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  Status CHAR (1) NULL,
		  ExternalStatus CHAR (1) NULL,
		  ExportDate DATETIME NULL,
		  SsnTinIndicator CHAR (1) NULL,
		  PmtDays SMALLINT NULL,
		  AuthBeginDate DATETIME NULL,
		  AuthEndDate DATETIME NULL,
		  TaxAddressSeq INT NULL,
		  CtrlNum1099 VARCHAR (4) NULL,
		  SurchargeCode CHAR (1) NULL,
		  WorkCompNum VARCHAR (18) NULL,
		  WorkCompState CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.AttorneyAddress', 'U') IS NOT NULL 
	DROP TABLE stg.AttorneyAddress  
BEGIN
	CREATE TABLE stg.AttorneyAddress
		(
		  ClaimSysSubSet CHAR (4) NULL,
		  AttorneyAddressSeq INT NULL,
		  RecType CHAR (2) NULL,
		  Address1 VARCHAR (30) NULL,
		  Address2 VARCHAR (30) NULL,
		  City VARCHAR (30) NULL,
		  State CHAR (2) NULL,
		  Zip VARCHAR (9) NULL,
		  PhoneNum VARCHAR (20) NULL,
		  FaxNum VARCHAR (20) NULL,
		  ContactFirstName VARCHAR (20) NULL,
		  ContactLastName VARCHAR (20) NULL,
		  ContactMiddleInitial CHAR (1) NULL,
		  URFirstName VARCHAR (20) NULL,
		  URLastName VARCHAR (20) NULL,
		  URMiddleInitial CHAR (1) NULL,
		  FacilityName VARCHAR (30) NULL,
		  CountryCode CHAR (3) NULL,
		  MailCode VARCHAR (20) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Bill', 'U') IS NOT NULL 
	DROP TABLE stg.Bill  
BEGIN
	CREATE TABLE stg.Bill
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  ClaimSeq INT NULL,
		  ClaimSysSubSet CHAR (4) NULL,
		  ProviderSeq BIGINT NULL,
		  ProviderSubSet CHAR (4) NULL,
		  PostDate DATETIME NULL,
		  DOSFirst DATETIME NULL,
		  Invoiced CHAR (1) NULL,
		  InvoicedPPO CHAR (1) NULL,
		  CreateUserID VARCHAR (2) NULL,
		  CarrierSeqNew VARCHAR (30) NULL,
		  DocCtrlType CHAR (2) NULL,
		  DOSLast DATETIME NULL,
		  PPONetworkID CHAR (2) NULL,
		  POS CHAR (2) NULL,
		  ProvType CHAR (3) NULL,
		  ProvSpecialty1 VARCHAR (8) NULL,
		  ProvZip VARCHAR (9) NULL,
		  ProvState CHAR (2) NULL,
		  SubmitDate DATETIME NULL,
		  ProvInvoice VARCHAR (14) NULL,
		  Region SMALLINT NULL,
		  HospitalSeq INT NULL,
		  ModUserID VARCHAR (2) NULL,
		  Status SMALLINT NULL,
		  StatusPrior SMALLINT NULL,
		  BillableLines SMALLINT NULL,
		  TotalCharge MONEY NULL,
		  BRReduction MONEY NULL,
		  BRFee MONEY NULL,
		  TotalAllow MONEY NULL,
		  TotalFee MONEY NULL,
		  DupClientCode CHAR (4) NULL,
		  DupBillSeq INT NULL,
		  FupStartDate DATETIME NULL,
		  FupEndDate DATETIME NULL,
		  SendBackMsg1SiteCode CHAR (3) NULL,
		  SendBackMsg1 VARCHAR (6) NULL,
		  SendBackMsg2SiteCode CHAR (3) NULL,
		  SendBackMsg2 VARCHAR (6) NULL,
		  PPOReduction MONEY NULL,
		  PPOPrc SMALLINT NULL,
		  PPOContractID VARCHAR (30) NULL,
		  PPOStatus CHAR (1) NULL,
		  PPOFee MONEY NULL,
		  NGDReduction MONEY NULL,
		  NGDFee MONEY NULL,
		  URFee MONEY NULL,
		  OtherData VARCHAR (30) NULL,
		  ExternalStatus CHAR (1) NULL,
		  URFlag CHAR (1) NULL,
		  Visits SMALLINT NULL,
		  TOS CHAR (2) NULL,
		  TOB CHAR (1) NULL,
		  SubProductCode CHAR (1) NULL,
		  ForcePay CHAR (1) NULL,
		  PmtAuth VARCHAR (4) NULL,
		  FlowStatus CHAR (1) NULL,
		  ConsultDate DATETIME NULL,
		  RcvdDate DATETIME NULL,
		  AdmissionType CHAR (1) NULL,
		  PaidDate DATETIME NULL,
		  AdmitDate DATETIME NULL,
		  DischargeDate DATETIME NULL,
		  TxBillType CHAR (1) NULL,
		  RcvdBrDate DATETIME NULL,
		  DueDate DATETIME NULL,
		  Adjuster VARCHAR (25) NULL,
		  DOI DATETIME NULL,
		  RetCtrlFlg CHAR (1) NULL,
		  RetCtrlNum VARCHAR (9) NULL,
		  SiteCode CHAR (3) NULL,
		  SourceID CHAR (2) NULL,
		  CaseType CHAR (1) NULL,
		  SubProductID VARCHAR (30) NULL,
		  SubProductPrice MONEY NULL,
		  URReduction MONEY NULL,
		  ProvLicenseNum VARCHAR (30) NULL,
		  ProvMedicareNum VARCHAR (20) NULL,
		  ProvSpecialty2 VARCHAR (8) NULL,
		  PmtExportDate DATETIME NULL,
		  PmtAcceptDate DATETIME NULL,
		  ClientTOB VARCHAR (5) NULL,
		  BRFeeNet MONEY NULL,
		  PPOFeeNet MONEY NULL,
		  NGDFeeNet MONEY NULL,
		  URFeeNet MONEY NULL,
		  SubProductPriceNet MONEY NULL,
		  BillSeqNewRev INT NULL,
		  BillSeqOrgRev INT NULL,
		  VocPlanSeq SMALLINT NULL,
		  ReviewDate DATETIME NULL,
		  AuditDate DATETIME NULL,
		  ReevalAllow MONEY NULL,
		  CheckNum VARCHAR (30) NULL,
		  NegoType CHAR (2) NULL,
		  DischargeHour CHAR (2) NULL,
		  UB92TOB CHAR (3) NULL,
		  MCO VARCHAR (10) NULL,
		  DRG CHAR (3) NULL,
		  PatientAccount VARCHAR (20) NULL,
		  ExaminerRevFlag CHAR (1) NULL,
		  RefProvName VARCHAR (40) NULL,
		  PaidAmount MONEY NULL,
		  AdmissionSource CHAR (1) NULL,
		  AdmitHour CHAR (2) NULL,
		  PatientStatus CHAR (2) NULL,
		  DRGValue MONEY NULL,
		  CompanySeq SMALLINT NULL,
		  TotalCoPay MONEY NULL,
		  UB92ProcMethod CHAR (1) NULL,
		  TotalDeductible MONEY NULL,
		  PolicyCoPayAmount MONEY NULL,
		  PolicyCoPayPct SMALLINT NULL,
		  DocCtrlID VARCHAR (50) NULL,
		  ResourceUtilGroup VARCHAR (4) NULL,
		  PolicyDeductible MONEY NULL,
		  PolicyLimit MONEY NULL,
		  PolicyTimeLimit SMALLINT NULL,
		  PolicyWarningPct SMALLINT NULL,
		  AppBenefits CHAR (1) NULL,
		  AppAssignee CHAR (1) NULL,
		  CreateDate DATETIME NULL,
		  ModDate DATETIME NULL,
		  IncrementValue SMALLINT NULL,
		  AdjVerifRequestDate DATETIME NULL,
		  AdjVerifRcvdDate DATETIME NULL,
		  RenderingProvLastName VARCHAR (35) NULL,
		  RenderingProvFirstName VARCHAR (25) NULL,
		  RenderingProvMiddleName VARCHAR (25) NULL,
		  RenderingProvSuffix VARCHAR (10) NULL,
		  RereviewCount SMALLINT NULL,
		  DRGBilled CHAR (3) NULL,
		  DRGCalculated CHAR (3) NULL,
		  ProvRxLicenseNum VARCHAR (30) NULL,
		  ProvSigOnFile CHAR (1) NULL,
		  RefProvFirstName VARCHAR (30) NULL,
		  RefProvMiddleName VARCHAR (25) NULL,
		  RefProvSuffix VARCHAR (10) NULL,
		  RefProvDEANum VARCHAR (9) NULL,
		  SendbackMsg1Subset CHAR (2) NULL,
		  SendbackMsg2Subset CHAR (2) NULL,
		  PPONetworkJurisdictionInd CHAR (1) NULL,
		  ManualReductionMode SMALLINT NULL,
		  WholesaleSalesTaxZip VARCHAR (9) NULL,
		  RetailSalesTaxZip VARCHAR (9) NULL,
		  PPONetworkJurisdictionInsurerSeq INT NULL,
		  InvoicedWholesale CHAR (1) NULL,
		  InvoicedPPOWholesale CHAR (1) NULL,
		  AdmittingDxRef SMALLINT NULL,
		  AdmittingDxCode VARCHAR (8) NULL,
		  ProvFacilityNPI VARCHAR (10) NULL,
		  ProvBillingNPI VARCHAR (10) NULL,
		  ProvRenderingNPI VARCHAR (10) NULL,
		  ProvOperatingNPI VARCHAR (10) NULL,
		  ProvReferringNPI VARCHAR (10) NULL,
		  ProvOther1NPI VARCHAR (10) NULL,
		  ProvOther2NPI VARCHAR (10) NULL,
		  ProvOperatingLicenseNum VARCHAR (30) NULL,
		  EHubID VARCHAR (50) NULL,
		  OtherBillingProviderSubset CHAR (4) NULL,
		  OtherBillingProviderSeq BIGINT NULL,
		  ResubmissionReasonCode CHAR (2) NULL,
		  ContractType CHAR (2) NULL,
		  ContractAmount MONEY NULL,
		  PriorAuthReferralNum1 VARCHAR (30) NULL,
		  PriorAuthReferralNum2 VARCHAR (30) NULL,
		  DRGCompositeFactor MONEY NULL,
		  DRGDischargeFraction MONEY NULL,
		  DRGInpatientMultiplier MONEY NULL,
		  DRGWeight MONEY NULL,
		  EFTPmtMethodCode VARCHAR (3) NULL,
		  EFTPmtFormatCode VARCHAR (10) NULL,
		  EFTSenderDFIID VARCHAR (27) NULL,
		  EFTSenderAcctNum VARCHAR (50) NULL,
		  EFTOrigCoSupplCode VARCHAR (24) NULL,
		  EFTReceiverDFIID VARCHAR (27) NULL,
		  EFTReceiverAcctQual VARCHAR (3) NULL,
		  EFTReceiverAcctNum VARCHAR (50) NULL,
		  PolicyLimitResult CHAR (1) NULL,
		  HistoryBatchNumber INT NULL,
		  ProvBillingTaxonomy VARCHAR (11) NULL,
		  ProvFacilityTaxonomy VARCHAR (11) NULL,
		  ProvRenderingTaxonomy VARCHAR (11) NULL,
		  PPOStackList VARCHAR (30) NULL,
		  ICDVersion SMALLINT NULL,
		  ODGFlag SMALLINT NULL,
		  ProvBillLicenseNum VARCHAR (30) NULL,
		  ProvFacilityLicenseNum VARCHAR (30) NULL,
		  ProvVendorExternalID VARCHAR (30) NULL,
		  BRActualClientCode CHAR (4) NULL,
		  BROverrideClientCode CHAR (4) NULL,
		  BillReevalReasonCode VARCHAR (30) NULL,
		  PaymentClearedDate DATETIME NULL,
		  EstimatedBRClientCode CHAR (4) NULL,
		  EstimatedBRJuris CHAR (2) NULL,
		  OverrideFeeControlRetail CHAR (4) NULL,
		  OverrideFeeControlWholesale CHAR (4) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.BillControl', 'U') IS NOT NULL
DROP TABLE stg.BillControl
BEGIN
	CREATE TABLE stg.BillControl (
	   ClientCode CHAR(4) NOT NULL
	   ,BillSeq INT NOT NULL
	   ,BillControlSeq SMALLINT NOT NULL
	   ,ModDate DATETIME NULL
	   ,CreateDate DATETIME NULL
	   ,Control CHAR(1) NULL
	   ,ExternalID VARCHAR(50) NULL
	   ,BatchNumber BIGINT NULL
	   ,ModUserID CHAR(2) NULL
	   ,ExternalID2 VARCHAR(50) NULL
	   ,Message VARCHAR(500) NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.BillControlHistory', 'U') IS NOT NULL 
	DROP TABLE stg.BillControlHistory  
BEGIN
	CREATE TABLE stg.BillControlHistory
		(
		  BillControlHistorySeq BIGINT NULL,
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  BillControlSeq SMALLINT NULL,
		  CreateDate DATETIME NULL,
		  Control CHAR (1) NULL,
		  ExternalID VARCHAR (50) NULL,
		  EDIBatchLogSeq BIGINT NULL,
		  Deleted BIT NULL,
		  ModUserID CHAR (2) NULL,
		  ExternalID2 VARCHAR (50) NULL,
		  Message VARCHAR (500) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.BillData', 'U') IS NOT NULL 
	DROP TABLE stg.BillData  
BEGIN
	CREATE TABLE stg.BillData
		(
		  ClientCode CHAR(4) NULL,
	      BillSeq INT NULL,
	      TypeCode CHAR(6) NULL,
	      SubType CHAR(12) NULL,
	      SubSeq SMALLINT NULL,
	      NumData NUMERIC(18, 6) NULL,
	      TextData VARCHAR(6000) NULL,
	      ModDate DATETIME NULL,
	      ModUserID CHAR(2) NULL,
	      CreateDate DATETIME NULL,
	      CreateUserID CHAR(2) NULL,
	      DmlOperation CHAR(1) NOT NULL
	 )
END 
GO




IF OBJECT_ID('stg.BillFee', 'U') IS NOT NULL 
	DROP TABLE stg.BillFee  
BEGIN
	CREATE TABLE stg.BillFee
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  FeeType CHAR (1) NULL,
		  TransactionType CHAR (6) NULL,
		  FeeCtrlSource CHAR (1) NULL,
		  FeeControlSeq INT NULL,
		  FeeAmount MONEY NULL,
		  InvoiceSeq BIGINT NULL,
		  InvoiceSubSeq SMALLINT NULL,
		  PPONetworkID CHAR (2) NULL,
		  ReductionCode SMALLINT NULL,
		  FeeOverride CHAR (1) NULL,
		  OverrideVerified CHAR (1) NULL,
		  ExclusiveFee CHAR (1) NULL,
		  FeeSourceID VARCHAR (20) NULL,
		  HandlingFee CHAR (1) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.BillICD', 'U') IS NOT NULL 
	DROP TABLE stg.BillICD  
BEGIN
	CREATE TABLE stg.BillICD
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  BillICDSeq SMALLINT NULL,
		  CodeType CHAR (1) NULL,
		  ICDCode VARCHAR (8) NULL,
		  CodeDate DATETIME NULL,
		  POA CHAR (1) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.BillICDDiagnosis', 'U') IS NOT NULL 
	DROP TABLE stg.BillICDDiagnosis  
BEGIN
	CREATE TABLE stg.BillICDDiagnosis
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  BillDiagnosisSeq SMALLINT NULL,
		  ICDDiagnosisID INT NULL,
		  POA CHAR (1) NULL,
		  BilledICDDiagnosis CHAR (8) NULL,
		  ICDBillUsageTypeID SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.BillICDProcedure', 'U') IS NOT NULL 
	DROP TABLE stg.BillICDProcedure  
BEGIN
	CREATE TABLE stg.BillICDProcedure
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  BillProcedureSeq SMALLINT NULL,
		  ICDProcedureID INT NULL,
		  CodeDate DATETIME NULL,
		  BilledICDProcedure CHAR (8) NULL,
		  ICDBillUsageTypeID SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.BillPPORate', 'U') IS NOT NULL 
	DROP TABLE stg.BillPPORate  
BEGIN
	CREATE TABLE stg.BillPPORate
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  LinkName VARCHAR (12) NULL,
		  RateType VARCHAR (8) NULL,
		  Applied CHAR (1) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.BillProvider', 'U') IS NOT NULL 
	DROP TABLE stg.BillProvider  
BEGIN
	CREATE TABLE stg.BillProvider
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  BillProviderSeq INT NULL,
		  Qualifier CHAR (2) NULL,
		  LastName VARCHAR (40) NULL,
		  FirstName VARCHAR (30) NULL,
		  MiddleName VARCHAR (25) NULL,
		  Suffix VARCHAR (10) NULL,
		  NPI VARCHAR (10) NULL,
		  LicenseNum VARCHAR (30) NULL,
		  DEANum VARCHAR (9) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.BillReevalReason', 'U') IS NOT NULL 
	DROP TABLE stg.BillReevalReason  
BEGIN
	CREATE TABLE stg.BillReevalReason
		(
		  BillReevalReasonCode VARCHAR (30) NULL,
		  SiteCode CHAR (3) NULL,
		  BillReevalReasonCategorySeq INT NULL,
		  ShortDescription VARCHAR (40) NULL,
		  LongDescription VARCHAR (255) NULL,
		  Active BIT NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.BillRuleFire', 'U') IS NOT NULL 
	DROP TABLE stg.BillRuleFire  
BEGIN
	CREATE TABLE stg.BillRuleFire
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  LineSeq SMALLINT NULL,
		  RuleID CHAR (5) NULL,
		  RuleType CHAR (1) NULL,
		  DateRuleFired DATETIME NULL,
		  Validated CHAR (1) NULL,
		  ValidatedUserID CHAR (2) NULL,
		  DateValidated DATETIME NULL,
		  PendToID VARCHAR (13) NULL,
		  RuleSeverity CHAR (1) NULL,
		  WFTaskSeq INT NULL,
		  ChildTargetSubset VARCHAR (4) NULL,
		  ChildTargetSeq INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Branch', 'U') IS NOT NULL 
	DROP TABLE stg.Branch  
BEGIN
	CREATE TABLE stg.Branch
		(
		  ClaimSysSubSet CHAR (4) NULL,
		  BranchSeq INT NULL,
		  Name VARCHAR (60) NULL,
		  ExternalID VARCHAR (20) NULL,
		  BranchID VARCHAR (20) NULL,
		  LocationCode VARCHAR (10) NULL,
		  AdminKey VARCHAR (40) NULL,
		  Address1 VARCHAR (30) NULL,
		  Address2 VARCHAR (30) NULL,
		  City VARCHAR (20) NULL,
		  State CHAR (2) NULL,
		  Zip VARCHAR (9) NULL,
		  PhoneNum VARCHAR (20) NULL,
		  FaxNum VARCHAR (20) NULL,
		  ContactName VARCHAR (30) NULL,
		  TIN VARCHAR (9) NULL,
		  StateTaxID VARCHAR (30) NULL,
		  DIRNum VARCHAR (20) NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  RuleFire VARCHAR (4) NULL,
		  FeeRateCntrlEx VARCHAR (4) NULL,
		  FeeRateCntrlIn VARCHAR (4) NULL,
		  SalesTaxExempt CHAR (1) NULL,
		  EffectiveDate DATETIME NULL,
		  TerminationDate DATETIME NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.BRERuleCategory', 'U') IS NOT NULL 
	DROP TABLE stg.BRERuleCategory  
BEGIN
	CREATE TABLE stg.BRERuleCategory
		(
		  BRERuleCategoryID VARCHAR (30) NULL,
		  CategoryDescription VARCHAR (500) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.CityStateZip', 'U') IS NOT NULL 
	DROP TABLE stg.CityStateZip  
BEGIN
	CREATE TABLE stg.CityStateZip
		(
		  ZipCode CHAR (5) NULL,
		  CtyStKey CHAR (6) NULL,
		  CpyDtlCode CHAR (1) NULL,
		  ZipClsCode CHAR (1) NULL,
		  CtyStName VARCHAR (28) NULL,
		  CtyStNameAbv VARCHAR (13) NULL,
		  CtyStFacCode CHAR (1) NULL,
		  CtyStMailInd CHAR (1) NULL,
		  PreLstCtyKey VARCHAR (6) NULL,
		  PreLstCtyNme VARCHAR (28) NULL,
		  CtyDlvInd CHAR (1) NULL,
		  AutZoneInd CHAR (1) NULL,
		  UnqZipInd CHAR (1) NULL,
		  FinanceNum VARCHAR (6) NULL,
		  StateAbbrv CHAR (2) NULL,
		  CountyNum CHAR (3) NULL,
		  CountyName VARCHAR (25) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Claim', 'U') IS NOT NULL 
	DROP TABLE stg.Claim  
BEGIN
	CREATE TABLE stg.Claim
		(
		  ClaimSysSubSet CHAR (4) NULL,
		  ClaimSeq INT NULL,
		  ClaimID VARCHAR (35) NULL,
		  DOI DATETIME NULL,
		  PatientSSN VARCHAR (9) NULL,
		  PatientFirstName VARCHAR (10) NULL,
		  PatientLastName VARCHAR (20) NULL,
		  PatientMInitial CHAR (1) NULL,
		  ExternalClaimID VARCHAR (35) NULL,
		  PolicyCoPayAmount MONEY NULL,
		  PolicyCoPayPct SMALLINT NULL,
		  PolicyDeductible MONEY NULL,
		  Status CHAR (1) NULL,
		  PolicyLimit MONEY NULL,
		  PolicyID VARCHAR (30) NULL,
		  PolicyTimeLimit SMALLINT NULL,
		  Adjuster VARCHAR (25) NULL,
		  PolicyLimitWarningPct SMALLINT NULL,
		  FirstDOS DATETIME NULL,
		  LastDOS DATETIME NULL,
		  LoadDate DATETIME NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  PatientSex CHAR (1) NULL,
		  PatientCity VARCHAR (20) NULL,
		  PatientDOB DATETIME NULL,
		  PatientStreet2 VARCHAR (30) NULL,
		  PatientState CHAR (2) NULL,
		  PatientZip VARCHAR (9) NULL,
		  PatientStreet1 VARCHAR (30) NULL,
		  MMIDate DATETIME NULL,
		  BodyPart1 CHAR (3) NULL,
		  BodyPart2 CHAR (3) NULL,
		  BodyPart3 CHAR (3) NULL,
		  BodyPart4 CHAR (3) NULL,
		  BodyPart5 CHAR (3) NULL,
		  Location VARCHAR (10) NULL,
		  NatureInj CHAR (3) NULL,
		  URFlag CHAR (1) NULL,
		  CarKnowDate DATETIME NULL,
		  ClaimType CHAR (2) NULL,
		  CtrlDay SMALLINT NULL,
		  MCOChoice CHAR (2) NULL,
		  ClientCodeDefault VARCHAR (4) NULL,
		  CloseDate DATETIME NULL,
		  ReopenDate DATETIME NULL,
		  MedCloseDate DATETIME NULL,
		  MedStipDate DATETIME NULL,
		  LegalStatus1 CHAR (2) NULL,
		  LegalStatus2 CHAR (2) NULL,
		  LegalStatus3 CHAR (2) NULL,
		  Jurisdiction CHAR (2) NULL,
		  ProductCode CHAR (1) NULL,
		  PlaintiffAttorneySeq BIGINT NULL,
		  DefendantAttorneySeq BIGINT NULL,
		  BranchID VARCHAR (20) NULL,
		  OccCode CHAR (2) NULL,
		  ClaimSeverity CHAR (2) NULL,
		  DateLostBegan DATETIME NULL,
		  AccidentEmployment CHAR (1) NULL,
		  RelationToInsured CHAR (1) NULL,
		  Policy5Days CHAR (2) NULL,
		  Policy90Days CHAR (2) NULL,
		  Job5Days CHAR (2) NULL,
		  Job90Days CHAR (2) NULL,
		  LostDays SMALLINT NULL,
		  ActualRTWDate DATETIME NULL,
		  MCOTransInd CHAR (2) NULL,
		  QualifiedInjWorkInd CHAR (2) NULL,
		  PermStationaryInd CHAR (2) NULL,
		  HospitalAdmit CHAR (2) NULL,
		  QualifiedInjWorkDate DATETIME NULL,
		  RetToWorkDate DATETIME NULL,
		  PermStationaryDate DATETIME NULL,
		  MCOFein VARCHAR (9) NULL,
		  CreateUserID CHAR (2) NULL,
		  IDCode VARCHAR (80) NULL,
		  IDType VARCHAR (2) NULL,
		  MPNOptOutEffectiveDate DATETIME NULL,
		  MPNOptOutTerminationDate DATETIME NULL,
		  MPNOptOutPhysicianName VARCHAR (50) NULL,
		  MPNOptOutPhysicianTIN VARCHAR (9) NULL,
		  MPNChoice CHAR (2) NULL,
		  JurisdictionClaimID VARCHAR (35) NULL,
		  PolicyLimitResult CHAR (1) NULL,
		  PatientPrimaryPhone VARCHAR (20) NULL,
		  PatientWorkPhone VARCHAR (20) NULL,
		  PatientAlternatePhone VARCHAR (20) NULL,
		  ICDVersion SMALLINT NULL,
		  LastDateofTrauma DATETIME NULL,
		  ClaimAdminClaimNum VARCHAR (35) NULL,
		  PatientCountryCode CHAR (3) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ClaimData', 'U') IS NOT NULL 
	DROP TABLE stg.ClaimData  
BEGIN
	CREATE TABLE stg.ClaimData
		(
		  ClaimSysSubset CHAR (4) NULL,
		  ClaimSeq INT NULL,
		  TypeCode CHAR (6) NULL,
		  SubType CHAR (12) NULL,
		  SubSeq SMALLINT NULL,
		  NumData NUMERIC (18,6) NULL,
		  TextData VARCHAR (6000) NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ClaimDiag', 'U') IS NOT NULL 
	DROP TABLE stg.ClaimDiag  
BEGIN
	CREATE TABLE stg.ClaimDiag
		(
		  ClaimSysSubSet CHAR (4) NULL,
		  ClaimSeq INT NULL,
		  ClaimDiagSeq SMALLINT NULL,
		  DiagCode VARCHAR (8) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ClaimICDDiagnosis', 'U') IS NOT NULL 
	DROP TABLE stg.ClaimICDDiagnosis  
BEGIN
	CREATE TABLE stg.ClaimICDDiagnosis
		(
		  ClaimSysSubSet CHAR (4) NULL,
		  ClaimSeq INT NULL,
		  ClaimDiagnosisSeq SMALLINT NULL,
		  ICDDiagnosisID INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ClaimSys', 'U') IS NOT NULL 
	DROP TABLE stg.ClaimSys  
BEGIN
	CREATE TABLE stg.ClaimSys
		(
		  ClaimSysSubset CHAR (4) NULL,
		  ClaimIDMask VARCHAR (35) NULL,
		  ClaimAccess CHAR (1) NULL,
		  ClaimSysDesc VARCHAR (30) NULL,
		  PolicyholderReq CHAR (1) NULL,
		  ValidateBranch CHAR (1) NULL,
		  ValidatePolicy CHAR (1) NULL,
		  LglCode1TableCode CHAR (2) NULL,
		  LglCode2TableCode CHAR (2) NULL,
		  LglCode3TableCode CHAR (2) NULL,
		  UROccTableCode CHAR (2) NULL,
		  Policy5DaysTableCode CHAR (2) NULL,
		  Policy90DaysTableCode CHAR (2) NULL,
		  Job5DaysTableCode CHAR (2) NULL,
		  Job90DaysTableCode CHAR (2) NULL,
		  HCOTransIndTableCode CHAR (2) NULL,
		  QualifiedInjWorkTableCode CHAR (2) NULL,
		  PermStationaryTableCode CHAR (2) NULL,
		  ValidateAdjuster CHAR (1) NULL,
		  MCOProgram CHAR (1) NULL,
		  AdjusterRequired CHAR (1) NULL,
		  HospitalAdmitTableCode CHAR (2) NULL,
		  AttorneyTaxAddrRequired CHAR (1) NULL,
		  BodyPartTableCode CHAR (2) NULL,
		  PolicyDefaults CHAR (1) NULL,
		  PolicyCoPayAmount MONEY NULL,
		  PolicyCoPayPct SMALLINT NULL,
		  PolicyDeductible MONEY NULL,
		  PolicyLimit MONEY NULL,
		  PolicyTimeLimit SMALLINT NULL,
		  PolicyLimitWarningPct SMALLINT NULL,
		  RestrictUserAccess CHAR (1) NULL,
		  BEOverridePermissionFlag CHAR (1) NULL,
		  RootClaimLength SMALLINT NULL,
		  RelateClaimsTotalPolicyDetail CHAR (1) NULL,
		  PolicyLimitResult CHAR (1) NULL,
		  EnableClaimClientCodeDefault CHAR (1) NULL,
		  ReevalCopyDocCtrlID CHAR (1) NULL,
		  EnableCEPHeaderFieldEdits CHAR (1) NULL,
		  EnableSmartClientSelection CHAR (1) NULL,
		  SCSClientSelectionCode CHAR (12) NULL,
		  SCSProviderSubset CHAR (4) NULL,
		  SCSClientCodeMask CHAR (4) NULL,
		  SCSDefaultClient CHAR (4) NULL,
		  ClaimExternalIDasCarrierClaimID CHAR (1) NULL,
		  PolicyExternalIDasCarrierPolicyID CHAR (1) NULL,
		  URProfileID VARCHAR (8) NULL,
		  BEUROverridesRequireReviewRef CHAR (1) NULL,
		  UREntryValidations CHAR (1) NULL,
		  PendPPOEDIControl CHAR (1) NULL,
		  BEReevalLineAddDelete CHAR (1) NULL,
		  CPTGroupToIndividual CHAR (1) NULL,
		  ClaimExternalIDasClaimAdminClaimNum CHAR (1) NULL,
		  CreateUserID CHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  FinancialAggregation XML NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ClaimSysData', 'U') IS NOT NULL 
	DROP TABLE stg.ClaimSysData  
BEGIN
	CREATE TABLE stg.ClaimSysData
		(
		  ClaimSysSubset CHAR (4) NULL,
		  TypeCode CHAR (6) NULL,
		  SubType CHAR (12) NULL,
		  SubSeq SMALLINT NULL,
		  NumData NUMERIC (18,6) NULL,
		  TextData VARCHAR (6000) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Client', 'U') IS NOT NULL 
	DROP TABLE stg.Client  
BEGIN
	CREATE TABLE stg.Client
		(
		  ClientCode CHAR (4) NULL,
		  Name VARCHAR (30) NULL,
		  Jurisdiction CHAR (2) NULL,
		  ControlNum VARCHAR (20) NULL,
		  PolicyTimeLimit SMALLINT NULL,
		  PolicyLimitWarningPct SMALLINT NULL,
		  PolicyLimit MONEY NULL,
		  PolicyDeductible MONEY NULL,
		  PolicyCoPayPct SMALLINT NULL,
		  PolicyCoPayAmount MONEY NULL,
		  BEDiagnosis CHAR (1) NULL,
		  InvoiceBRCycle CHAR (1) NULL,
		  Status CHAR (1) NULL,
		  InvoiceGroupBy CHAR (1) NULL,
		  BEDOI CHAR (1) NULL,
		  DrugMarkUpBrand SMALLINT NULL,
		  SupplyLimit SMALLINT NULL,
		  InvoicePPOCycle CHAR (1) NULL,
		  InvoicePPOTax SMALLINT NULL,
		  DrugMarkUpGen SMALLINT NULL,
		  DrugDispGen SMALLINT NULL,
		  DrugDispBrand SMALLINT NULL,
		  BEAdjuster CHAR (1) NULL,
		  InvoiceTax SMALLINT NULL,
		  CompanySeq SMALLINT NULL,
		  BEMedAlert CHAR (1) NULL,
		  UCRPercentile SMALLINT NULL,
		  ClientComment VARCHAR (6000) NULL,
		  RemitAttention VARCHAR (30) NULL,
		  RemitAddress1 VARCHAR (30) NULL,
		  RemitAddress2 VARCHAR (30) NULL,
		  RemitCityStateZip VARCHAR (30) NULL,
		  RemitPhone VARCHAR (12) NULL,
		  ExternalID VARCHAR (10) NULL,
		  BEOther CHAR (1) NULL,
		  MedAlertDays SMALLINT NULL,
		  MedAlertVisits SMALLINT NULL,
		  MedAlertMaxCharge MONEY NULL,
		  MedAlertWarnVisits SMALLINT NULL,
		  ProviderSubSet CHAR (4) NULL,
		  AllowReReview CHAR (1) NULL,
		  AcctRep CHAR (2) NULL,
		  ClientType CHAR (1) NULL,
		  UCRMarkUp SMALLINT NULL,
		  InvoiceCombined CHAR (1) NULL,
		  BESubmitDt CHAR (1) NULL,
		  BERcvdCarrierDate CHAR (1) NULL,
		  BERcvdBillReviewDate CHAR (1) NULL,
		  BEDueDate CHAR (1) NULL,
		  ProductCode CHAR (1) NULL,
		  BEProvInvoice CHAR (1) NULL,
		  ClaimSysSubSet CHAR (4) NULL,
		  DefaultBRtoUCR CHAR (1) NULL,
		  BasePPOFeesOffFS CHAR (1) NULL,
		  BEClientTOBTableCode CHAR (2) NULL,
		  BEForcePay CHAR (1) NULL,
		  BEPayAuthorization CHAR (1) NULL,
		  BECarrierSeqFlag CHAR (1) NULL,
		  BEProvTypeTableCode CHAR (2) NULL,
		  BEProvSpcl1TableCode CHAR (2) NULL,
		  BEProvLicense CHAR (1) NULL,
		  BEPayAuthTableCode CHAR (2) NULL,
		  PendReasonTableCode CHAR (2) NULL,
		  VocRehab CHAR (1) NULL,
		  EDIAckRequired CHAR (1) NULL,
		  StateRptInd CHAR (1) NULL,
		  BEPatientAcctNum CHAR (1) NULL,
		  AutoDup CHAR (1) NULL,
		  UseAllowOnDup CHAR (1) NULL,
		  URImportUsed CHAR (1) NULL,
		  URProgStartDate CHAR (1) NULL,
		  URImportCtrlNum CHAR (4) NULL,
		  URImportCtrlGroup CHAR (4) NULL,
		  UCRSource CHAR (1) NULL,
		  UCRMarkup2 SMALLINT NULL,
		  NGDTableCode CHAR (2) NULL,
		  BESubProductTableCode CHAR (2) NULL,
		  CountryTableCode CHAR (2) NULL,
		  BERefPhys CHAR (1) NULL,
		  BEPmtWarnDays SMALLINT NULL,
		  GeoState CHAR (2) NULL,
		  BEDisableDOICheck CHAR (1) NULL,
		  DelayDays SMALLINT NULL,
		  BEValidateTotal CHAR (1) NULL,
		  BEFastMatch CHAR (1) NULL,
		  BEPriorBillDefault CHAR (1) NULL,
		  BEClientDueDays SMALLINT NULL,
		  BEAutoCalcDueDate CHAR (1) NULL,
		  UCRSource2 CHAR (1) NULL,
		  UCRPercentile2 SMALLINT NULL,
		  BEProvSpcl2TableCode CHAR (2) NULL,
		  FeeRateCntrlEx CHAR (4) NULL,
		  FeeRateCntrlIn CHAR (4) NULL,
		  BECollisionProvBills CHAR (1) NULL,
		  BECollisionBills CHAR (1) NULL,
		  SupplyMarkup SMALLINT NULL,
		  BECollisionProviders CHAR (1) NULL,
		  DefaultCoPayDeduct CHAR (1) NULL,
		  AutoBundling CHAR (1) NULL,
		  BEValidateBillClaimICD9 CHAR (1) NULL,
		  EnableGenericReprice CHAR (1) NULL,
		  BESubProdFeeInfo CHAR (1) NULL,
		  DenyNonInjDrugs CHAR (1) NULL,
		  BECollisionDosLines CHAR (1) NULL,
		  PPOProfileSiteCode CHAR (3) NULL,
		  PPOProfileID INT NULL,
		  BEShowDEAWarning CHAR (1) NULL,
		  BEHideAdjusterColumn CHAR (1) NULL,
		  BEHideCoPayColumn CHAR (1) NULL,
		  BEHideDeductColumn CHAR (1) NULL,
		  BEPaidDate CHAR (1) NULL,
		  BEProcCrossWalk CHAR (1) NULL,
		  CreateUserID CHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  BEConsultDate CHAR (1) NULL,
		  BEShowPharmacyColumns CHAR (1) NULL,
		  BEAdjVerifDates CHAR (1) NULL,
		  FutureDOSMonthLimit SMALLINT NULL,
		  BEStopAtLineUnits CHAR (1) NULL,
		  BENYNF10Fields CHAR (1) NULL,
		  EnableDRGGrouper CHAR (1) NULL,
		  ApplyCptAmaUcrRules CHAR (1) NULL,
		  BEProvSigOnFile CHAR (1) NULL,
		  BETimeEntry CHAR (1) NULL,
		  SalesTaxExempt CHAR (1) NULL,
		  InvoiceRetailProfile CHAR (4) NULL,
		  InvoiceWholesaleProfile CHAR (4) NULL,
		  BEDefaultTaxZip CHAR (1) NULL,
		  ReceiptHandlingCode CHAR (1) NULL,
		  PaymentHandlingCode CHAR (1) NULL,
		  DefaultRetailSalesTaxZip VARCHAR (9) NULL,
		  DefaultWholesaleSalesTaxZip VARCHAR (9) NULL,
		  TxNonSubscrib CHAR (1) NULL,
		  RootClaimLength SMALLINT NULL,
		  BEDAWTableCode VARCHAR (4) NULL,
		  EORProfileSeq INT NULL,
		  BEOtherBillingProvider CHAR (1) NULL,
		  BEDocCtrlID CHAR (1) NULL,
		  ReportingETL CHAR (1) NULL,
		  ClaimVerification CHAR (1) NULL,
		  ProvVerification CHAR (1) NULL,
		  BEPermitAllowOver CHAR (1) NULL,
		  BEStopAtLineDxRef CHAR (1) NULL,
		  BEQuickInfoCode CHAR (12) NULL,
		  ExcludedSmartClientSelect CHAR (1) NULL,
		  CollisionsSearchBy CHAR (1) NULL,
		  AutoDupIncludeProv CHAR (1) NULL,
		  URProfileID VARCHAR (8) NULL,
		  ExcludeURDM CHAR (1) NULL,
		  BECollisionURCases CHAR (1) NULL,
		  MUEEdits CHAR (1) NULL,
		  CPTRarity NUMERIC (5,2) NULL,
		  ICDRarity NUMERIC (5,2) NULL,
		  ICDToCPTRarity NUMERIC (5,2) NULL,
		  BEDisablePPOSearch CHAR (1) NULL,
		  BEShowLineExternalIDColumn CHAR (1) NULL,
		  BEShowLinePriorAuthColumn CHAR (1) NULL,
		  SmartGuidelinesFlag CHAR (1) NULL,
		  BEProvBillingLicense CHAR (1) NULL,
		  BEProvFacilityLicense CHAR (1) NULL,
		  VendorProviderSubSet CHAR (4) NULL,
		  DefaultJurisClientCode CHAR (1) NULL,
		  ClientGroupId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ClientData', 'U') IS NOT NULL 
	DROP TABLE stg.ClientData  
BEGIN
	CREATE TABLE stg.ClientData
		(
		  ClientCode CHAR (4) NULL,
		  TypeCode CHAR (6) NULL,
		  SubType CHAR (12) NULL,
		  SubSeq SMALLINT NULL,
		  NumData NUMERIC (18,6) NULL,
		  TextData VARCHAR (6000) NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ClientInsurer', 'U') IS NOT NULL 
	DROP TABLE stg.ClientInsurer  
BEGIN
	CREATE TABLE stg.ClientInsurer
		(
		  ClientCode CHAR (4) NULL,
		  InsurerType CHAR (1) NULL,
		  EffectiveDate DATETIME NULL,
		  InsurerSeq INT NULL,
		  TerminationDate DATETIME NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Drugs', 'U') IS NOT NULL 
	DROP TABLE stg.Drugs  
BEGIN
	CREATE TABLE stg.Drugs
		(
		  DrugCode CHAR (4) NULL,
		  DrugsDescription VARCHAR (20) NULL,
		  Disp VARCHAR (20) NULL,
		  DrugType CHAR (1) NULL,
		  Cat CHAR (1) NULL,
		  UpdateFlag CHAR (1) NULL,
		  Uv INT NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.EDIXmit', 'U') IS NOT NULL 
	DROP TABLE stg.EDIXmit  
BEGIN
	CREATE TABLE stg.EDIXmit
		(
		  EDIXmitSeq INT NULL,
		  FileSpec VARCHAR (8000) NULL,
		  FileLocation VARCHAR (255) NULL,
		  RecommendedPayment MONEY NULL,
		  UserID CHAR (2) NULL,
		  XmitDate DATETIME NULL,
		  DateFrom DATETIME NULL,
		  DateTo DATETIME NULL,
		  EDIType CHAR (1) NULL,
		  EDIPartnerID CHAR (3) NULL,
		  DBVersion VARCHAR (20) NULL,
		  EDIMapToolSiteCode CHAR (3) NULL,
		  EDIPortType CHAR (1) NULL,
		  EDIMapToolID INT NULL,
		  TransmissionStatus CHAR (1) NULL,
		  BatchNumber INT NULL,
		  SenderID VARCHAR (20) NULL,
		  ReceiverID VARCHAR (20) NULL,
		  ExternalBatchID VARCHAR (50) NULL,
		  SARelatedBatchID BIGINT NULL,
		  AckNoteCode CHAR (3) NULL,
		  AckNote VARCHAR (50) NULL,
		  ExternalBatchDate DATETIME NULL,
		  UserNotes VARCHAR (1000) NULL,
		  ResubmitDate DATETIME NULL,
		  ResubmitUserID VARCHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID VARCHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.EntityType', 'U') IS NOT NULL 
	DROP TABLE stg.EntityType  
BEGIN
	CREATE TABLE stg.EntityType
		(
		  EntityTypeID INT NULL,
		  EntityTypeKey NVARCHAR (250) NULL,
		  Description NVARCHAR (MAX) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ETL_ControlFiles', 'U') IS NOT NULL
DROP TABLE stg.ETL_ControlFiles
BEGIN
	CREATE TABLE stg.ETL_ControlFiles
		(ControlFileName VARCHAR(255) NOT NULL,
		 OltpPostingGroupAuditId INT NOT NULL,
		 CoreDBVersionId INT NULL,
		 SnapshotDate Datetime NOT NULL,
		 DataFileName VARCHAR(255) NOT NULL,
		 TargetTableName VARCHAR(100) NOT NULL,
		 RowsExtracted INT NULL,
		 TotalRowCount BIGINT NULL,
		 OdsVersion VARCHAR(20)
		 );
 END
 GO
 IF OBJECT_ID('stg.FSProcedure', 'U') IS NOT NULL 
	DROP TABLE stg.FSProcedure  
BEGIN
	CREATE TABLE stg.FSProcedure
		(
		  Jurisdiction CHAR (2) NULL,
		  Extension CHAR (3) NULL,
		  ProcedureCode CHAR (6) NULL,
		  FSProcDescription VARCHAR (24) NULL,
		  Sv CHAR (1) NULL,
		  Star CHAR (1) NULL,
		  Panel CHAR (1) NULL,
		  Ip CHAR (1) NULL,
		  Mult CHAR (1) NULL,
		  AsstSurgeon CHAR (1) NULL,
		  SectionFlag CHAR (1) NULL,
		  Fup CHAR (3) NULL,
		  Bav SMALLINT NULL,
		  ProcGroup CHAR (4) NULL,
		  ViewType SMALLINT NULL,
		  UnitValue1 MONEY NULL,
		  UnitValue2 MONEY NULL,
		  UnitValue3 MONEY NULL,
		  UnitValue4 MONEY NULL,
		  UnitValue5 MONEY NULL,
		  UnitValue6 MONEY NULL,
		  UnitValue7 MONEY NULL,
		  UnitValue8 MONEY NULL,
		  UnitValue9 MONEY NULL,
		  UnitValue10 MONEY NULL,
		  UnitValue11 MONEY NULL,
		  UnitValue12 MONEY NULL,
		  ProUnitValue1 MONEY NULL,
		  ProUnitValue2 MONEY NULL,
		  ProUnitValue3 MONEY NULL,
		  ProUnitValue4 MONEY NULL,
		  ProUnitValue5 MONEY NULL,
		  ProUnitValue6 MONEY NULL,
		  ProUnitValue7 MONEY NULL,
		  ProUnitValue8 MONEY NULL,
		  ProUnitValue9 MONEY NULL,
		  ProUnitValue10 MONEY NULL,
		  ProUnitValue11 MONEY NULL,
		  ProUnitValue12 MONEY NULL,
		  TechUnitValue1 MONEY NULL,
		  TechUnitValue2 MONEY NULL,
		  TechUnitValue3 MONEY NULL,
		  TechUnitValue4 MONEY NULL,
		  TechUnitValue5 MONEY NULL,
		  TechUnitValue6 MONEY NULL,
		  TechUnitValue7 MONEY NULL,
		  TechUnitValue8 MONEY NULL,
		  TechUnitValue9 MONEY NULL,
		  TechUnitValue10 MONEY NULL,
		  TechUnitValue11 MONEY NULL,
		  TechUnitValue12 MONEY NULL,
		  SiteCode CHAR (3) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.FSProcedureMV', 'U') IS NOT NULL 
	DROP TABLE stg.FSProcedureMV  
BEGIN
	CREATE TABLE stg.FSProcedureMV
		(
		  Jurisdiction CHAR (2) NULL,
		  Extension CHAR (3) NULL,
		  ProcedureCode CHAR (6) NULL,
		  EffectiveDate DATETIME NULL,
		  TerminationDate DATETIME NULL,
		  FSProcDescription VARCHAR (24) NULL,
		  Sv CHAR (1) NULL,
		  Star CHAR (1) NULL,
		  Panel CHAR (1) NULL,
		  Ip CHAR (1) NULL,
		  Mult CHAR (1) NULL,
		  AsstSurgeon CHAR (1) NULL,
		  SectionFlag CHAR (1) NULL,
		  Fup CHAR (3) NULL,
		  Bav SMALLINT NULL,
		  ProcGroup CHAR (4) NULL,
		  ViewType SMALLINT NULL,
		  UnitValue MONEY NULL,
		  ProUnitValue MONEY NULL,
		  TechUnitValue MONEY NULL,
		  SiteCode CHAR (3) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.FSServiceCode', 'U') IS NOT NULL 
	DROP TABLE stg.FSServiceCode  
BEGIN
	CREATE TABLE stg.FSServiceCode
		(
		  Jurisdiction CHAR (2) NULL,
		  ServiceCode VARCHAR (30) NULL,
		  GeoAreaCode VARCHAR (12) NULL,
		  EffectiveDate DATETIME NULL,
		  Description VARCHAR (255) NULL,
		  TermDate DATETIME NULL,
		  CodeSource VARCHAR (6) NULL,
		  CodeGroup VARCHAR (12) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ICD_Diagnosis', 'U') IS NOT NULL 
	DROP TABLE stg.ICD_Diagnosis  
BEGIN
	CREATE TABLE stg.ICD_Diagnosis
		(
		  ICDDiagnosisID INT NULL,
		  Code CHAR (8) NULL,
		  ShortDesc VARCHAR (60) NULL,
		  Description VARCHAR (300) NULL,
		  Detailed BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Insurer', 'U') IS NOT NULL 
	DROP TABLE stg.Insurer  
BEGIN
	CREATE TABLE stg.Insurer
		(
		  InsurerType CHAR (1) NULL,
		  InsurerSeq INT NULL,
		  Jurisdiction CHAR (2) NULL,
		  StateID VARCHAR (30) NULL,
		  TIN VARCHAR (9) NULL,
		  AltID VARCHAR (18) NULL,
		  Name VARCHAR (30) NULL,
		  Address1 VARCHAR (30) NULL,
		  Address2 VARCHAR (30) NULL,
		  City VARCHAR (20) NULL,
		  State CHAR (2) NULL,
		  Zip VARCHAR (9) NULL,
		  PhoneNum VARCHAR (20) NULL,
		  CreateUserID CHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  FaxNum VARCHAR (20) NULL,
		  NAICCoCode VARCHAR (6) NULL,
		  NAICGpCode VARCHAR (30) NULL,
		  NCCICarrierCode VARCHAR (5) NULL,
		  NCCIGroupCode VARCHAR (5) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Jurisdiction', 'U') IS NOT NULL 
	DROP TABLE stg.Jurisdiction  
BEGIN
	CREATE TABLE stg.Jurisdiction
		(
		  JurisdictionID CHAR (2) NULL,
		  Name VARCHAR (30) NULL,
		  POSTableCode CHAR (2) NULL,
		  TOSTableCode CHAR (2) NULL,
		  TOBTableCode CHAR (2) NULL,
		  ProvTypeTableCode CHAR (2) NULL,
		  Hospital CHAR (1) NULL,
		  ProvSpclTableCode CHAR (2) NULL,
		  DaysToPay SMALLINT NULL,
		  DaysToPayQualify CHAR (2) NULL,
		  OutPatientFS CHAR (1) NULL,
		  ProcFileVer CHAR (1) NULL,
		  AnestUnit SMALLINT NULL,
		  AnestRndUp SMALLINT NULL,
		  AnestFormat CHAR (1) NULL,
		  StateMandateSSN CHAR (1) NULL,
		  ICDEdition SMALLINT NULL,
		  ICD10ComplianceDate DATETIME NULL,
		  eBillsDaysToPay SMALLINT NULL,
		  eBillsDaysToPayQualify CHAR (2) NULL,
		  DisputeDaysToPay SMALLINT NULL,
		  DisputeDaysToPayQualify CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Line', 'U') IS NOT NULL 
	DROP TABLE stg.Line  
BEGIN
	CREATE TABLE stg.Line
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  LineSeq SMALLINT NULL,
		  DupClientCode CHAR (4) NULL,
		  DupBillSeq INT NULL,
		  DOS DATETIME NULL,
		  ProcType CHAR (1) NULL,
		  PPOOverride MONEY NULL,
		  ClientLineType VARCHAR (5) NULL,
		  ProvType CHAR (3) NULL,
		  URQtyAllow SMALLINT NULL,
		  URQtySvd SMALLINT NULL,
		  DOSTo DATETIME NULL,
		  URAllow MONEY NULL,
		  URCaseSeq INT NULL,
		  RevenueCode CHAR (4) NULL,
		  ProcBilled VARCHAR (30) NULL,
		  URReviewSeq SMALLINT NULL,
		  URPriority SMALLINT NULL,
		  ProcCode VARCHAR (30) NULL,
		  Units DECIMAL (11,3) NULL,
		  AllowUnits DECIMAL (11,3) NULL,
		  Charge MONEY NULL,
		  BRAllow MONEY NULL,
		  PPOAllow MONEY NULL,
		  PayOverride MONEY NULL,
		  ProcNew VARCHAR (30) NULL,
		  AdjAllow MONEY NULL,
		  ReevalAmount MONEY NULL,
		  POS CHAR (2) NULL,
		  DxRefList VARCHAR (30) NULL,
		  TOS CHAR (2) NULL,
		  ReevalTxtPtr SMALLINT NULL,
		  FSAmount MONEY NULL,
		  UCAmount MONEY NULL,
		  CoPay MONEY NULL,
		  Deductible MONEY NULL,
		  CostToChargeRatio FLOAT NULL,
		  RXNumber VARCHAR (20) NULL,
		  DaysSupply SMALLINT NULL,
		  DxRef VARCHAR (4) NULL,
		  ExternalID VARCHAR (30) NULL,
		  ItemCostInvoiced MONEY NULL,
		  ItemCostAdditional MONEY NULL,
		  Refill CHAR (1) NULL,
		  ProvSecondaryID VARCHAR (30) NULL,
		  Certification CHAR (1) NULL,
		  ReevalTxtSrc VARCHAR (3) NULL,
		  BasisOfCost CHAR (1) NULL,
		  DMEFrequencyCode CHAR (1) NULL,
		  ProvRenderingNPI VARCHAR (10) NULL,
		  ProvSecondaryIDQualifier CHAR (2) NULL,
		  PaidProcCode VARCHAR (30) NULL,
		  PaidProcType VARCHAR (3) NULL,
		  URStatus CHAR (1) NULL,
		  URWorkflowStatus CHAR (1) NULL,
		  OverrideAllowUnits DECIMAL (11,3) NULL,
		  LineSeqOrgRev SMALLINT NULL,
		  ODGFlag SMALLINT NULL,
		  CompoundDrugIndicator CHAR (1) NULL,
		  PriorAuthNum VARCHAR (50) NULL,
		  ReevalParagraphJurisdiction CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.LineMod', 'U') IS NOT NULL 
	DROP TABLE stg.LineMod  
BEGIN
	CREATE TABLE stg.LineMod
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  LineSeq SMALLINT NULL,
		  ModSeq SMALLINT NULL,
		  UserEntered CHAR (1) NULL,
		  ModSiteCode CHAR (3) NULL,
		  Modifier VARCHAR (6) NULL,
		  ReductionCode SMALLINT NULL,
		  ModSubset CHAR (2) NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ReasonClientCode CHAR (4) NULL,
		  ReasonBillSeq INT NULL,
		  ReasonLineSeq SMALLINT NULL,
		  ReasonType CHAR (1) NULL,
		  ReasonValue VARCHAR (30) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.LineReduction', 'U') IS NOT NULL 
	DROP TABLE stg.LineReduction  
BEGIN
	CREATE TABLE stg.LineReduction
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  LineSeq SMALLINT NULL,
		  ReductionCode SMALLINT NULL,
		  ReductionAmount MONEY NULL,
		  OverrideAmount MONEY NULL,
		  ModUserID CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.MedicareICQM', 'U') IS NOT NULL 
	DROP TABLE stg.MedicareICQM  
BEGIN
	CREATE TABLE stg.MedicareICQM
		(
		  Jurisdiction CHAR (2) NULL,
		  MdicqmSeq INT NULL,
		  ProviderNum VARCHAR (6) NULL,
		  ProvSuffix CHAR (1) NULL,
		  ServiceCode VARCHAR (25) NULL,
		  HCPCS VARCHAR (5) NULL,
		  Revenue CHAR (3) NULL,
		  MedicareICQMDescription VARCHAR (40) NULL,
		  IP1995 INT NULL,
		  OP1995 INT NULL,
		  IP1996 INT NULL,
		  OP1996 INT NULL,
		  IP1997 INT NULL,
		  OP1997 INT NULL,
		  IP1998 INT NULL,
		  OP1998 INT NULL,
		  NPI VARCHAR (10) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Modifier', 'U') IS NOT NULL 
	DROP TABLE stg.Modifier  
BEGIN
	CREATE TABLE stg.Modifier
		(
		  Jurisdiction CHAR (2) NULL,
		  Code VARCHAR (6) NULL,
		  SiteCode CHAR (3) NULL,
		  Func CHAR (1) NULL,
		  Val CHAR (3) NULL,
		  ModType CHAR (1) NULL,
		  GroupCode CHAR (2) NULL,
		  ModDescription VARCHAR (30) NULL,
		  ModComment1 VARCHAR (70) NULL,
		  ModComment2 VARCHAR (70) NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  Statute VARCHAR (30) NULL,
		  Remark1 VARCHAR (6) NULL,
		  RemarkQualifier1 VARCHAR (2) NULL,
		  Remark2 VARCHAR (6) NULL,
		  RemarkQualifier2 VARCHAR (2) NULL,
		  Remark3 VARCHAR (6) NULL,
		  RemarkQualifier3 VARCHAR (2) NULL,
		  Remark4 VARCHAR (6) NULL,
		  RemarkQualifier4 VARCHAR (2) NULL,
		  CBREReasonID INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ODGData', 'U') IS NOT NULL 
	DROP TABLE stg.ODGData  
BEGIN
	CREATE TABLE stg.ODGData
		(
		  ICDDiagnosisID INT NULL,
		  ProcedureCode VARCHAR (30) NULL,
		  ICDDescription VARCHAR (300) NULL,
		  ProcedureDescription VARCHAR (800) NULL,
		  IncidenceRate MONEY NULL,
		  ProcedureFrequency MONEY NULL,
		  Visits25Perc SMALLINT NULL,
		  Visits50Perc SMALLINT NULL,
		  Visits75Perc SMALLINT NULL,
		  VisitsMean MONEY NULL,
		  CostsMean MONEY NULL,
		  AutoApprovalCode VARCHAR (5) NULL,
		  PaymentFlag SMALLINT NULL,
		  CostPerVisit MONEY NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Pend', 'U') IS NOT NULL 
	DROP TABLE stg.Pend  
BEGIN
	CREATE TABLE stg.Pend
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  PendSeq SMALLINT NULL,
		  PendDate DATETIME NULL,
		  ReleaseFlag CHAR (1) NULL,
		  PendToID VARCHAR (13) NULL,
		  Priority CHAR (1) NULL,
		  ReleaseDate DATETIME NULL,
		  ReasonCode VARCHAR (8) NULL,
		  PendByUserID CHAR (2) NULL,
		  ReleaseByUserID CHAR (2) NULL,
		  AutoPendFlag CHAR (1) NULL,
		  RuleID CHAR (5) NULL,
		  WFTaskSeq INT NULL,
		  ReleasedByExternalUserName VARCHAR (128) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Policy', 'U') IS NOT NULL 
	DROP TABLE stg.Policy  
BEGIN
	CREATE TABLE stg.Policy
		(
		  ClaimSysSubSet CHAR (4) NULL,
		  PolicySeq INT NULL,
		  Name VARCHAR (60) NULL,
		  ExternalID VARCHAR (20) NULL,
		  PolicyID VARCHAR (30) NULL,
		  AdminKey VARCHAR (40) NULL,
		  LocationCode VARCHAR (10) NULL,
		  Address1 VARCHAR (30) NULL,
		  Address2 VARCHAR (30) NULL,
		  City VARCHAR (20) NULL,
		  State CHAR (2) NULL,
		  Zip VARCHAR (9) NULL,
		  PhoneNum VARCHAR (20) NULL,
		  FaxNum VARCHAR (20) NULL,
		  EffectiveDate DATETIME NULL,
		  TerminationDate DATETIME NULL,
		  TIN VARCHAR (9) NULL,
		  StateTaxID VARCHAR (30) NULL,
		  DeptIndusRelNum VARCHAR (20) NULL,
		  EqOppIndicator CHAR (1) NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  MCOFlag CHAR (1) NULL,
		  MCOStartDate DATETIME NULL,
		  FeeRateCtrlEx CHAR (4) NULL,
		  CreateBy CHAR (2) NULL,
		  FeeRateCtrlIn CHAR (4) NULL,
		  CreateDate DATETIME NULL,
		  SelfInsured CHAR (1) NULL,
		  NAICSCode VARCHAR (15) NULL,
		  MonthlyPremium MONEY NULL,
		  PPOProfileSiteCode CHAR (3) NULL,
		  PPOProfileID INT NULL,
		  SalesTaxExempt CHAR (1) NULL,
		  ReceiptHandlingCode CHAR (1) NULL,
		  TxNonSubscrib CHAR (1) NULL,
		  SubdivisionName VARCHAR (60) NULL,
		  PolicyCoPayAmount MONEY NULL,
		  PolicyCoPayPct SMALLINT NULL,
		  PolicyDeductible MONEY NULL,
		  PolicyLimitAmount MONEY NULL,
		  PolicyTimeLimit SMALLINT NULL,
		  PolicyLimitWarningPct SMALLINT NULL,
		  PolicyLimitResult CHAR (1) NULL,
		  URProfileID VARCHAR (8) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.PPOContract', 'U') IS NOT NULL 
	DROP TABLE stg.PPOContract  
BEGIN
	CREATE TABLE stg.PPOContract
		(
		  PPONetworkID CHAR (2) NULL,
		  PPOContractID VARCHAR (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
		  SiteCode CHAR (3) NULL,
		  TIN VARCHAR (9) NULL,
		  AlternateTIN VARCHAR (9) NULL,
		  StartDate DATETIME NULL,
		  EndDate DATETIME NULL,
		  OPLineItemDefaultDiscount SMALLINT NULL,
		  CompanyName VARCHAR (35) NULL,
		  First VARCHAR (35) NULL,
		  GroupCode CHAR (3) NULL,
		  GroupName VARCHAR (40) NULL,
		  OPDiscountBaseValue CHAR (1) NULL,
		  OPOffFS SMALLINT NULL,
		  OPOffUCR SMALLINT NULL,
		  OPOffCharge SMALLINT NULL,
		  OPEffectiveDate DATETIME NULL,
		  OPAdditionalDiscountOffLink SMALLINT NULL,
		  OPTerminationDate DATETIME NULL,
		  OPUCRPercentile SMALLINT NULL,
		  OPCondition CHAR (2) NULL,
		  IPDiscountBaseValue CHAR (1) NULL,
		  IPOffFS SMALLINT NULL,
		  IPOffUCR SMALLINT NULL,
		  IPOffCharge SMALLINT NULL,
		  IPEffectiveDate DATETIME NULL,
		  IPTerminationDate DATETIME NULL,
		  IPCondition CHAR (2) NULL,
		  IPStopCapAmount MONEY NULL,
		  IPStopCapRate SMALLINT NULL,
		  MinDisc SMALLMONEY NULL,
		  MaxDisc SMALLMONEY NULL,
		  MedicalPerdiem SMALLMONEY NULL,
		  SurgicalPerdiem SMALLMONEY NULL,
		  ICUPerdiem SMALLMONEY NULL,
		  PsychiatricPerdiem SMALLMONEY NULL,
		  MiscParm CHAR (2) NULL,
		  SpcCode CHAR (1) NULL,
		  PPOType CHAR (1) NULL,
		  BillingAddress1 VARCHAR (30) NULL,
		  BillingAddress2 VARCHAR (30) NULL,
		  BillingCity VARCHAR (20) NULL,
		  BillingState CHAR (2) NULL,
		  BillingZip VARCHAR (9) NULL,
		  PracticeAddress1 VARCHAR (30) NULL,
		  PracticeAddress2 VARCHAR (30) NULL,
		  PracticeCity VARCHAR (20) NULL,
		  PracticeState CHAR (2) NULL,
		  PracticeZip VARCHAR (9) NULL,
		  PhoneNum VARCHAR (10) NULL,
		  OutFile VARCHAR (12) NULL,
		  InpatFile VARCHAR (12) NULL,
		  URCoordinatorFlag CHAR (1) NULL,
		  ExclusivePPOOrgFlag CHAR (1) NULL,
		  StopLossTypeCode VARCHAR (4) NULL,
		  BR_RNEDiscount SMALLINT NULL,
		  ModDate DATETIME NULL,
		  ExportFlag CHAR (1) NULL,
		  OPManualIndicator CHAR (1) NULL,
		  OPStopCapAmount MONEY NULL,
		  OPStopCapRate SMALLINT NULL,
		  Specialty1 VARCHAR (4) NULL,
		  Specialty2 VARCHAR (4) NULL,
		  LessorOfThreshold SMALLINT NULL,
		  BilateralDiscount SMALLINT NULL,
		  SurgeryDiscount2 SMALLINT NULL,
		  SurgeryDiscount3 SMALLINT NULL,
		  SurgeryDiscount4 SMALLINT NULL,
		  SurgeryDiscount5 SMALLINT NULL,
		  Matrix CHAR (1) NULL,
		  ProvType VARCHAR (5) NULL,
		  AllInclusive CHAR (1) NULL,
		  Region VARCHAR (4) NULL,
		  PaymentAddressFlag CHAR (1) NULL,
		  MedicalGroup CHAR (1) NULL,
		  MedicalGroupCode VARCHAR (4) NULL,
		  RateMode CHAR (1) NULL,
		  PracticeCounty VARCHAR (25) NULL,
		  FIPSCountyCode CHAR (3) NULL,
		  PrimaryCareFlag CHAR (1) NULL,
		  PPOContractIDOld VARCHAR (14) NULL,
		  MultiSurg CHAR (1) NULL,
		  BiLevel CHAR (1) NULL,
		  DRGRate SMALLMONEY NULL,
		  DRGGreaterThanBC SMALLINT NULL,
		  DRGMinPercentBC SMALLINT NULL,
		  CarveOut CHAR (1) NULL,
		  PPOtoFSSeq INT NULL,
		  LicenseNum VARCHAR (30) NULL,
		  MedicareNum VARCHAR (20) NULL,
		  NPI VARCHAR (10) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.PPONetwork', 'U') IS NOT NULL 
	DROP TABLE stg.PPONetwork  
BEGIN
	CREATE TABLE stg.PPONetwork
		(
		  PPONetworkID CHAR (2) NULL,
		  Name VARCHAR (30) NULL,
		  TIN VARCHAR (10) NULL,
		  Zip VARCHAR (10) NULL,
		  State CHAR (2) NULL,
		  City VARCHAR (15) NULL,
		  Street VARCHAR (30) NULL,
		  PhoneNum VARCHAR (20) NULL,
		  PPONetworkComment VARCHAR (6000) NULL,
		  AllowMaint CHAR (1) NULL,
		  ReqExtPPO CHAR (1) NULL,
		  DemoRates CHAR (1) NULL,
		  PrintAsProvider CHAR (1) NULL,
		  PPOType CHAR (3) NULL,
		  PPOVersion CHAR (1) NULL,
		  PPOBridgeExists CHAR (1) NULL,
		  UsesDrg CHAR (1) NULL,
		  PPOToOther CHAR (1) NULL,
		  SubNetworkIndicator CHAR (1) NULL,
		  EmailAddress VARCHAR (255) NULL,
		  WebSite VARCHAR (255) NULL,
		  BillControlSeq SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.PPOProfile', 'U') IS NOT NULL 
	DROP TABLE stg.PPOProfile  
BEGIN
	CREATE TABLE stg.PPOProfile
		(
		  SiteCode CHAR (3) NULL,
		  PPOProfileID INT NULL,
		  ProfileDesc VARCHAR (50) NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  SmartSearchPageMax SMALLINT NULL,
		  JurisdictionStackExclusive CHAR (1) NULL,
		  ReevalFullStackWhenOrigAllowNoHit CHAR (1) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.PPOProfileHistory', 'U') IS NOT NULL 
	DROP TABLE stg.PPOProfileHistory  
BEGIN
	CREATE TABLE stg.PPOProfileHistory
		(
		  PPOProfileHistorySeq BIGINT NULL,
		  RecordDeleted BIT NULL,
		  LogDateTime DATETIME NULL,
		  loginame NVARCHAR (256) NULL,
		  SiteCode CHAR (3) NULL,
		  PPOProfileID INT NULL,
		  ProfileDesc VARCHAR (50) NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  SmartSearchPageMax SMALLINT NULL,
		  JurisdictionStackExclusive CHAR (1) NULL,
		  ReevalFullStackWhenOrigAllowNoHit CHAR (1) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.PPOProfileNetworks', 'U') IS NOT NULL 
	DROP TABLE stg.PPOProfileNetworks  
BEGIN
	CREATE TABLE stg.PPOProfileNetworks
		(
		  PPOProfileSiteCode CHAR (3) NULL,
		  PPOProfileID INT NULL,
		  ProfileRegionSiteCode CHAR (3) NULL,
		  ProfileRegionID INT NULL,
		  NetworkOrder SMALLINT NULL,
		  PPONetworkID CHAR (2) NULL,
		  SearchLogic CHAR (1) NULL,
		  Verification CHAR (1) NULL,
		  EffectiveDate DATETIME NULL,
		  TerminationDate DATETIME NULL,
		  JurisdictionInd CHAR (1) NULL,
		  JurisdictionInsurerSeq INT NULL,
		  JurisdictionUseOnly CHAR (1) NULL,
		  PPOSSTinReq CHAR (1) NULL,
		  PPOSSLicReq CHAR (1) NULL,
		  DefaultExtendedSearches SMALLINT NULL,
		  DefaultExtendedFilters SMALLINT NULL,
		  SeveredTies CHAR (1) NULL,
		  POS VARCHAR (500) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.PPOProfileNetworksHistory', 'U') IS NOT NULL 
	DROP TABLE stg.PPOProfileNetworksHistory  
BEGIN
	CREATE TABLE stg.PPOProfileNetworksHistory
		(
		  PPOProfileNetworksHistorySeq BIGINT NULL,
		  RecordDeleted BIT NULL,
		  LogDateTime DATETIME NULL,
		  loginame NVARCHAR (256) NULL,
		  PPOProfileSiteCode CHAR (3) NULL,
		  PPOProfileID INT NULL,
		  ProfileRegionSiteCode CHAR (3) NULL,
		  ProfileRegionID INT NULL,
		  NetworkOrder SMALLINT NULL,
		  PPONetworkID CHAR (2) NULL,
		  SearchLogic CHAR (1) NULL,
		  Verification CHAR (1) NULL,
		  EffectiveDate DATETIME NULL,
		  TerminationDate DATETIME NULL,
		  JurisdictionInd CHAR (1) NULL,
		  JurisdictionInsurerSeq INT NULL,
		  JurisdictionUseOnly CHAR (1) NULL,
		  PPOSSTinReq CHAR (1) NULL,
		  PPOSSLicReq CHAR (1) NULL,
		  DefaultExtendedSearches SMALLINT NULL,
		  DefaultExtendedFilters SMALLINT NULL,
		  SeveredTies CHAR (1) NULL,
		  POS VARCHAR (500) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.PPORateType', 'U') IS NOT NULL 
	DROP TABLE stg.PPORateType  
BEGIN
	CREATE TABLE stg.PPORateType
		(
		  RateTypeCode CHAR (8) NULL,
		  PPONetworkID CHAR (2) NULL,
		  Category CHAR (1) NULL,
		  Priority CHAR (1) NULL,
		  VBColor SMALLINT NULL,
		  RateTypeDescription VARCHAR (70) NULL,
		  Explanation VARCHAR (6000) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.PPOSubNetwork', 'U') IS NOT NULL 
	DROP TABLE stg.PPOSubNetwork  
BEGIN
	CREATE TABLE stg.PPOSubNetwork
		(
		  PPONetworkID CHAR (2) NULL,
		  GroupCode CHAR (3) NULL,
		  GroupName VARCHAR (40) NULL,
		  ExternalID VARCHAR (30) NULL,
		  SiteCode CHAR (3) NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID VARCHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID VARCHAR (2) NULL,
		  Street1 VARCHAR (30) NULL,
		  Street2 VARCHAR (30) NULL,
		  City VARCHAR (15) NULL,
		  State CHAR (2) NULL,
		  Zip VARCHAR (10) NULL,
		  PhoneNum VARCHAR (20) NULL,
		  EmailAddress VARCHAR (255) NULL,
		  WebSite VARCHAR (255) NULL,
		  TIN VARCHAR (9) NULL,
		  Comment VARCHAR (4000) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ProfileRegion', 'U') IS NOT NULL 
	DROP TABLE stg.ProfileRegion  
BEGIN
	CREATE TABLE stg.ProfileRegion
		(
		  SiteCode CHAR (3) NULL,
		  ProfileRegionID INT NULL,
		  RegionTypeCode CHAR (2) NULL,
		  RegionName VARCHAR (50) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ProfileRegionDetail', 'U') IS NOT NULL 
	DROP TABLE stg.ProfileRegionDetail  
BEGIN
	CREATE TABLE stg.ProfileRegionDetail
		(
		  ProfileRegionSiteCode CHAR (3) NULL,
		  ProfileRegionID INT NULL,
		  ZipCodeFrom CHAR (5) NULL,
		  ZipCodeTo CHAR (5) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Provider', 'U') IS NOT NULL 
	DROP TABLE stg.Provider  
BEGIN
	CREATE TABLE stg.Provider
		(
		  ProviderSubSet CHAR (4) NULL,
		  ProviderSeq BIGINT NULL,
		  TIN VARCHAR (9) NULL,
		  TINSuffix VARCHAR (6) NULL,
		  ExternalID VARCHAR (30) NULL,
		  Name VARCHAR (50) NULL,
		  GroupCode VARCHAR (5) NULL,
		  LicenseNum VARCHAR (30) NULL,
		  MedicareNum VARCHAR (20) NULL,
		  PracticeAddressSeq INT NULL,
		  BillingAddressSeq INT NULL,
		  HospitalSeq INT NULL,
		  ProvType CHAR (3) NULL,
		  Specialty1 VARCHAR (8) NULL,
		  Specialty2 VARCHAR (8) NULL,
		  CreateUserID CHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  Status CHAR (1) NULL,
		  ExternalStatus CHAR (1) NULL,
		  ExportDate DATETIME NULL,
		  SsnTinIndicator CHAR (1) NULL,
		  PmtDays SMALLINT NULL,
		  AuthBeginDate DATETIME NULL,
		  AuthEndDate DATETIME NULL,
		  TaxAddressSeq INT NULL,
		  CtrlNum1099 VARCHAR (4) NULL,
		  SurchargeCode CHAR (1) NULL,
		  WorkCompNum VARCHAR (18) NULL,
		  WorkCompState CHAR (2) NULL,
		  NCPDPID VARCHAR (10) NULL,
		  EntityType CHAR (1) NULL,
		  LastName VARCHAR (35) NULL,
		  FirstName VARCHAR (25) NULL,
		  MiddleName VARCHAR (25) NULL,
		  Suffix VARCHAR (10) NULL,
		  NPI VARCHAR (10) NULL,
		  FacilityNPI VARCHAR (10) NULL,
		  VerificationGroupID VARCHAR (30) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ProviderAddress', 'U') IS NOT NULL 
	DROP TABLE stg.ProviderAddress  
BEGIN
	CREATE TABLE stg.ProviderAddress
		(
		  ProviderSubSet CHAR (4) NULL,
		  ProviderAddressSeq INT NULL,
		  RecType CHAR (2) NULL,
		  Address1 VARCHAR (30) NULL,
		  Address2 VARCHAR (30) NULL,
		  City VARCHAR (30) NULL,
		  State CHAR (2) NULL,
		  Zip VARCHAR (9) NULL,
		  PhoneNum VARCHAR (20) NULL,
		  FaxNum VARCHAR (20) NULL,
		  ContactFirstName VARCHAR (20) NULL,
		  ContactLastName VARCHAR (20) NULL,
		  ContactMiddleInitial CHAR (1) NULL,
		  URFirstName VARCHAR (20) NULL,
		  URLastName VARCHAR (20) NULL,
		  URMiddleInitial CHAR (1) NULL,
		  FacilityName VARCHAR (30) NULL,
		  CountryCode CHAR (3) NULL,
		  MailCode VARCHAR (20) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ProviderCluster', 'U') IS NOT NULL
    DROP TABLE stg.ProviderCluster;
BEGIN
    CREATE TABLE stg.ProviderCluster
        (
			ProviderSubSet CHAR(4)  NULL,
			ProviderSeq BIGINT  NULL, 
			OrgOdsCustomerId INT  NULL,
			MitchellProviderKey VARCHAR(200) NULL,
			ProviderClusterKey VARCHAR(200) NULL,
			ProviderType VARCHAR(30) NULL,
			DmlOperation CHAR(1) NOT NULL
        )
END
GO

IF OBJECT_ID('stg.ProviderSpecialty', 'U') IS NOT NULL 
	DROP TABLE stg.ProviderSpecialty  
BEGIN
	CREATE TABLE stg.ProviderSpecialty
		(
		  Id UNIQUEIDENTIFIER NULL,
		  Description NVARCHAR (MAX) NULL,
		  ImplementationDate SMALLDATETIME NULL,
		  DeactivationDate SMALLDATETIME NULL,
		  DataSource UNIQUEIDENTIFIER NULL,
		  Creator NVARCHAR (128) NULL,
		  CreateDate SMALLDATETIME NULL,
		  LastUpdater NVARCHAR (128) NULL,
		  LastUpdateDate SMALLDATETIME NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ProviderSys', 'U') IS NOT NULL 
	DROP TABLE stg.ProviderSys  
BEGIN
	CREATE TABLE stg.ProviderSys
		(
		  ProviderSubset CHAR (4) NULL,
		  ProviderSubSetDesc VARCHAR (30) NULL,
		  ProviderAccess CHAR (1) NULL,
		  TaxAddrRequired CHAR (1) NULL,
		  AllowDummyProviders CHAR (1) NULL,
		  CascadeUpdatesOnImport CHAR (1) NULL,
		  RootExtIDOverrideDelimiter CHAR (1) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.ReductionType', 'U') IS NOT NULL 
	DROP TABLE stg.ReductionType  
BEGIN
	CREATE TABLE stg.ReductionType
		(
		  ReductionCode SMALLINT NULL,
		  ReductionDescription VARCHAR (50) NULL,
		  BEOverride CHAR (1) NULL,
		  BEMsg CHAR (1) NULL,
		  Abbreviation VARCHAR (8) NULL,
		  DefaultMessageCode VARCHAR (6) NULL,
		  DefaultDenialMessageCode VARCHAR (6) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.Region', 'U') IS NOT NULL 
	DROP TABLE stg.Region  
BEGIN
	CREATE TABLE stg.Region
		(
		  Jurisdiction CHAR (2) NULL,
		  Extension CHAR (3) NULL,
		  EndZip CHAR (5) NULL,
		  Beg VARCHAR (5) NULL,
		  Region SMALLINT NULL,
		  RegionDescription VARCHAR (4) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.TableLookUp', 'U') IS NOT NULL
DROP TABLE stg.TableLookUp
BEGIN
	CREATE TABLE stg.TableLookUp (
	   TableCode CHAR(4) NOT NULL,
       TypeCode CHAR(4) NOT NULL,
       Code CHAR(12) NOT NULL,
       SiteCode CHAR(3) NOT NULL,
       OldCode VARCHAR(12) NULL,
       ShortDesc VARCHAR(40) NULL,
       Source CHAR(1) NULL,
       Priority SMALLINT NULL,
       LongDesc VARCHAR(6000) NULL,
       OwnerApp CHAR(1) NULL,
       RecordStatus CHAR(1) NULL,
	   CreateDate DATETIME NULL,
	   CreateUserID CHAR(2) NULL,
	   ModDate DATETIME NULL,
	   ModUserID VARCHAR(2) NULL,
	   DmlOperation CHAR(1) NOT NULL
		)
END
GO
IF OBJECT_ID('stg.UserInfo', 'U') IS NOT NULL 
	DROP TABLE stg.UserInfo  
BEGIN
	CREATE TABLE stg.UserInfo
		(
		  UserID CHAR (2) NULL,
		  UserPassword VARCHAR (35) NULL,
		  Name VARCHAR (30) NULL,
		  SecurityLevel CHAR (1) NULL,
		  EnableAdjusterMenu CHAR (1) NULL,
		  EnableProvAdds CHAR (1) NULL,
		  AllowPosting CHAR (1) NULL,
		  EnableClaimAdds CHAR (1) NULL,
		  EnablePolicyAdds CHAR (1) NULL,
		  EnableInvoiceCreditVoid CHAR (1) NULL,
		  EnableReevaluations CHAR (1) NULL,
		  EnablePPOAccess CHAR (1) NULL,
		  EnableURCommentView CHAR (1) NULL,
		  EnablePendRelease CHAR (1) NULL,
		  EnableXtableUpdate CHAR (1) NULL,
		  CreateUserID CHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  EnablePPOFastMatchAdds CHAR (1) NULL,
		  ExternalID VARCHAR (30) NULL,
		  EmailAddress VARCHAR (255) NULL,
		  EmailNotify CHAR (1) NULL,
		  ActiveStatus CHAR (1) NULL,
		  CompanySeq SMALLINT NULL,
		  NetworkLogin VARCHAR (50) NULL,
		  AutomaticNetworkLogin CHAR (1) NULL,
		  LastLoggedInDate DATETIME NULL,
		  PromptToCreateMCC CHAR (1) NULL,
		  AccessAllWorkQueues CHAR (1) NULL,
		  LandingZoneAccess CHAR (1) NULL,
		  ReviewLevel TINYINT NULL,
		  EnableUserMaintenance CHAR (1) NULL,
		  EnableHistoryMaintenance CHAR (1) NULL,
		  EnableClientMaintenance CHAR (1) NULL,
		  FeeAccess CHAR (1) NULL,
		  EnableSalesTaxMaintenance CHAR (1) NULL,
		  BESalesTaxZipCodeAccess CHAR (1) NULL,
		  InvoiceGenAccess CHAR (1) NULL,
		  BEPermitAllowOver CHAR (1) NULL,
		  PermitRereviews CHAR (1) NULL,
		  EditBillControl CHAR (1) NULL,
		  RestrictEORNotes CHAR (1) NULL,
		  UWQAutoNextBill CHAR (1) NULL,
		  UWQDisableOptions CHAR (1) NULL,
		  UWQDisableRules CHAR (1) NULL,
		  PermitCheckReissue CHAR (1) NULL,
		  EnableEDIAutomationMaintenance CHAR (1) NULL,
		  RestrictDiaryNotes CHAR (1) NULL,
		  RestrictExternalDiaryNotes CHAR (1) NULL,
		  BEDeferManualModeMsg CHAR (1) NULL,
		  UserRoleID INT NULL,
		  EraseBillTempHistory CHAR (1) NULL,
		  EditPPOProfile CHAR (1) NULL,
		  EnableUrAccess CHAR (1) NULL,
		  CapstoneConfigurationAccess CHAR (1) NULL,
		  PermitUDFDefinition CHAR (1) NULL,
		  EnablePPOProfileEdit CHAR (1) NULL,
		  EnableSupervisorRole CHAR (1) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.WFlow', 'U') IS NOT NULL 
	DROP TABLE stg.WFlow  
BEGIN
	CREATE TABLE stg.WFlow
		(
		  WFlowSeq INT NULL,
		  Description VARCHAR (50) NULL,
		  RecordStatus CHAR (1) NULL,
		  EntityTypeCode CHAR (2) NULL,
		  CreateUserID CHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  InitialTaskSeq INT NULL,
		  PauseTaskSeq INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.WFQueue', 'U') IS NOT NULL 
	DROP TABLE stg.WFQueue  
BEGIN
	CREATE TABLE stg.WFQueue
		(
		  EntityTypeCode CHAR (2) NULL,
		  EntitySubset CHAR (4) NULL,
		  EntitySeq BIGINT NULL,
		  WFTaskSeq INT NULL,
		  PriorWFTaskSeq INT NULL,
		  Status CHAR (1) NULL,
		  Priority CHAR (1) NULL,
		  CreateUserID CHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  TaskMessage VARCHAR (500) NULL,
		  Parameter1 VARCHAR (35) NULL,
		  ContextID VARCHAR (256) NULL,
		  PriorStatus CHAR (1) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.WFTask', 'U') IS NOT NULL 
	DROP TABLE stg.WFTask  
BEGIN
	CREATE TABLE stg.WFTask
		(
		  WFTaskSeq INT NULL,
		  WFLowSeq INT NULL,
		  WFTaskRegistrySeq INT NULL,
		  Name VARCHAR (35) NULL,
		  Parameter1 VARCHAR (35) NULL,
		  RecordStatus CHAR (1) NULL,
		  NodeLeft NUMERIC (8,2) NULL,
		  NodeTop NUMERIC (8,2) NULL,
		  CreateUserID CHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  NoPrior CHAR (1) NULL,
		  NoRestart CHAR (1) NULL,
		  ParameterX VARCHAR (2000) NULL,
		  DefaultPendGroup VARCHAR (12) NULL,
		  Configuration NVARCHAR (2000) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.WFTaskLink', 'U') IS NOT NULL 
	DROP TABLE stg.WFTaskLink  
BEGIN
	CREATE TABLE stg.WFTaskLink
		(
		  FromTaskSeq INT NULL,
		  LinkWhen SMALLINT NULL,
		  ToTaskSeq INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

IF OBJECT_ID('stg.WFTaskRegistry', 'U') IS NOT NULL 
	DROP TABLE stg.WFTaskRegistry  
BEGIN
	CREATE TABLE stg.WFTaskRegistry
		(
		  WFTaskRegistrySeq INT NULL,
		  EntityTypeCode CHAR (2) NULL,
		  Description VARCHAR (50) NULL,
		  Action VARCHAR (50) NULL,
		  SmallImageResID INT NULL,
		  LargeImageResID INT NULL,
		  PersistBefore CHAR (1) NULL,
		  NAction VARCHAR (512) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'adm.AppVersion')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'This table stores a record for each version deployed to the database, along with the date and time of deployment',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.AppVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'AppVersionId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key; Identity',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.AppVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'AppVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'ODS version; the forrmat is x.x.x[.x]',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersion' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.AppVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'AppVersionDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The date and time this record was inserted into the AppVersion table',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Audit table that tracks the status of a posting group load',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key.  Identity.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'OltpPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OltpPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key associated with the posting group on the source OLTP database.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OltpPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Posting Group',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'Status' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Status' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Status of posting group load.  FI means load was completed successfully.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Status' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'DataExtractTypeId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'When true, it means the posting group contains incremental data extracts.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Acs Ods version at the time this record was queued.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsVersion' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'SnapshotCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SnapshotCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The date and time the snapshot from which the data was extracted was created on the souce server (typically the source secondary server)',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SnapshotCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Delete Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'SnapshotDropDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SnapshotDropDate' --Column Name


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CoreDBVersionId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CoreDBVersionId' --Column Name


EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The Server Core Database siteinfoseq used to track changes in the core database.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CoreDBVersionId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time the record was added.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LastChangeDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time the record was last inserted or updated.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Audit table that tracks the status of each table load',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key.  Identity.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Process',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'Status' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Status' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Status of load.  When FI, load is complete.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Status' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ExtractRowCount' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ExtractRowCount' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Number of records loaded into stg table (staging)',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ExtractRowCount' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'UpdateRowCount' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'UpdateRowCount' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Number of records updated in stg table (staging)',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'UpdateRowCount' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LoadRowCount' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadRowCount' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Number of records loaaded into src table',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadRowCount' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ExtractDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ExtractDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time data was loaded into stg table',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ExtractDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LastUpdateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastUpdateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Data and time record was last inserted or updated',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastUpdateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LoadDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time data was loaded into src table',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time record was created',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LastChangeDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Data and time record was last inserted or updated',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillControl')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillControl', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillControl', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillControl')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillControl', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillControl', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillControl')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillControl', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillControl', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillControl')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillControl', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillControl', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillControl')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillControl', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillControl', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillControl')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillControl', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillControl', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BillControl')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillControl', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BillControl', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.EntityType')
		AND ep.name = N'MS_Description'
		AND c.name = N'EntityTypeKey' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'EntityType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'EntityTypeKey' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Key Column has been renamed in the ods as EntityTypeKey since it is a reerved keyword.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'EntityType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'EntityTypeKey' --Column Name


GO