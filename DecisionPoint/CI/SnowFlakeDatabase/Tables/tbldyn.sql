CREATE TABLE IF NOT EXISTS adm.App_Version (
	  App_Version_Id NUMBER(10,0) NOT NULL IDENTITY(1,1)
	, App_Version VARCHAR(10) NULL
	, App_Version_Date DATETIME NULL
	, PRIMARY KEY (APP_VERSION_ID)
);

CREATE TABLE IF NOT EXISTS adm.Error_Log
(
	Object_Audit_Key INT NOT NULL COMMENT 'Key of object that generated error Ex. ProcessAuditId, will be -1 if error is at Master procedure level',
	Event_Id  INT NOT NULL COMMENT 'Event Id from Event table',
	Error_Message STRING NULL COMMENT 'Error message associated with event Ex. if primary key violation then this will be the keys in violation',
	Log_Date  DATETIME NOT NULL COMMENT 'When the error occured'

);


CREATE TABLE IF NOT EXISTS ADM.POSTING_GROUP_INJEST_AUDIT
(
	Posting_Group_Audit_Id INT NOT NULL IDENTITY(1,1) COMMENT 'Identity key generated per control file',
	Ods_Cutoff_Posting_Group_Audit_Id INT NOT NULL COMMENT 'Last ods posting group coming from ods',      
	Current_Replication_Id INT NOT NULL COMMENT 'Identity value generated per extraction on ODS side to detect gaps between consecutive posting groups',			  
	Status CHAR(2) NOT NULL COMMENT 'Load Status (S=Start,FI=Finished,Er=Error)',                          
	Injest_Type_Id INT NOT NULL COMMENT 'Full,incremental',                     
	Ods_Version VARCHAR(10) NULL COMMENT 'Current Ods Version',                   
	Snapshot_Date DATETIME NULL COMMENT 'Snapshot Date of load (Create date of control file)',                     
	Create_Date DATETIME NOT NULL COMMENT 'Snapshot Date of load (Create date of control file)' ,                 
	Last_Change_Date DATETIME NOT NULL COMMENT 'Last milestone checkpoint' ,
	PRIMARY KEY(Posting_Group_Audit_Id)
);

CREATE TABLE IF NOT EXISTS ADM.PROCESS_FILE_AUDIT 
(
	Process_File_Audit_Id INT NOT NULL IDENTITY(1,1) COMMENT 'Identity key',
	Process_Audit_Id  INT NOT NULL COMMENT 'Foreign key which is used to refer to ADM.PROCESS_INJEST_AUDIT',							
	File_Number  INT NOT NULL COMMENT 'From Control file',					
	Status  CHAR(2) NOT NULL COMMENT 'Load Status (S=Start,FI=Finished,Er=Error)',							
	Total_Records_In_File INT NULL COMMENT 'Total number of records in the file',				
	Total_Records_Extracted INT NULL COMMENT 'Total number of records extracted to the table',					
	Total_Records_With_Errors INT NULL COMMENT 'Total number of records with errors',		
	Load_Date DATETIME NULL COMMENT 'When file load starts',						
	Create_Date DATETIME NOT NULL COMMENT 'When file load starts',				
	Last_Change_Date DATETIME NOT NULL COMMENT 'last status update',
	PRIMARY KEY(Process_File_Audit_Id)
);

CREATE TABLE IF NOT EXISTS ADM.PROCESS_INJEST_AUDIT 
(
	Process_Audit_Id INT NOT NULL IDENTITY(1,1) COMMENT 'Identity key generated when process starts',
	Posting_Group_Audit_Id INT NOT NULL COMMENT 'Foreign key which is used to refer to ADM.POSTING_GROUP_INJEST_AUDIT',						              
	Process_Id INT NOT NULL COMMENT 'The identity value in adm.process for the table we are loading',							                  
	Status CHAR(2) NOT NULL COMMENT 'Load Status (S=Start,FI=Finished,Er=Error)',	
	Total_Records_In_Source BIGINT NULL COMMENT 'Total Number of records reported by source system in countrol file',
	Total_Number_Of_Files INT NULL COMMENT 'Total number of files',					 
	Total_Records_Extracted INT NULL COMMENT 'Total number of records extracted. Sum from all files.',				
	Total_Records_Loaded INT NULL COMMENT 'Total number of records loaded to the target',					
	Total_Records_Updated INT NULL COMMENT 'Total number of records updated. Sum from all files.',				
	Load_Date  DATETIME NULL COMMENT 'When Last file was loaded',						
	Update_Date DATETIME NULL COMMENT 'When records updated',					
	Create_Date DATETIME NOT NULL COMMENT 'When First File is started',					
	Last_Change_Date DATETIME NOT NULL COMMENT 'Last Change of status ( last milesstone)',
	PRIMARY KEY(Process_Audit_Id)
);

-- ADD NEW COLUMN Total_Records_In_Source
CALL ADM.ALTER_COLUMN(
    'ADD', 
    'ADM', 
    'PROCESS_INJEST_AUDIT', 
    'Total_Records_In_Source',
    'BIGINT', 
    'NULL',
    'Total Number of records reported by source system in countrol file'
);
CREATE TABLE IF NOT EXISTS adm_oltp.Error_Log
(
	Object_Audit_Key INT NOT NULL COMMENT 'Key of object that generated error Ex. ProcessAuditId, will be -1 if error is at Master procedure level',
	Event_Id  INT NOT NULL COMMENT 'Event Id from Event table',
	Error_Message STRING NULL COMMENT 'Error message associated with event Ex. if primary key violation then this will be the keys in violation',
	Log_Date  DATETIME NOT NULL COMMENT 'When the error occured'

);
CREATE TABLE IF NOT EXISTS ADM_OLTP.POSTING_GROUP_AUDIT
(
	Posting_Group_Audit_Id INT NOT NULL IDENTITY(1,1) COMMENT 'Primary key.Identity.',
	Oltp_Posting_Group_Audit_Id INT NOT NULL COMMENT 'Primary key associated with the posting group on the source OLTP database.',      
	Posting_Group_Id INT NOT NULL COMMENT 'FK to Posting Group',
	Customer_Id INT NOT NULL COMMENT 'FK to Customer',	
	Status CHAR(2) NOT NULL COMMENT 'Status of posting group load.  FI means load was completed successfully.' ,                 
	Data_Extract_Type_Id INT NOT NULL COMMENT 'When true, it means the posting group contains incremental data extracts.',                    
	Ods_Version VARCHAR(10) NULL COMMENT 'Acs Ods version at the time this record was queued.',                   
	Snapshot_Date DATETIME NULL COMMENT 'The date and time the snapshot from which the data was extracted was created on the source server (typically the source secondary server)',
    Snapshot_Drop_Date DATETIME NULL	COMMENT 'The date and time the snapshot was dropped.',
	Create_Date DATETIME NOT NULL COMMENT 'Date and time the record was added.',               
	Last_Change_Date DATETIME NOT NULL COMMENT 'Date and time the record was last inserted or updated.' ,
	PRIMARY KEY(Posting_Group_Audit_Id)
);	

CREATE TABLE IF NOT EXISTS ADM_OLTP.PROCESS_AUDIT 
(
	Process_Audit_Id INT NOT NULL IDENTITY(1,1) COMMENT 'Primary key.Identity.',
	Posting_Group_Audit_Id INT NOT NULL COMMENT 'FK to Posting_Group_Audit',						              
	Process_Id INT NOT NULL COMMENT 'FK to Process',							                  
	Status CHAR(2)  NOT NULL COMMENT 'Status of load.  When FI, load is complete.',	
	Total_Records_In_Source BIGINT NULL COMMENT 'Total Number of records reported by source system in control file',
	Total_Records_In_Target INT NULL COMMENT 'Total Number of records in the Ods',				
	Total_Deleted_Records INT NULL COMMENT 'Total Number of records delete from the source',				
	Control_Row_Count INT NULL COMMENT 'Total Number of records reported by source for each Posting group',
	Extract_Row_Count INT NULL COMMENT 'Number of records loaded into stg table (staging)',
    Update_Row_Count INT NULL COMMENT 'Number of records updated in stg table (staging)',
    Load_Row_Count INT  NULL  COMMENT 'Number of records loaaded into src table',		
	Extract_Date  DATETIME NULL COMMENT 'Date and time data was loaded into stg table',						
	Last_Update_Date DATETIME NULL COMMENT 'Data and time record was last inserted or updated',
	Load_Date	DATETIME NULL COMMENT 'Date and time data was loaded into src table',
	Create_Date DATETIME NOT NULL COMMENT 'Date and time record was created',				
	Last_Change_Date DATETIME NOT NULL COMMENT 'Data and time record was last inserted or updated',
	PRIMARY KEY(Process_Audit_Id)
);
CREATE TABLE IF NOT EXISTS ADM_OLTP.PROCESS_FILE_AUDIT 
(
	Process_File_Audit_Id INT NOT NULL IDENTITY(1,1) COMMENT 'Identity key',
	Process_Audit_Id  INT NOT NULL COMMENT 'Foreign key which is used to refer to ADM.PROCESS_INJEST_AUDIT',							
	File_Number  INT NOT NULL COMMENT 'From Control file',					
	Status  CHAR(2) NOT NULL COMMENT 'Load Status (S=Start,FI=Finished,Er=Error)',							
	Total_Records_In_File INT NULL COMMENT 'Total number of records in the file',				
	Total_Records_Extracted INT NULL COMMENT 'Total number of records extracted to the table',					
	Total_Records_With_Errors INT NULL COMMENT 'Total number of records with errors',		
	Load_Date DATETIME NULL COMMENT 'When file load starts',						
	Create_Date DATETIME NOT NULL COMMENT 'When file load starts',				
	Last_Change_Date DATETIME NOT NULL COMMENT 'last status update',
	PRIMARY KEY(Process_File_Audit_Id)
);CREATE TABLE IF NOT EXISTS rpt.PostingGroupAudit (
	  PostingGroupAuditId NUMBER(10, 0) NOT NULL
	, OltpPostingGroupAuditId NUMBER(10, 0) NOT NULL
	, PostingGroupId NUMBER(3, 0) NOT NULL
	, CustomerId NUMBER(10, 0) NOT NULL
	, Status VARCHAR(2) NOT NULL
	, DataExtractTypeId NUMBER(10, 0) NOT NULL
	, OdsVersion VARCHAR(10) NULL
	, SnapshotCreateDate DATETIME NULL
	, SnapshotDropDate DATETIME NULL
	, CreateDate DATETIME NOT NULL
	, LastChangeDate DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS rpt.ProcessAudit (
	  ProcessAuditId NUMBER(10, 0) NOT NULL
	, PostingGroupAuditId NUMBER(10, 0) NOT NULL
	, ProcessId NUMBER(5, 0) NOT NULL
	, Status VARCHAR(2) NOT NULL
	, TotalRecordsInSource NUMBER(19, 0) NULL
	, TotalRecordsInTarget NUMBER(19, 0) NULL
	, TotalDeletedRecords NUMBER(10, 0) NULL
	, ControlRowCount NUMBER(10, 0) NULL
	, ExtractRowCount NUMBER(10, 0) NULL
	, UpdateRowCount NUMBER(10, 0) NULL
	, LoadRowCount NUMBER(10, 0) NULL
	, ExtractDate DATETIME NULL
	, LastUpdateDate DATETIME NULL
	, LoadDate DATETIME NULL
	, CreateDate DATETIME NOT NULL
	, LastChangeDate DATETIME NOT NULL
);

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

CREATE TABLE IF NOT EXISTS src.Adjustment3603rdPartyEndNoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.Adjustment360ApcEndNoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.Adjustment360Category (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Adjustment360CategoryId NUMBER(10, 0) NOT NULL
	 , Name VARCHAR(50) NULL
);

CREATE TABLE IF NOT EXISTS src.Adjustment360EndNoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId NUMBER(10, 0) NULL
	 , EndnoteTypeId NUMBER(3, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.Adjustment360OverrideEndNoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.Adjustment360SubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Adjustment360SubCategoryId NUMBER(10, 0) NOT NULL
	 , Name VARCHAR(50) NULL
	 , Adjustment360CategoryId NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.Adjustment3rdPartyEndnoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId VARCHAR(100) NULL
);

CREATE TABLE IF NOT EXISTS src.AdjustmentApcEndNoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId VARCHAR(100) NULL
);

CREATE TABLE IF NOT EXISTS src.AdjustmentEndNoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId VARCHAR(100) NULL
);

CREATE TABLE IF NOT EXISTS src.AdjustmentOverrideEndNoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId VARCHAR(100) NULL
);

CREATE TABLE IF NOT EXISTS src.Adjustor (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , lAdjIdNo NUMBER(10, 0) NOT NULL
	 , IDNumber VARCHAR(15) NULL
	 , Lastname VARCHAR(30) NULL
	 , FirstName VARCHAR(30) NULL
	 , Address1 VARCHAR(30) NULL
	 , Address2 VARCHAR(30) NULL
	 , City VARCHAR(30) NULL
	 , State VARCHAR(2) NULL
	 , ZipCode VARCHAR(12) NULL
	 , Phone VARCHAR(25) NULL
	 , Fax VARCHAR(25) NULL
	 , Office VARCHAR(120) NULL
	 , EMail VARCHAR(60) NULL
	 , InUse VARCHAR(100) NULL
	 , OfficeIdNo NUMBER(10, 0) NULL
	 , UserId NUMBER(10, 0) NULL
	 , CreateDate DATETIME NULL
	 , LastChangedOn DATETIME NULL
);

CREATE TABLE IF NOT EXISTS src.AnalysisGroup (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , AnalysisGroupId NUMBER(10, 0) NOT NULL
	 , GroupName VARCHAR(200) NULL
);

CREATE TABLE IF NOT EXISTS src.AnalysisRule (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , AnalysisRuleId NUMBER(10, 0) NOT NULL
	 , Title VARCHAR(200) NULL
	 , AssemblyQualifiedName VARCHAR(200) NULL
	 , MethodToInvoke VARCHAR(50) NULL
	 , DisplayMessage VARCHAR(200) NULL
	 , DisplayOrder NUMBER(10, 0) NULL
	 , IsActive BOOLEAN NULL
	 , CreateDate TIMESTAMP_LTZ(7) NULL
	 , LastChangedOn TIMESTAMP_LTZ(7) NULL
	 , MessageToken VARCHAR(200) NULL
);

CREATE TABLE IF NOT EXISTS src.AnalysisRuleGroup (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , AnalysisRuleGroupId NUMBER(10, 0) NOT NULL
	 , AnalysisRuleId NUMBER(10, 0) NULL
	 , AnalysisGroupId NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.AnalysisRuleThreshold (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , AnalysisRuleThresholdId NUMBER(10, 0) NOT NULL
	 , AnalysisRuleId NUMBER(10, 0) NULL
	 , ThresholdKey VARCHAR(50) NULL
	 , ThresholdValue VARCHAR(100) NULL
	 , CreateDate TIMESTAMP_LTZ(7) NULL
	 , LastChangedOn TIMESTAMP_LTZ(7) NULL
);

CREATE TABLE IF NOT EXISTS src.ApportionmentEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ApportionmentEndnote NUMBER(10, 0) NOT NULL
	 , ShortDescription VARCHAR(50) NULL
	 , LongDescription VARCHAR(500) NULL
);

CREATE TABLE IF NOT EXISTS src.BillAdjustment (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillLineAdjustmentId NUMBER(19, 0) NOT NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , LineNumber NUMBER(10, 0) NULL
	 , Adjustment NUMBER(19, 4) NULL
	 , EndNote NUMBER(10, 0) NULL
	 , EndNoteTypeId NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.BillApportionmentEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillId NUMBER(10, 0) NOT NULL
	 , LineNumber NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.BillCustomEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillId NUMBER(10, 0) NOT NULL
	 , LineNumber NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.BillExclusionLookUpTable (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReportID NUMBER(3, 0) NOT NULL
	 , ReportName VARCHAR(100) NULL
);

CREATE TABLE IF NOT EXISTS src.BILLS (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER(10, 0) NOT NULL
	 , LINE_NO NUMBER(5, 0) NOT NULL
	 , LINE_NO_DISP NUMBER(5, 0) NULL
	 , OVER_RIDE NUMBER(5, 0) NULL
	 , DT_SVC DATETIME NULL
	 , PRC_CD VARCHAR(7) NULL
	 , UNITS FLOAT(24) NULL
	 , TS_CD VARCHAR(14) NULL
	 , CHARGED NUMBER(19, 4) NULL
	 , ALLOWED NUMBER(19, 4) NULL
	 , ANALYZED NUMBER(19, 4) NULL
	 , REASON1 NUMBER(10, 0) NULL
	 , REASON2 NUMBER(10, 0) NULL
	 , REASON3 NUMBER(10, 0) NULL
	 , REASON4 NUMBER(10, 0) NULL
	 , REASON5 NUMBER(10, 0) NULL
	 , REASON6 NUMBER(10, 0) NULL
	 , REASON7 NUMBER(10, 0) NULL
	 , REASON8 NUMBER(10, 0) NULL
	 , REF_LINE_NO NUMBER(5, 0) NULL
	 , SUBNET VARCHAR(9) NULL
	 , OverrideReason NUMBER(5, 0) NULL
	 , FEE_SCHEDULE NUMBER(19, 4) NULL
	 , POS_RevCode VARCHAR(4) NULL
	 , CTGPenalty NUMBER(19, 4) NULL
	 , PrePPOAllowed NUMBER(19, 4) NULL
	 , PPODate DATETIME NULL
	 , PPOCTGPenalty NUMBER(19, 4) NULL
	 , UCRPerUnit NUMBER(19, 4) NULL
	 , FSPerUnit NUMBER(19, 4) NULL
	 , HCRA_Surcharge NUMBER(19, 4) NULL
	 , EligibleAmt NUMBER(19, 4) NULL
	 , DPAllowed NUMBER(19, 4) NULL
	 , EndDateOfService DATETIME NULL
	 , AnalyzedCtgPenalty NUMBER(19, 4) NULL
	 , AnalyzedCtgPpoPenalty NUMBER(19, 4) NULL
	 , RepackagedNdc VARCHAR(13) NULL
	 , OriginalNdc VARCHAR(13) NULL
	 , UnitOfMeasureId NUMBER(3, 0) NULL
	 , PackageTypeOriginalNdc VARCHAR(2) NULL
	 , ServiceCode VARCHAR(25) NULL
	 , PreApportionedAmount NUMBER(19, 4) NULL
	 , DeductibleApplied NUMBER(19, 4) NULL
	 , BillReviewResults NUMBER(19, 4) NULL
	 , PreOverriddenDeductible NUMBER(19, 4) NULL
	 , RemainingBalance NUMBER(19, 4) NULL
	 , CtgCoPayPenalty NUMBER(19, 4) NULL
	 , PpoCtgCoPayPenalty NUMBER(19, 4) NULL
	 , AnalyzedCtgCoPayPenalty NUMBER(19, 4) NULL
	 , AnalyzedPpoCtgCoPayPenalty NUMBER(19, 4) NULL
	 , CtgVunPenalty NUMBER(19, 4) NULL
	 , PpoCtgVunPenalty NUMBER(19, 4) NULL
	 , AnalyzedCtgVunPenalty NUMBER(19, 4) NULL
	 , AnalyzedPpoCtgVunPenalty NUMBER(19, 4) NULL
	 , RenderingNpi VARCHAR(15) NULL
);


CALL ADM.ALTER_COLUMN('ADD', 'src', 'BILLS', 'CtgCoPayPenalty', 'NUMBER(19, 4)',  'NULL');
CALL ADM.ALTER_COLUMN('ADD', 'src', 'BILLS', 'PpoCtgCoPayPenalty', 'NUMBER(19, 4)',  'NULL');
CALL ADM.ALTER_COLUMN('ADD', 'src', 'BILLS', 'AnalyzedCtgCoPayPenalty', 'NUMBER(19, 4)',  'NULL');
CALL ADM.ALTER_COLUMN('ADD', 'src', 'BILLS', 'AnalyzedPpoCtgCoPayPenalty', 'NUMBER(19, 4)',  'NULL');
CALL ADM.ALTER_COLUMN('ADD', 'src', 'BILLS', 'CtgVunPenalty', 'NUMBER(19, 4)',  'NULL');
CALL ADM.ALTER_COLUMN('ADD', 'src', 'BILLS', 'PpoCtgVunPenalty', 'NUMBER(19, 4)',  'NULL');
CALL ADM.ALTER_COLUMN('ADD', 'src', 'BILLS', 'AnalyzedCtgVunPenalty', 'NUMBER(19, 4)',  'NULL');
CALL ADM.ALTER_COLUMN('ADD', 'src', 'BILLS', 'AnalyzedPpoCtgVunPenalty', 'NUMBER(19, 4)',  'NULL');

CALL ADM.ALTER_COLUMN('ADD', 'SRC', 'BILLS', 'RenderingNpi', 'VARCHAR(15)', 'NULL');
CALL ADM.ALTER_COLUMN('RENAME', 'SRC', 'Bills', 'PpoCtgCoPayPenalty', 'PpoCtgCoPayPenaltyPercentage');
CALL ADM.ALTER_COLUMN('RENAME', 'SRC', 'Bills', 'AnalyzedPpoCtgCoPayPenalty', 'AnalyzedPpoCtgCoPayPenaltyPercentage');
CALL ADM.ALTER_COLUMN('RENAME', 'SRC', 'Bills', 'PpoCtgVunPenalty', 'PpoCtgVunPenaltyPercentage');
CALL ADM.ALTER_COLUMN('RENAME', 'SRC', 'Bills', 'AnalyzedPpoCtgVunPenalty', 'AnalyzedPpoCtgVunPenaltyPercentage');
CREATE TABLE IF NOT EXISTS src.BillsOverride (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillsOverrideID NUMBER(10, 0) NOT NULL
	 , BillIDNo NUMBER(10, 0) NULL
	 , LINE_NO NUMBER(5, 0) NULL
	 , UserId NUMBER(10, 0) NULL
	 , DateSaved DATETIME NULL
	 , AmountBefore NUMBER(19, 4) NULL
	 , AmountAfter NUMBER(19, 4) NULL
	 , CodesOverrode VARCHAR(50) NULL
	 , SeqNo NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.BillsProviderNetwork (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , NetworkId NUMBER(10, 0) NULL
	 , NetworkName VARCHAR(50) NULL
);

CREATE TABLE IF NOT EXISTS src.BILLS_CTG_Endnotes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , Line_No NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
	 , RuleType VARCHAR(2) NULL
	 , RuleId NUMBER(10, 0) NULL
	 , PreCertAction NUMBER(5, 0) NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.BILLS_DRG (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , PricerPassThru NUMBER(19, 4) NULL
	 , PricerCapital_Outlier_Amt NUMBER(19, 4) NULL
	 , PricerCapital_OldHarm_Amt NUMBER(19, 4) NULL
	 , PricerCapital_IME_Amt NUMBER(19, 4) NULL
	 , PricerCapital_HSP_Amt NUMBER(19, 4) NULL
	 , PricerCapital_FSP_Amt NUMBER(19, 4) NULL
	 , PricerCapital_Exceptions_Amt NUMBER(19, 4) NULL
	 , PricerCapital_DSH_Amt NUMBER(19, 4) NULL
	 , PricerCapitalPayment NUMBER(19, 4) NULL
	 , PricerDSH NUMBER(19, 4) NULL
	 , PricerIME NUMBER(19, 4) NULL
	 , PricerCostOutlier NUMBER(19, 4) NULL
	 , PricerHSP NUMBER(19, 4) NULL
	 , PricerFSP NUMBER(19, 4) NULL
	 , PricerTotalPayment NUMBER(19, 4) NULL
	 , PricerReturnMsg VARCHAR(255) NULL
	 , ReturnDRG VARCHAR(3) NULL
	 , ReturnDRGDesc VARCHAR(125) NULL
	 , ReturnMDC VARCHAR(3) NULL
	 , ReturnMDCDesc VARCHAR(100) NULL
	 , ReturnDRGWt FLOAT(24) NULL
	 , ReturnDRGALOS FLOAT(24) NULL
	 , ReturnADX VARCHAR(8) NULL
	 , ReturnSDX VARCHAR(8) NULL
	 , ReturnMPR VARCHAR(8) NULL
	 , ReturnPR2 VARCHAR(8) NULL
	 , ReturnPR3 VARCHAR(8) NULL
	 , ReturnNOR VARCHAR(8) NULL
	 , ReturnNO2 VARCHAR(8) NULL
	 , ReturnCOM VARCHAR(255) NULL
	 , ReturnCMI NUMBER(5, 0) NULL
	 , ReturnDCC VARCHAR(8) NULL
	 , ReturnDX1 VARCHAR(8) NULL
	 , ReturnDX2 VARCHAR(8) NULL
	 , ReturnDX3 VARCHAR(8) NULL
	 , ReturnMCI NUMBER(5, 0) NULL
	 , ReturnOR1 VARCHAR(8) NULL
	 , ReturnOR2 VARCHAR(8) NULL
	 , ReturnOR3 VARCHAR(8) NULL
	 , ReturnTRI NUMBER(5, 0) NULL
	 , SOJ VARCHAR(2) NULL
	 , OPCERT VARCHAR(7) NULL
	 , BlendCaseInclMalp FLOAT(24) NULL
	 , CapitalCost FLOAT(24) NULL
	 , HospBadDebt FLOAT(24) NULL
	 , ExcessPhysMalp FLOAT(24) NULL
	 , SparcsPerCase FLOAT(24) NULL
	 , AltLevelOfCare FLOAT(24) NULL
	 , DRGWgt FLOAT(24) NULL
	 , TransferCapital FLOAT(24) NULL
	 , NYDrgType NUMBER(5, 0) NULL
	 , LOS NUMBER(5, 0) NULL
	 , TrimPoint NUMBER(5, 0) NULL
	 , GroupBlendPercentage FLOAT(24) NULL
	 , AdjustmentFactor FLOAT(24) NULL
	 , HospLongStayGroupPrice FLOAT(24) NULL
	 , TotalDRGCharge NUMBER(19, 4) NULL
	 , BlendCaseAdj FLOAT(24) NULL
	 , CapitalCostAdj FLOAT(24) NULL
	 , NonMedicareCaseMix FLOAT(24) NULL
	 , HighCostChargeConverter FLOAT(24) NULL
	 , DischargeCasePaymentRate NUMBER(19, 4) NULL
	 , DirectMedicalEducation NUMBER(19, 4) NULL
	 , CasePaymentCapitalPerDiem NUMBER(19, 4) NULL
	 , HighCostOutlierThreshold NUMBER(19, 4) NULL
	 , ISAF FLOAT(24) NULL
	 , ReturnSOI NUMBER(5, 0) NULL
	 , CapitalCostPerDischarge NUMBER(19, 4) NULL
	 , ReturnSOIDesc VARCHAR(20) NULL
);

ALTER TABLE src.BILLS_DRG
	ALTER ReturnDRGDesc SET DATA TYPE VARCHAR(125) ,
	COLUMN ReturnMDCDesc SET DATA TYPE VARCHAR(100);
CREATE TABLE IF NOT EXISTS src.BILLS_Endnotes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER(10, 0) NOT NULL
	 , LINE_NO NUMBER(5, 0) NOT NULL
	 , EndNote NUMBER(5, 0) NOT NULL
	 , Referral VARCHAR(200) NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
	 , EndnoteTypeId NUMBER(3, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.Bills_OverrideEndNotes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , OverrideEndNoteID NUMBER(10, 0) NOT NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , Line_No NUMBER(5, 0) NULL
	 , OverrideEndNote NUMBER(5, 0) NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.Bills_Pharm (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , Line_No NUMBER(5, 0) NOT NULL
	 , LINE_NO_DISP NUMBER(5, 0) NULL
	 , DateOfService DATETIME NULL
	 , NDC VARCHAR(13) NULL
	 , PriceTypeCode VARCHAR(2) NULL
	 , Units FLOAT(24) NULL
	 , Charged NUMBER(19, 4) NULL
	 , Allowed NUMBER(19, 4) NULL
	 , EndNote VARCHAR(20) NULL
	 , Override NUMBER(5, 0) NULL
	 , Override_Rsn VARCHAR(10) NULL
	 , Analyzed NUMBER(19, 4) NULL
	 , CTGPenalty NUMBER(19, 4) NULL
	 , PrePPOAllowed NUMBER(19, 4) NULL
	 , PPODate DATETIME NULL
	 , POS_RevCode VARCHAR(4) NULL
	 , DPAllowed NUMBER(19, 4) NULL
	 , HCRA_Surcharge NUMBER(19, 4) NULL
	 , EndDateOfService DATETIME NULL
	 , RepackagedNdc VARCHAR(13) NULL
	 , OriginalNdc VARCHAR(13) NULL
	 , UnitOfMeasureId NUMBER(3, 0) NULL
	 , PackageTypeOriginalNdc VARCHAR(2) NULL
	 , PpoCtgPenalty NUMBER(19, 4) NULL
	 , ServiceCode VARCHAR(25) NULL
	 , PreApportionedAmount NUMBER(19, 4) NULL
	 , DeductibleApplied NUMBER(19, 4) NULL
	 , BillReviewResults NUMBER(19, 4) NULL
	 , PreOverriddenDeductible NUMBER(19, 4) NULL
	 , RemainingBalance NUMBER(19, 4) NULL
	 , CtgCoPayPenalty NUMBER(19, 4) NULL
	 , PpoCtgCoPayPenalty NUMBER(19, 4) NULL
	 , CtgVunPenalty NUMBER(19, 4) NULL
	 , PpoCtgVunPenalty NUMBER(19, 4) NULL
	 , RenderingNpi VARCHAR(15) NULL
);

CALL ADM.ALTER_COLUMN('ADD', 'src', 'Bills_Pharm', 'CtgCoPayPenalty', 'NUMBER(19, 4)',  'NULL');
CALL ADM.ALTER_COLUMN('ADD', 'src', 'Bills_Pharm', 'PpoCtgCoPayPenalty', 'NUMBER(19, 4)',  'NULL');
CALL ADM.ALTER_COLUMN('ADD', 'src', 'Bills_Pharm', 'CtgVunPenalty', 'NUMBER(19, 4)',  'NULL');
CALL ADM.ALTER_COLUMN('ADD', 'src', 'Bills_Pharm', 'PpoCtgVunPenalty', 'NUMBER(19, 4)',  'NULL');

CALL ADM.ALTER_COLUMN('ADD', 'SRC', 'BILLS_PHARM', 'RenderingNpi', 'VARCHAR(15)', 'NULL');
CALL ADM.ALTER_COLUMN('RENAME', 'SRC', 'Bills_Pharm', 'PpoCtgCoPayPenalty', 'PpoCtgCoPayPenaltyPercentage');
CALL ADM.ALTER_COLUMN('RENAME', 'SRC', 'Bills_Pharm', 'PpoCtgVunPenalty', 'PpoCtgVunPenaltyPercentage');
CREATE TABLE IF NOT EXISTS src.Bills_Pharm_CTG_Endnotes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER(10, 0) NOT NULL
	 , LINE_NO NUMBER(5, 0) NOT NULL
	 , EndNote NUMBER(5, 0) NOT NULL
	 , RuleType VARCHAR(2) NULL
	 , RuleId NUMBER(10, 0) NULL
	 , PreCertAction NUMBER(5, 0) NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.Bills_Pharm_Endnotes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER(10, 0) NOT NULL
	 , LINE_NO NUMBER(5, 0) NOT NULL
	 , EndNote NUMBER(5, 0) NOT NULL
	 , Referral VARCHAR(200) NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
	 , EndnoteTypeId NUMBER(3, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.Bills_Pharm_OverrideEndNotes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , OverrideEndNoteID NUMBER(10, 0) NOT NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , Line_No NUMBER(5, 0) NULL
	 , OverrideEndNote NUMBER(5, 0) NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.Bills_Tax (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillsTaxId NUMBER(10, 0) NOT NULL
	 , TableType NUMBER(5, 0) NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , Line_No NUMBER(5, 0) NULL
	 , SeqNo NUMBER(5, 0) NULL
	 , TaxTypeId NUMBER(5, 0) NULL
	 , ImportTaxRate NUMBER(5, 5) NULL
	 , Tax NUMBER(19, 4) NULL
	 , OverridenTax NUMBER(19, 4) NULL
	 , ImportTaxAmount NUMBER(19, 4) NULL
);

CREATE TABLE IF NOT EXISTS src.BILL_HDR (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER(10, 0) NOT NULL
	 , CMT_HDR_IDNo NUMBER(10, 0) NULL
	 , DateSaved DATETIME NULL
	 , DateRcv DATETIME NULL
	 , InvoiceNumber VARCHAR(40) NULL
	 , InvoiceDate DATETIME NULL
	 , FileNumber VARCHAR(50) NULL
	 , Note VARCHAR(20) NULL
	 , NoLines NUMBER(5, 0) NULL
	 , AmtCharged NUMBER(19, 4) NULL
	 , AmtAllowed NUMBER(19, 4) NULL
	 , ReasonVersion NUMBER(5, 0) NULL
	 , Region VARCHAR(50) NULL
	 , PvdUpdateCounter NUMBER(5, 0) NULL
	 , FeatureID NUMBER(10, 0) NULL
	 , ClaimDateLoss DATETIME NULL
	 , CV_Type VARCHAR(2) NULL
	 , Flags NUMBER(10, 0) NULL
	 , WhoCreate VARCHAR(15) NULL
	 , WhoLast VARCHAR(15) NULL
	 , AcceptAssignment NUMBER(5, 0) NULL
	 , EmergencyService NUMBER(5, 0) NULL
	 , CmtPaidDeductible NUMBER(19, 4) NULL
	 , InsPaidLimit NUMBER(19, 4) NULL
	 , StatusFlag VARCHAR(2) NULL
	 , OfficeId NUMBER(10, 0) NULL
	 , CmtPaidCoPay NUMBER(19, 4) NULL
	 , AmbulanceMethod NUMBER(5, 0) NULL
	 , StatusDate DATETIME NULL
	 , Category NUMBER(10, 0) NULL
	 , CatDesc VARCHAR(1000) NULL
	 , AssignedUser VARCHAR(15) NULL
	 , CreateDate DATETIME NULL
	 , PvdZOS VARCHAR(12) NULL
	 , PPONumberSent NUMBER(5, 0) NULL
	 , AdmissionDate DATETIME NULL
	 , DischargeDate DATETIME NULL
	 , DischargeStatus NUMBER(5, 0) NULL
	 , TypeOfBill VARCHAR(4) NULL
	 , SentryMessage VARCHAR(1000) NULL
	 , AmbulanceZipOfPickup VARCHAR(12) NULL
	 , AmbulanceNumberOfPatients NUMBER(5, 0) NULL
	 , WhoCreateID NUMBER(10, 0) NULL
	 , WhoLastId NUMBER(10, 0) NULL
	 , NYRequestDate DATETIME NULL
	 , NYReceivedDate DATETIME NULL
	 , ImgDocId VARCHAR(50) NULL
	 , PaymentDecision NUMBER(5, 0) NULL
	 , PvdCMSId VARCHAR(6) NULL
	 , PvdNPINo VARCHAR(15) NULL
	 , DischargeHour VARCHAR(2) NULL
	 , PreCertChanged NUMBER(5, 0) NULL
	 , DueDate DATETIME NULL
	 , AttorneyIDNo NUMBER(10, 0) NULL
	 , AssignedGroup NUMBER(10, 0) NULL
	 , LastChangedOn DATETIME NULL
	 , PrePPOAllowed NUMBER(19, 4) NULL
	 , PPSCode NUMBER(5, 0) NULL
	 , SOI NUMBER(5, 0) NULL
	 , StatementStartDate DATETIME NULL
	 , StatementEndDate DATETIME NULL
	 , DeductibleOverride BOOLEAN NULL
	 , AdmissionType NUMBER(3, 0) NULL
	 , CoverageType VARCHAR(2) NULL
	 , PricingProfileId NUMBER(10, 0) NULL
	 , DesignatedPricingState VARCHAR(2) NULL
	 , DateAnalyzed DATETIME NULL
	 , SentToPpoSysId NUMBER(10, 0) NULL
	 , PricingState VARCHAR(2) NULL
	 , BillVpnEligible BOOLEAN NULL
	 , ApportionmentPercentage NUMBER(5, 2) NULL
	 , BillSourceId NUMBER(3, 0) NULL
	 , OutOfStateProviderNumber NUMBER(10, 0) NULL
	 , FloridaDeductibleRuleEligible BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.Bill_History (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , SeqNo NUMBER(10, 0) NOT NULL
	 , DateCommitted DATETIME NULL
	 , AmtCommitted NUMBER(19, 4) NULL
	 , UserId VARCHAR(15) NULL
	 , AmtCoPay NUMBER(19, 4) NULL
	 , AmtDeductible NUMBER(19, 4) NULL
	 , Flags NUMBER(10, 0) NULL
	 , AmtSalesTax NUMBER(19, 4) NULL
	 , AmtOtherTax NUMBER(19, 4) NULL
	 , DeductibleOverride BOOLEAN NULL
	 , PricingState VARCHAR(2) NULL
	 , ApportionmentPercentage NUMBER(5, 2) NULL
	 , FloridaDeductibleRuleEligible BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.Bill_Payment_Adjustments (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Bill_Payment_Adjustment_ID NUMBER(10, 0) NOT NULL
	 , BillIDNo NUMBER(10, 0) NULL
	 , SeqNo NUMBER(5, 0) NULL
	 , InterestFlags NUMBER(10, 0) NULL
	 , DateInterestStarts DATETIME NULL
	 , DateInterestEnds DATETIME NULL
	 , InterestAdditionalInfoReceived DATETIME NULL
	 , Interest NUMBER(19, 4) NULL
	 , Comments VARCHAR(1000) NULL
);

CREATE TABLE IF NOT EXISTS src.Bill_Pharm_ApportionmentEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillId NUMBER(10, 0) NOT NULL
	 , LineNumber NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.BILL_SENTRY_ENDNOTE (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillID NUMBER(10, 0) NOT NULL
	 , Line NUMBER(10, 0) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.BIReportAdjustmentCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BIReportAdjustmentCategoryId NUMBER(10, 0) NOT NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR(500) NULL
	 , DisplayPriority NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.BIReportAdjustmentCategoryMapping (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BIReportAdjustmentCategoryId NUMBER(10, 0) NOT NULL
	 , Adjustment360SubCategoryId NUMBER(10, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.Bitmasks (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TableProgramUsed VARCHAR(50) NOT NULL
	 , AttributeUsed VARCHAR(50) NOT NULL
	 , Decimal NUMBER(19, 0) NOT NULL
	 , ConstantName VARCHAR(50) NULL
	 , Bit VARCHAR(50) NULL
	 , Hex VARCHAR(20) NULL
	 , Description VARCHAR(250) NULL
);

CREATE TABLE IF NOT EXISTS src.CbreToDpEndnoteMapping( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Endnote NUMBER (10,0) NOT NULL
	 , EndnoteTypeId NUMBER (3,0) NOT NULL
	 , CbreEndnote NUMBER (5,0) NOT NULL
	 , PricingState VARCHAR (2) NOT NULL
	 , PricingMethodId NUMBER (3,0) NOT NULL
 ); 
CREATE TABLE IF NOT EXISTS src.CLAIMANT (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CmtIDNo NUMBER(10, 0) NOT NULL
	 , ClaimIDNo NUMBER(10, 0) NULL
	 , CmtSSN VARCHAR(11) NULL
	 , CmtLastName VARCHAR(60) NULL
	 , CmtFirstName VARCHAR(35) NULL
	 , CmtMI VARCHAR(1) NULL
	 , CmtDOB DATETIME NULL
	 , CmtSEX VARCHAR(1) NULL
	 , CmtAddr1 VARCHAR(55) NULL
	 , CmtAddr2 VARCHAR(55) NULL
	 , CmtCity VARCHAR(30) NULL
	 , CmtState VARCHAR(2) NULL
	 , CmtZip VARCHAR(12) NULL
	 , CmtPhone VARCHAR(25) NULL
	 , CmtOccNo VARCHAR(11) NULL
	 , CmtAttorneyNo NUMBER(10, 0) NULL
	 , CmtPolicyLimit NUMBER(19, 4) NULL
	 , CmtStateOfJurisdiction VARCHAR(2) NULL
	 , CmtDeductible NUMBER(19, 4) NULL
	 , CmtCoPaymentPercentage NUMBER(5, 0) NULL
	 , CmtCoPaymentMax NUMBER(19, 4) NULL
	 , CmtPPO_Eligible NUMBER(5, 0) NULL
	 , CmtCoordBenefits NUMBER(5, 0) NULL
	 , CmtFLCopay NUMBER(5, 0) NULL
	 , CmtCOAExport DATETIME NULL
	 , CmtPGFirstName VARCHAR(30) NULL
	 , CmtPGLastName VARCHAR(30) NULL
	 , CmtDedType NUMBER(5, 0) NULL
	 , ExportToClaimIQ NUMBER(5, 0) NULL
	 , CmtInactive NUMBER(5, 0) NULL
	 , CmtPreCertOption NUMBER(5, 0) NULL
	 , CmtPreCertState VARCHAR(2) NULL
	 , CreateDate DATETIME NULL
	 , LastChangedOn DATETIME NULL
	 , OdsParticipant BOOLEAN NULL
	 , CoverageType VARCHAR(2) NULL
	 , DoNotDisplayCoverageTypeOnEOB BOOLEAN NULL
	 , ShowAllocationsOnEob BOOLEAN NULL
	 , SetPreAllocation BOOLEAN NULL
	 , PharmacyEligible NUMBER(3, 0) NULL
	 , SendCardToClaimant NUMBER(3, 0) NULL
	 , ShareCoPayMaximum BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.ClaimantManualProviderSummary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ManualProviderId NUMBER(10, 0) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NOT NULL
	 , FirstDateOfService DATETIME NULL
	 , LastDateOfService DATETIME NULL
	 , Visits NUMBER(10, 0) NULL
	 , ChargedAmount NUMBER(19, 4) NULL
	 , EvaluatedAmount NUMBER(19, 4) NULL
	 , MinimumEvaluatedAmount NUMBER(19, 4) NULL
	 , MaximumEvaluatedAmount NUMBER(19, 4) NULL
	 , Comments VARCHAR(255) NULL
);

CREATE TABLE IF NOT EXISTS src.ClaimantProviderSummaryEvaluation (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ClaimantProviderSummaryEvaluationId NUMBER(10, 0) NOT NULL
	 , ClaimantHeaderId NUMBER(10, 0) NULL
	 , EvaluatedAmount NUMBER(19, 4) NULL
	 , MinimumEvaluatedAmount NUMBER(19, 4) NULL
	 , MaximumEvaluatedAmount NUMBER(19, 4) NULL
	 , Comments VARCHAR(255) NULL
);

CREATE TABLE IF NOT EXISTS src.Claimant_ClientRef (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CmtIdNo NUMBER(10, 0) NOT NULL
	 , CmtSuffix VARCHAR(50) NULL
	 , ClaimIdNo NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.CLAIMS (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ClaimIDNo NUMBER(10, 0) NOT NULL
	 , ClaimNo VARCHAR NULL
	 , DateLoss DATETIME NULL
	 , CV_Code VARCHAR(2) NULL
	 , DiaryIndex NUMBER(10, 0) NULL
	 , LastSaved DATETIME NULL
	 , PolicyNumber VARCHAR(50) NULL
	 , PolicyHoldersName VARCHAR(30) NULL
	 , PaidDeductible NUMBER(19, 4) NULL
	 , Status VARCHAR(1) NULL
	 , InUse VARCHAR(100) NULL
	 , CompanyID NUMBER(10, 0) NULL
	 , OfficeIndex NUMBER(10, 0) NULL
	 , AdjIdNo NUMBER(10, 0) NULL
	 , PaidCoPay NUMBER(19, 4) NULL
	 , AssignedUser VARCHAR(15) NULL
	 , Privatized NUMBER(5, 0) NULL
	 , PolicyEffDate DATETIME NULL
	 , Deductible NUMBER(19, 4) NULL
	 , LossState VARCHAR(2) NULL
	 , AssignedGroup NUMBER(10, 0) NULL
	 , CreateDate DATETIME NULL
	 , LastChangedOn DATETIME NULL
	 , AllowMultiCoverage BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.Claims_ClientRef (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ClaimIdNo NUMBER(10, 0) NOT NULL
	 , ClientRefId VARCHAR(50) NULL
);

CREATE TABLE IF NOT EXISTS src.CMS_Zip2Region (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , ZIP_Code VARCHAR(5) NOT NULL
	 , State VARCHAR(2) NULL
	 , Region VARCHAR(2) NULL
	 , AmbRegion VARCHAR(2) NULL
	 , RuralFlag NUMBER(5, 0) NULL
	 , ASCRegion NUMBER(5, 0) NULL
	 , PlusFour NUMBER(5, 0) NULL
	 , CarrierId NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.CMT_DX (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER(10, 0) NOT NULL
	 , DX VARCHAR(8) NOT NULL
	 , SeqNum NUMBER(5, 0) NULL
	 , POA VARCHAR(1) NULL
	 , IcdVersion NUMBER(3, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.CMT_HDR (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CMT_HDR_IDNo NUMBER(10, 0) NOT NULL
	 , CmtIDNo NUMBER(10, 0) NULL
	 , PvdIDNo NUMBER(10, 0) NULL
	 , LastChangedOn DATETIME NULL
);

CREATE TABLE IF NOT EXISTS src.CMT_ICD9 (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER(10, 0) NOT NULL
	 , SeqNo NUMBER(5, 0) NOT NULL
	 , ICD9 VARCHAR(7) NULL
	 , IcdVersion NUMBER(3, 0) NULL
);

-- rename table to coveragetype
CALL ADM.DDL_TABLE('RENAME', 'SRC', 'LKP_CVTYPE', 'COVERAGETYPE');

CREATE TABLE IF NOT EXISTS src.CoverageType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , LongName VARCHAR(30) NULL
	 , ShortName VARCHAR(2) NOT NULL
	 , CbreCoverageTypeCode VARCHAR(2) NULL
	 , CoverageTypeCategoryCode VARCHAR(4) NULL
	 , PricingMethodId NUMBER(3, 0) NULL
);

-- Drop all obsolete objects after renaming
CALL ADM.DROP_OBJECT('DROP','TABLE','SRC','LKP_CVTYPE');
CALL ADM.DROP_OBJECT('DROP','VIEW','DBO','LKP_CVTYPE');
CALL ADM.DROP_OBJECT('DROP','FUNCTION','DBO','IF_LKP_CVTYPE (NUMBER)');
CREATE TABLE IF NOT EXISTS src.cpt_DX_DICT (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ICD9 VARCHAR(6) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , Flags NUMBER(5, 0) NULL
	 , NonSpecific VARCHAR(1) NULL
	 , AdditionalDigits VARCHAR(1) NULL
	 , Traumatic VARCHAR(1) NULL
	 , DX_DESC VARCHAR NULL
	 , Duration NUMBER(5, 0) NULL
	 , Colossus NUMBER(5, 0) NULL
	 , DiagnosisFamilyId NUMBER(3, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.cpt_PRC_DICT (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PRC_CD VARCHAR(7) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , PRC_DESC VARCHAR NULL
	 , Flags NUMBER(10, 0) NULL
	 , Vague VARCHAR(1) NULL
	 , PerVisit NUMBER(5, 0) NULL
	 , PerClaimant NUMBER(5, 0) NULL
	 , PerProvider NUMBER(5, 0) NULL
	 , BodyFlags NUMBER(10, 0) NULL
	 , Colossus NUMBER(5, 0) NULL
	 , CMS_Status VARCHAR(1) NULL
	 , DrugFlag NUMBER(5, 0) NULL
	 , CurativeFlag NUMBER(5, 0) NULL
	 , ExclPolicyLimit NUMBER(5, 0) NULL
	 , SpecNetFlag NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.CreditReason (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CreditReasonId NUMBER(10, 0) NOT NULL
	 , CreditReasonDesc VARCHAR(100) NULL
	 , IsVisible BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.CreditReasonOverrideENMap (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CreditReasonOverrideENMapId NUMBER(10, 0) NOT NULL
	 , CreditReasonId NUMBER(10, 0) NULL
	 , OverrideEndnoteId NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.CriticalAccessHospitalInpatientRevenueCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RevenueCode VARCHAR(4) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.CTG_Endnotes( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Endnote NUMBER (10,0) NOT NULL
	 , ShortDesc VARCHAR (50) NULL
	 , LongDesc VARCHAR (500) NULL
 ); 
CREATE TABLE IF NOT EXISTS src.CustomBillStatuses (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StatusId NUMBER(10, 0) NOT NULL
	 , StatusName VARCHAR(50) NULL
	 , StatusDescription VARCHAR(300) NULL
);

CREATE TABLE IF NOT EXISTS src.CustomEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CustomEndnote NUMBER(10, 0) NOT NULL
	 , ShortDescription VARCHAR(50) NULL
	 , LongDescription VARCHAR(500) NULL
);

CREATE TABLE IF NOT EXISTS src.CustomerBillExclusion (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , Customer VARCHAR(50) NOT NULL
	 , ReportID NUMBER(3, 0) NOT NULL
	 , CreateDate DATETIME NULL
);

CREATE TABLE IF NOT EXISTS src.DeductibleRuleCriteria (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DeductibleRuleCriteriaId NUMBER(10, 0) NOT NULL
	 , PricingRuleDateCriteriaId NUMBER(3, 0) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
);

CREATE TABLE IF NOT EXISTS src.DeductibleRuleCriteriaCoverageType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DeductibleRuleCriteriaId NUMBER(10, 0) NOT NULL
	 , CoverageType VARCHAR(5) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.DeductibleRuleExemptEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
	 , EndnoteTypeId NUMBER(3, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.DemandClaimant (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NOT NULL
	 , ExternalClaimantId NUMBER(10, 0) NULL
	 , OrganizationId VARCHAR(100) NULL
	 , HeightInInches NUMBER(5, 0) NULL
	 , Weight NUMBER(5, 0) NULL
	 , Occupation VARCHAR(50) NULL
	 , BiReportStatus NUMBER(5, 0) NULL
	 , HasDemandPackage NUMBER(10, 0) NULL
	 , FactsOfLoss VARCHAR(250) NULL
	 , PreExistingConditions VARCHAR(100) NULL
	 , Archived BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.DemandPackage (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DemandPackageId NUMBER(10, 0) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NULL
	 , RequestedByUserName VARCHAR(15) NULL
	 , DateTimeReceived TIMESTAMP_LTZ(7) NULL
	 , CorrelationId VARCHAR(36) NULL
	 , PageCount NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.DemandPackageRequestedService (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DemandPackageRequestedServiceId NUMBER(10, 0) NOT NULL
	 , DemandPackageId NUMBER(10, 0) NULL
	 , ReviewRequestOptions VARCHAR NULL
);

CREATE TABLE IF NOT EXISTS src.DemandPackageUploadedFile (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DemandPackageUploadedFileId NUMBER(10, 0) NOT NULL
	 , DemandPackageId NUMBER(10, 0) NULL
	 , FileName VARCHAR(255) NULL
	 , Size NUMBER(10, 0) NULL
	 , DocStoreId VARCHAR(50) NULL
);

CREATE TABLE IF NOT EXISTS src.DiagnosisCodeGroup (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DiagnosisCode VARCHAR(8) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , MajorCategory VARCHAR(500) NULL
	 , MinorCategory VARCHAR(500) NULL
);

CREATE TABLE IF NOT EXISTS src.EncounterType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EncounterTypeId NUMBER(3, 0) NOT NULL
	 , EncounterTypePriority NUMBER(3, 0) NULL
	 , Description VARCHAR(100) NULL
	 , NarrativeInformation VARCHAR NULL
);

CREATE TABLE IF NOT EXISTS src.EndnoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EndnoteSubCategoryId NUMBER(3, 0) NOT NULL
	 , Description VARCHAR(50) NULL
);

CREATE TABLE IF NOT EXISTS src.Esp_Ppo_Billing_Data_Self_Bill (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , COMPANYCODE VARCHAR(10) NULL
	 , TRANSACTIONTYPE VARCHAR(10) NULL
	 , BILL_HDR_AMTALLOWED NUMBER(15, 2) NULL
	 , BILL_HDR_AMTCHARGED NUMBER(15, 2) NULL
	 , BILL_HDR_BILLIDNO NUMBER(10, 0) NULL
	 , BILL_HDR_CMT_HDR_IDNO NUMBER(10, 0) NULL
	 , BILL_HDR_CREATEDATE DATETIME NULL
	 , BILL_HDR_CV_TYPE VARCHAR(5) NULL
	 , BILL_HDR_FORM_TYPE VARCHAR(8) NULL
	 , BILL_HDR_NOLINES NUMBER(10, 0) NULL
	 , BILLS_ALLOWED NUMBER(15, 2) NULL
	 , BILLS_ANALYZED NUMBER(15, 2) NULL
	 , BILLS_CHARGED NUMBER(15, 2) NULL
	 , BILLS_DT_SVC DATETIME NULL
	 , BILLS_LINE_NO NUMBER(10, 0) NULL
	 , CLAIMANT_CLIENTREF_CMTSUFFIX VARCHAR(50) NULL
	 , CLAIMANT_CMTFIRST_NAME VARCHAR(50) NULL
	 , CLAIMANT_CMTIDNO VARCHAR(20) NULL
	 , CLAIMANT_CMTLASTNAME VARCHAR(60) NULL
	 , CMTSTATEOFJURISDICTION VARCHAR(2) NULL
	 , CLAIMS_COMPANYID NUMBER(10, 0) NULL
	 , CLAIMS_CLAIMNO VARCHAR(50) NULL
	 , CLAIMS_DATELOSS DATETIME NULL
	 , CLAIMS_OFFICEINDEX NUMBER(10, 0) NULL
	 , CLAIMS_POLICYHOLDERSNAME VARCHAR(100) NULL
	 , CLAIMS_POLICYNUMBER VARCHAR(50) NULL
	 , PNETWKEVENTLOG_EVENTID NUMBER(10, 0) NULL
	 , PNETWKEVENTLOG_LOGDATE DATETIME NULL
	 , PNETWKEVENTLOG_NETWORKID NUMBER(10, 0) NULL
	 , ACTIVITY_FLAG VARCHAR(1) NULL
	 , PPO_AMTALLOWED NUMBER(15, 2) NULL
	 , PREPPO_AMTALLOWED NUMBER(15, 2) NULL
	 , PREPPO_ALLOWED_FS VARCHAR(1) NULL
	 , PRF_COMPANY_COMPANYNAME VARCHAR(50) NULL
	 , PRF_OFFICE_OFCNAME VARCHAR(50) NULL
	 , PRF_OFFICE_OFCNO VARCHAR(25) NULL
	 , PROVIDER_PVDFIRSTNAME VARCHAR(60) NULL
	 , PROVIDER_PVDGROUP VARCHAR(60) NULL
	 , PROVIDER_PVDLASTNAME VARCHAR(60) NULL
	 , PROVIDER_PVDTIN VARCHAR(15) NULL
	 , PROVIDER_STATE VARCHAR(5) NULL
	 , UDFCLAIM_UDFVALUETEXT VARCHAR(255) NULL
	 , ENTRY_DATE DATETIME NULL
	 , UDFCLAIMANT_UDFVALUETEXT VARCHAR(255) NULL
	 , SOURCE_DB VARCHAR(20) NULL
	 , CLAIMS_CV_CODE VARCHAR(5) NULL
	 , VPN_TRANSACTIONID NUMBER(19, 0) NOT NULL
	 , VPN_TRANSACTIONTYPEID NUMBER(10, 0) NULL
	 , VPN_BILLIDNO NUMBER(10, 0) NULL
	 , VPN_LINE_NO NUMBER(5, 0) NULL
	 , VPN_CHARGED NUMBER(19, 4) NULL
	 , VPN_DPALLOWED NUMBER(19, 4) NULL
	 , VPN_VPNALLOWED NUMBER(19, 4) NULL
	 , VPN_SAVINGS NUMBER(19, 4) NULL
	 , VPN_CREDITS NUMBER(19, 4) NULL
	 , VPN_HASOVERRIDE BOOLEAN NULL
	 , VPN_ENDNOTES VARCHAR(200) NULL
	 , VPN_NETWORKIDNO NUMBER(10, 0) NULL
	 , VPN_PROCESSFLAG NUMBER(5, 0) NULL
	 , VPN_LINETYPE NUMBER(10, 0) NULL
	 , VPN_DATETIMESTAMP DATETIME NULL
	 , VPN_SEQNO NUMBER(10, 0) NULL
	 , VPN_VPN_REF_LINE_NO NUMBER(5, 0) NULL
	 , VPN_NETWORKNAME VARCHAR(50) NULL
	 , VPN_SOJ VARCHAR(2) NULL
	 , VPN_CAT3 NUMBER(10, 0) NULL
	 , VPN_PPODATESTAMP DATETIME NULL
	 , VPN_NINTEYDAYS NUMBER(10, 0) NULL
	 , VPN_BILL_TYPE VARCHAR(1) NULL
	 , VPN_NET_SAVINGS NUMBER(19, 4) NULL
	 , CREDIT BOOLEAN NULL
	 , RECON BOOLEAN NULL
	 , DELETED BOOLEAN NULL
	 , STATUS_FLAG VARCHAR(2) NULL
	 , DATE_SAVED DATETIME NULL
	 , SUB_NETWORK VARCHAR(50) NULL
	 , INVALID_CREDIT BOOLEAN NULL
	 , PROVIDER_SPECIALTY VARCHAR(50) NULL
	 , ADJUSTOR_IDNUMBER VARCHAR(25) NULL
	 , ACP_FLAG VARCHAR(1) NULL
	 , OVERRIDE_ENDNOTES VARCHAR NULL
	 , OVERRIDE_ENDNOTES_DESC VARCHAR NULL
);

CREATE TABLE IF NOT EXISTS src.EvaluationSummary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NOT NULL
	 , Details VARCHAR NULL
	 , CreatedBy VARCHAR(50) NULL
	 , CreatedDate TIMESTAMP_LTZ(7) NULL
	 , ModifiedBy VARCHAR(50) NULL
	 , ModifiedDate TIMESTAMP_LTZ(7) NULL
	 , EvaluationSummaryTemplateVersionId NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.EvaluationSummaryHistory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EvaluationSummaryHistoryId NUMBER(10, 0) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NULL
	 , EvaluationSummary VARCHAR NULL
	 , CreatedBy VARCHAR(50) NULL
	 , CreatedDate TIMESTAMP_LTZ(7) NULL
);

CREATE TABLE IF NOT EXISTS src.EvaluationSummaryTemplateVersion (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EvaluationSummaryTemplateVersionId NUMBER(10, 0) NOT NULL
	 , Template VARCHAR NULL
	 , TemplateHash BINARY(32) NULL
	 , CreatedDate TIMESTAMP_LTZ(7) NULL
);

CREATE TABLE IF NOT EXISTS src.EventLog (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EventLogId NUMBER(10, 0) NOT NULL
	 , ObjectName VARCHAR(50) NULL
	 , ObjectId NUMBER(10, 0) NULL
	 , UserName VARCHAR(15) NULL
	 , LogDate TIMESTAMP_LTZ(7) NULL
	 , ActionName VARCHAR(20) NULL
	 , OrganizationId VARCHAR(100) NULL
);

CREATE TABLE IF NOT EXISTS src.EventLogDetail (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EventLogDetailId NUMBER(10, 0) NOT NULL
	 , EventLogId NUMBER(10, 0) NULL
	 , PropertyName VARCHAR(50) NULL
	 , OldValue VARCHAR NULL
	 , NewValue VARCHAR NULL
);

CREATE TABLE IF NOT EXISTS src.ExtractCat (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CatIdNo NUMBER(10, 0) NOT NULL
	 , Description VARCHAR(50) NULL
);

CREATE TABLE IF NOT EXISTS src.GeneralInterestRuleBaseType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , GeneralInterestRuleBaseTypeId NUMBER(3, 0) NOT NULL
	 , GeneralInterestRuleBaseTypeName VARCHAR(50) NULL
);

CREATE TABLE IF NOT EXISTS src.GeneralInterestRuleSetting (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , GeneralInterestRuleBaseTypeId NUMBER(3, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.Icd10DiagnosisVersion (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DiagnosisCode VARCHAR(8) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , NonSpecific BOOLEAN NULL
	 , Traumatic BOOLEAN NULL
	 , Duration NUMBER(5, 0) NULL
	 , Description VARCHAR NULL
	 , DiagnosisFamilyId NUMBER(3, 0) NULL
	 , TotalCharactersRequired NUMBER(3, 0) NULL
	 , PlaceholderRequired BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.ICD10ProcedureCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ICDProcedureCode VARCHAR(7) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , Description VARCHAR(300) NULL
	 , PASGrpNo NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.IcdDiagnosisCodeDictionary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DiagnosisCode VARCHAR(8) NOT NULL
	 , IcdVersion NUMBER(3, 0) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , NonSpecific BOOLEAN NULL
	 , Traumatic BOOLEAN NULL
	 , Duration NUMBER(3, 0) NULL
	 , Description VARCHAR NULL
	 , DiagnosisFamilyId NUMBER(3, 0) NULL
	 , DiagnosisSeverityId NUMBER(3, 0) NULL
	 , LateralityId NUMBER(3, 0) NULL
	 , TotalCharactersRequired NUMBER(3, 0) NULL
	 , PlaceholderRequired BOOLEAN NULL
	 , Flags NUMBER(5, 0) NULL
	 , AdditionalDigits BOOLEAN NULL
	 , Colossus NUMBER(5, 0) NULL
	 , InjuryNatureId NUMBER(3, 0) NULL
	 , EncounterSubcategoryId NUMBER(3, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.IcdDiagnosisCodeDictionaryBodyPart (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DiagnosisCode VARCHAR(8) NOT NULL
	 , IcdVersion NUMBER(3, 0) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , NcciBodyPartId NUMBER(3, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.InjuryNature (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , InjuryNatureId NUMBER(3, 0) NOT NULL
	 , InjuryNaturePriority NUMBER(3, 0) NULL
	 , Description VARCHAR(100) NULL
	 , NarrativeInformation VARCHAR NULL
);

CREATE TABLE IF NOT EXISTS src.lkp_SPC (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , lkp_SpcId NUMBER(10, 0) NOT NULL
	 , LongName VARCHAR(50) NULL
	 , ShortName VARCHAR(4) NULL
	 , Mult NUMBER(19, 4) NULL
	 , NCD92 NUMBER(5, 0) NULL
	 , NCD93 NUMBER(5, 0) NULL
	 , PlusFour NUMBER(5, 0) NULL
	 , CbreSpecialtyCode VARCHAR(12) NULL
);

CREATE TABLE IF NOT EXISTS src.lkp_TS (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ShortName VARCHAR(2) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , LongName VARCHAR(100) NULL
	 , Global NUMBER(5, 0) NULL
	 , AnesMedDirect NUMBER(5, 0) NULL
	 , AffectsPricing NUMBER(5, 0) NULL
	 , IsAssistantSurgery BOOLEAN NULL
	 , IsCoSurgeon BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.ManualProvider (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ManualProviderId NUMBER(10, 0) NOT NULL
	 , TIN VARCHAR(15) NULL
	 , LastName VARCHAR(60) NULL
	 , FirstName VARCHAR(35) NULL
	 , GroupName VARCHAR(60) NULL
	 , Address1 VARCHAR(55) NULL
	 , Address2 VARCHAR(55) NULL
	 , City VARCHAR(30) NULL
	 , State VARCHAR(2) NULL
	 , Zip VARCHAR(12) NULL
);

CREATE TABLE IF NOT EXISTS src.ManualProviderSpecialty (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ManualProviderId NUMBER(10, 0) NOT NULL
	 , Specialty VARCHAR(12) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.MedicalCodeCutOffs (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CodeTypeID NUMBER(10, 0) NOT NULL
	 , CodeType VARCHAR(50) NULL
	 , Code VARCHAR(50) NOT NULL
	 , FormType VARCHAR(10) NOT NULL
	 , MaxChargedPerUnit FLOAT(53) NULL
	 , MaxUnitsPerEncounter FLOAT(53) NULL
);

CREATE TABLE IF NOT EXISTS src.MedicareStatusIndicatorRule (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , MedicareStatusIndicatorRuleId NUMBER(10, 0) NOT NULL
	 , MedicareStatusIndicatorRuleName VARCHAR(50) NULL
	 , StatusIndicator VARCHAR(500) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
	 , Endnote NUMBER(10, 0) NULL
	 , EditActionId NUMBER(3, 0) NULL
	 , Comments VARCHAR(1000) NULL
);

CREATE TABLE IF NOT EXISTS src.MedicareStatusIndicatorRuleCoverageType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , MedicareStatusIndicatorRuleId NUMBER(10, 0) NOT NULL
	 , ShortName VARCHAR(2) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.MedicareStatusIndicatorRulePlaceOfService (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , MedicareStatusIndicatorRuleId NUMBER(10, 0) NOT NULL
	 , PlaceOfService VARCHAR(4) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.MedicareStatusIndicatorRuleProcedureCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , MedicareStatusIndicatorRuleId NUMBER(10, 0) NOT NULL
	 , ProcedureCode VARCHAR(7) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.MedicareStatusIndicatorRuleProviderSpecialty (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , MedicareStatusIndicatorRuleId NUMBER(10, 0) NOT NULL
	 , ProviderSpecialty VARCHAR(6) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.ModifierByState (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , State VARCHAR(2) NOT NULL
	 , ProcedureServiceCategoryId NUMBER(3, 0) NOT NULL
	 , ModifierDictionaryId NUMBER(10, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.ModifierDictionary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ModifierDictionaryId NUMBER(10, 0) NOT NULL
	 , Modifier VARCHAR(2) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
	 , Description VARCHAR(100) NULL
	 , Global BOOLEAN NULL
	 , AnesMedDirect BOOLEAN NULL
	 , AffectsPricing BOOLEAN NULL
	 , IsCoSurgeon BOOLEAN NULL
	 , IsAssistantSurgery BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.ModifierToProcedureCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProcedureCode VARCHAR(5) NOT NULL
	 , Modifier VARCHAR(2) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , SojFlag NUMBER(5, 0) NULL
	 , RequiresGuidelineReview BOOLEAN NULL
	 , Reference VARCHAR(255) NULL
	 , Comments VARCHAR(255) NULL
);

CREATE TABLE IF NOT EXISTS src.NcciBodyPart (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , NcciBodyPartId NUMBER(3, 0) NOT NULL
	 , Description VARCHAR(100) NULL
	 , NarrativeInformation VARCHAR NULL
);

CREATE TABLE IF NOT EXISTS src.NcciBodyPartToHybridBodyPartTranslation (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , NcciBodyPartId NUMBER(3, 0) NOT NULL
	 , HybridBodyPartId NUMBER(5, 0) NOT NULL
);

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

CREATE TABLE IF NOT EXISTS src.ny_Pharmacy (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , NDCCode VARCHAR(13) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , Description VARCHAR(125) NULL
	 , Fee NUMBER(19, 4) NOT NULL
	 , TypeOfDrug NUMBER(5, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.ny_specialty (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RatingCode VARCHAR(12) NOT NULL
	 , Desc_ VARCHAR(70) NULL
	 , CbreSpecialtyCode VARCHAR(12) NULL
);

CREATE TABLE IF NOT EXISTS src.pa_PlaceOfService (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , POS NUMBER(5, 0) NOT NULL
	 , Description VARCHAR(255) NULL
	 , Facility NUMBER(5, 0) NULL
	 , MHL NUMBER(5, 0) NULL
	 , PlusFour NUMBER(5, 0) NULL
	 , Institution NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.PlaceOfServiceDictionary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PlaceOfServiceCode NUMBER(5, 0) NOT NULL
	 , Description VARCHAR(255) NULL
	 , Facility NUMBER(5, 0) NULL
	 , MHL NUMBER(5, 0) NULL
	 , PlusFour NUMBER(5, 0) NULL
	 , Institution NUMBER(10, 0) NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
);

CREATE TABLE IF NOT EXISTS src.PrePpoBillInfo (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DateSentToPPO DATETIME NULL
	 , ClaimNo VARCHAR(50) NULL
	 , ClaimIDNo NUMBER(10, 0) NULL
	 , CompanyID NUMBER(10, 0) NULL
	 , OfficeIndex NUMBER(10, 0) NULL
	 , CV_Code VARCHAR(2) NULL
	 , DateLoss DATETIME NULL
	 , Deductible NUMBER(19, 4) NULL
	 , PaidCoPay NUMBER(19, 4) NULL
	 , PaidDeductible NUMBER(19, 4) NULL
	 , LossState VARCHAR(2) NULL
	 , CmtIDNo NUMBER(10, 0) NULL
	 , CmtCoPaymentMax NUMBER(19, 4) NULL
	 , CmtCoPaymentPercentage NUMBER(5, 0) NULL
	 , CmtDedType NUMBER(5, 0) NULL
	 , CmtDeductible NUMBER(19, 4) NULL
	 , CmtFLCopay NUMBER(5, 0) NULL
	 , CmtPolicyLimit NUMBER(19, 4) NULL
	 , CmtStateOfJurisdiction VARCHAR(2) NULL
	 , PvdIDNo NUMBER(10, 0) NULL
	 , PvdTIN VARCHAR(15) NULL
	 , PvdSPC_List VARCHAR(50) NULL
	 , PvdTitle VARCHAR(5) NULL
	 , PvdFlags NUMBER(10, 0) NULL
	 , DateSaved DATETIME NULL
	 , DateRcv DATETIME NULL
	 , InvoiceDate DATETIME NULL
	 , NoLines NUMBER(5, 0) NULL
	 , AmtCharged NUMBER(19, 4) NULL
	 , AmtAllowed NUMBER(19, 4) NULL
	 , Region VARCHAR(50) NULL
	 , FeatureID NUMBER(10, 0) NULL
	 , Flags NUMBER(10, 0) NULL
	 , WhoCreate VARCHAR(15) NULL
	 , WhoLast VARCHAR(15) NULL
	 , CmtPaidDeductible NUMBER(19, 4) NULL
	 , InsPaidLimit NUMBER(19, 4) NULL
	 , StatusFlag VARCHAR(2) NULL
	 , CmtPaidCoPay NUMBER(19, 4) NULL
	 , Category NUMBER(10, 0) NULL
	 , CatDesc VARCHAR(1000) NULL
	 , CreateDate DATETIME NULL
	 , PvdZOS VARCHAR(12) NULL
	 , AdmissionDate DATETIME NULL
	 , DischargeDate DATETIME NULL
	 , DischargeStatus NUMBER(5, 0) NULL
	 , TypeOfBill VARCHAR(4) NULL
	 , PaymentDecision NUMBER(5, 0) NULL
	 , PPONumberSent NUMBER(5, 0) NULL
	 , BillIDNo NUMBER(10, 0) NULL
	 , LINE_NO NUMBER(5, 0) NULL
	 , LINE_NO_DISP NUMBER(5, 0) NULL
	 , OVER_RIDE NUMBER(5, 0) NULL
	 , DT_SVC DATETIME NULL
	 , PRC_CD VARCHAR(7) NULL
	 , UNITS FLOAT(24) NULL
	 , TS_CD VARCHAR(14) NULL
	 , CHARGED NUMBER(19, 4) NULL
	 , ALLOWED NUMBER(19, 4) NULL
	 , ANALYZED NUMBER(19, 4) NULL
	 , REF_LINE_NO NUMBER(5, 0) NULL
	 , SUBNET VARCHAR(9) NULL
	 , FEE_SCHEDULE NUMBER(19, 4) NULL
	 , POS_RevCode VARCHAR(4) NULL
	 , CTGPenalty NUMBER(19, 4) NULL
	 , PrePPOAllowed NUMBER(19, 4) NULL
	 , PPODate DATETIME NULL
	 , PPOCTGPenalty NUMBER(19, 4) NULL
	 , UCRPerUnit NUMBER(19, 4) NULL
	 , FSPerUnit NUMBER(19, 4) NULL
	 , HCRA_Surcharge NUMBER(19, 4) NULL
	 , NDC VARCHAR(13) NULL
	 , PriceTypeCode VARCHAR(2) NULL
	 , PharmacyLine NUMBER(5, 0) NULL
	 , Endnotes VARCHAR(50) NULL
	 , SentryEN VARCHAR(250) NULL
	 , CTGEN VARCHAR(250) NULL
	 , CTGRuleType VARCHAR(250) NULL
	 , CTGRuleID VARCHAR(250) NULL
	 , OverrideEN VARCHAR(50) NULL
	 , UserId NUMBER(10, 0) NULL
	 , DateOverriden DATETIME NULL
	 , AmountBeforeOverride NUMBER(19, 4) NULL
	 , AmountAfterOverride NUMBER(19, 4) NULL
	 , CodesOverriden VARCHAR(50) NULL
	 , NetworkID NUMBER(10, 0) NULL
	 , BillSnapshot VARCHAR(30) NULL
	 , PPOSavings NUMBER(19, 4) NULL
	 , RevisedDate DATETIME NULL
	 , ReconsideredDate DATETIME NULL
	 , TierNumber NUMBER(5, 0) NULL
	 , PPOBillInfoID NUMBER(10, 0) NULL
	 , PrePPOBillInfoID NUMBER(10, 0) NOT NULL
	 , CtgCoPayPenalty NUMBER(19, 4) NULL
	 , PpoCtgCoPayPenalty NUMBER(19, 4) NULL
	 , CtgVunPenalty NUMBER(19, 4) NULL
	 , PpoCtgVunPenalty NUMBER(19, 4) NULL
);


CALL ADM.ALTER_COLUMN('ADD', 'src', 'PREPPOBILLINFO', 'CtgCoPayPenalty', 'NUMBER(19, 4)',  'NULL');
CALL ADM.ALTER_COLUMN('ADD', 'src', 'PREPPOBILLINFO', 'PpoCtgCoPayPenalty', 'NUMBER(19, 4)',  'NULL');
CALL ADM.ALTER_COLUMN('ADD', 'src', 'PREPPOBILLINFO', 'CtgVunPenalty', 'NUMBER(19, 4)',  'NULL');
CALL ADM.ALTER_COLUMN('ADD', 'src', 'PREPPOBILLINFO', 'PpoCtgVunPenalty', 'NUMBER(19, 4)',  'NULL');
CALL ADM.ALTER_COLUMN('RENAME', 'SRC', 'PrePPOBillInfo', 'PpoCtgCoPayPenalty', 'PpoCtgCoPayPenaltyPercentage');
CALL ADM.ALTER_COLUMN('RENAME', 'SRC', 'PrePPOBillInfo', 'PpoCtgVunPenalty', 'PpoCtgVunPenaltyPercentage');
CREATE TABLE IF NOT EXISTS src.prf_COMPANY (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CompanyId NUMBER(10, 0) NOT NULL
	 , CompanyName VARCHAR(50) NULL
	 , LastChangedOn DATETIME NULL
);

CREATE TABLE IF NOT EXISTS src.prf_CTGMaxPenaltyLines (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CTGMaxPenLineID NUMBER(10, 0) NOT NULL
	 , ProfileId NUMBER(10, 0) NULL
	 , DatesBasedOn NUMBER(5, 0) NULL
	 , MaxPenaltyPercent NUMBER(5, 0) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
);

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

CREATE TABLE IF NOT EXISTS src.prf_CTGPenaltyHdr (
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

CREATE TABLE IF NOT EXISTS src.prf_CTGPenaltyLines (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CTGPenLineID NUMBER(10, 0) NOT NULL
	 , ProfileId NUMBER(10, 0) NULL
	 , PenaltyType NUMBER(5, 0) NULL
	 , FeeSchedulePercent NUMBER(5, 0) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
	 , TurnAroundTime NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.Prf_CustomIcdAction (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CustomIcdActionId NUMBER(10, 0) NOT NULL
	 , ProfileId NUMBER(10, 0) NULL
	 , IcdVersionId NUMBER(3, 0) NULL
	 , Action NUMBER(5, 0) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
);

CREATE TABLE IF NOT EXISTS src.prf_Office (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CompanyId NUMBER(10, 0) NULL
	 , OfficeId NUMBER(10, 0) NOT NULL
	 , OfcNo VARCHAR(4) NULL
	 , OfcName VARCHAR(40) NULL
	 , OfcAddr1 VARCHAR(30) NULL
	 , OfcAddr2 VARCHAR(30) NULL
	 , OfcCity VARCHAR(30) NULL
	 , OfcState VARCHAR(2) NULL
	 , OfcZip VARCHAR(12) NULL
	 , OfcPhone VARCHAR(20) NULL
	 , OfcDefault NUMBER(5, 0) NULL
	 , OfcClaimMask VARCHAR(50) NULL
	 , OfcTinMask VARCHAR(50) NULL
	 , Version NUMBER(5, 0) NULL
	 , OfcEdits NUMBER(10, 0) NULL
	 , OfcCOAEnabled NUMBER(5, 0) NULL
	 , CTGEnabled NUMBER(5, 0) NULL
	 , LastChangedOn DATETIME NULL
	 , AllowMultiCoverage BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.Prf_OfficeUDF (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , OfficeId NUMBER(10, 0) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.prf_PPO (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PPOSysId NUMBER(10, 0) NOT NULL
	 , ProfileId NUMBER(10, 0) NULL
	 , PPOId NUMBER(10, 0) NULL
	 , bStatus NUMBER(5, 0) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
	 , AutoSend NUMBER(5, 0) NULL
	 , AutoResend NUMBER(5, 0) NULL
	 , BypassMatching NUMBER(5, 0) NULL
	 , UseProviderNetworkEnrollment NUMBER(5, 0) NULL
	 , TieredTypeId NUMBER(5, 0) NULL
	 , Priority NUMBER(5, 0) NULL
	 , PolicyEffectiveDate DATETIME NULL
	 , BillFormType NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.prf_Profile (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProfileId NUMBER(10, 0) NOT NULL
	 , OfficeId NUMBER(10, 0) NULL
	 , CoverageId VARCHAR(2) NULL
	 , StateId VARCHAR(2) NULL
	 , AnHeader VARCHAR NULL
	 , AnFooter VARCHAR NULL
	 , ExHeader VARCHAR NULL
	 , ExFooter VARCHAR NULL
	 , AnalystEdits NUMBER(19, 0) NULL
	 , DxEdits NUMBER(10, 0) NULL
	 , DxNonTraumaDays NUMBER(10, 0) NULL
	 , DxNonSpecDays NUMBER(10, 0) NULL
	 , PrintCopies NUMBER(10, 0) NULL
	 , NewPvdState VARCHAR(2) NULL
	 , bDuration NUMBER(5, 0) NULL
	 , bLimits NUMBER(5, 0) NULL
	 , iDurPct NUMBER(5, 0) NULL
	 , iLimitPct NUMBER(5, 0) NULL
	 , PolicyLimit NUMBER(19, 4) NULL
	 , CoPayPercent NUMBER(10, 0) NULL
	 , CoPayMax NUMBER(19, 4) NULL
	 , Deductible NUMBER(19, 4) NULL
	 , PolicyWarn NUMBER(5, 0) NULL
	 , PolicyWarnPerc NUMBER(10, 0) NULL
	 , FeeSchedules NUMBER(10, 0) NULL
	 , DefaultProfile NUMBER(5, 0) NULL
	 , FeeAncillaryPct NUMBER(5, 0) NULL
	 , iGapdol NUMBER(5, 0) NULL
	 , iGapTreatmnt NUMBER(5, 0) NULL
	 , bGapTreatmnt NUMBER(5, 0) NULL
	 , bGapdol NUMBER(5, 0) NULL
	 , bPrintAdjustor NUMBER(5, 0) NULL
	 , sPrinterName VARCHAR(50) NULL
	 , ErEdits NUMBER(10, 0) NULL
	 , ErAllowedDays NUMBER(10, 0) NULL
	 , UcrFsRules NUMBER(10, 0) NULL
	 , LogoIdNo NUMBER(10, 0) NULL
	 , LogoJustify NUMBER(5, 0) NULL
	 , BillLine VARCHAR(50) NULL
	 , Version NUMBER(5, 0) NULL
	 , ClaimDeductible NUMBER(5, 0) NULL
	 , IncludeCommitted NUMBER(5, 0) NULL
	 , FLMedicarePercent NUMBER(5, 0) NULL
	 , UseLevelOfServiceUrl NUMBER(5, 0) NULL
	 , LevelOfServiceURL VARCHAR(250) NULL
	 , CCIPrimary NUMBER(5, 0) NULL
	 , CCISecondary NUMBER(5, 0) NULL
	 , CCIMutuallyExclusive NUMBER(5, 0) NULL
	 , CCIComprehensiveComponent NUMBER(5, 0) NULL
	 , PayDRGAllowance NUMBER(5, 0) NULL
	 , FLHospEmPriceOn NUMBER(5, 0) NULL
	 , EnableBillRelease NUMBER(5, 0) NULL
	 , DisableSubmitBill NUMBER(5, 0) NULL
	 , MaxPaymentsPerBill NUMBER(5, 0) NULL
	 , NoOfPmtPerBill NUMBER(10, 0) NULL
	 , DefaultDueDate NUMBER(5, 0) NULL
	 , CheckForNJCarePaths NUMBER(5, 0) NULL
	 , NJCarePathPercentFS NUMBER(5, 0) NULL
	 , ApplyEndnoteForNJCarePaths NUMBER(5, 0) NULL
	 , FLMedicarePercent2008 NUMBER(5, 0) NULL
	 , RequireEndnoteDuringOverride NUMBER(5, 0) NULL
	 , StorePerUnitFSandUCR NUMBER(5, 0) NULL
	 , UseProviderNetworkEnrollment NUMBER(5, 0) NULL
	 , UseASCRule NUMBER(5, 0) NULL
	 , AsstCoSurgeonEligible NUMBER(5, 0) NULL
	 , LastChangedOn DATETIME NULL
	 , IsNJPhysMedCapAfterCTG NUMBER(5, 0) NULL
	 , IsEligibleAmtFeeBased NUMBER(5, 0) NULL
	 , HideClaimTreeTotalsGrid NUMBER(5, 0) NULL
	 , SortBillsBy NUMBER(5, 0) NULL
	 , SortBillsByOrder NUMBER(5, 0) NULL
	 , ApplyNJEmergencyRoomBenchmarkFee NUMBER(5, 0) NULL
	 , AllowIcd10ForNJCarePaths NUMBER(5, 0) NULL
	 , EnableOverrideDeductible BOOLEAN NULL
	 , AnalyzeDiagnosisPointers BOOLEAN NULL
	 , MedicareFeePercent NUMBER(5, 0) NULL
	 , EnableSupplementalNdcData BOOLEAN NULL
	 , ApplyOriginalNdcAwp BOOLEAN NULL
	 , NdcAwpNotAvailable NUMBER(3, 0) NULL
	 , PayEapgAllowance NUMBER(5, 0) NULL
	 , MedicareInpatientApcEnabled BOOLEAN NULL
	 , MedicareOutpatientAscEnabled BOOLEAN NULL
	 , MedicareAscEnabled BOOLEAN NULL
	 , UseMedicareInpatientApcFee BOOLEAN NULL
	 , MedicareInpatientDrgEnabled BOOLEAN NULL
	 , MedicareInpatientDrgPricingType NUMBER(5, 0) NULL
	 , MedicarePhysicianEnabled BOOLEAN NULL
	 , MedicareAmbulanceEnabled BOOLEAN NULL
	 , MedicareDmeposEnabled BOOLEAN NULL
	 , MedicareAspDrugAndClinicalEnabled BOOLEAN NULL
	 , MedicareInpatientPricingType NUMBER(5, 0) NULL
	 , MedicareOutpatientPricingRulesEnabled BOOLEAN NULL
	 , MedicareAscPricingRulesEnabled BOOLEAN NULL
	 , NjUseAdmitTypeEnabled BOOLEAN NULL
	 , MedicareClinicalLabEnabled BOOLEAN NULL
	 , MedicareInpatientEnabled BOOLEAN NULL
	 , MedicareOutpatientApcEnabled BOOLEAN NULL
	 , MedicareAspDrugEnabled BOOLEAN NULL
	 , ShowAllocationsOnEob BOOLEAN NULL
	 , EmergencyCarePricingRuleId NUMBER(3, 0) NULL
	 , OutOfStatePricingEffectiveDateId NUMBER(3, 0) NULL
	 , PreAllocation BOOLEAN NULL
	 , AssistantCoSurgeonModifiers NUMBER(5, 0) NULL
	 , AssistantSurgeryModifierNotMedicallyNecessary NUMBER(5, 0) NULL
	 , AssistantSurgeryModifierRequireAdditionalDocument NUMBER(5, 0) NULL
	 , CoSurgeryModifierNotMedicallyNecessary NUMBER(5, 0) NULL
	 , CoSurgeryModifierRequireAdditionalDocument NUMBER(5, 0) NULL
	 , DxNoDiagnosisDays NUMBER(10, 0) NULL
	 , ModifierExempted BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.ProcedureCodeGroup (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProcedureCode VARCHAR(7) NOT NULL
	 , MajorCategory VARCHAR(500) NULL
	 , MinorCategory VARCHAR(500) NULL
);

CREATE TABLE IF NOT EXISTS src.ProcedureServiceCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProcedureServiceCategoryId NUMBER(3, 0) NOT NULL
	 , ProcedureServiceCategoryName VARCHAR(50) NULL
	 , ProcedureServiceCategoryDescription VARCHAR(100) NULL
	 , LegacyTableName VARCHAR(100) NULL
	 , LegacyBitValue NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.ProvidedLink( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProvidedLinkId NUMBER (10,0) NOT NULL
	 , Title VARCHAR (100) NULL
	 , URL VARCHAR (150) NULL
	 , OrderIndex NUMBER (3,0) NULL
 ); 
CREATE TABLE IF NOT EXISTS src.PROVIDER (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PvdIDNo NUMBER(10, 0) NOT NULL
	 , PvdMID NUMBER(10, 0) NULL
	 , PvdSource NUMBER(5, 0) NULL
	 , PvdTIN VARCHAR(15) NULL
	 , PvdLicNo VARCHAR(30) NULL
	 , PvdCertNo VARCHAR(30) NULL
	 , PvdLastName VARCHAR(60) NULL
	 , PvdFirstName VARCHAR(35) NULL
	 , PvdMI VARCHAR(1) NULL
	 , PvdTitle VARCHAR(5) NULL
	 , PvdGroup VARCHAR(60) NULL
	 , PvdAddr1 VARCHAR(55) NULL
	 , PvdAddr2 VARCHAR(55) NULL
	 , PvdCity VARCHAR(30) NULL
	 , PvdState VARCHAR(2) NULL
	 , PvdZip VARCHAR(12) NULL
	 , PvdZipPerf VARCHAR(12) NULL
	 , PvdPhone VARCHAR(25) NULL
	 , PvdFAX VARCHAR(13) NULL
	 , PvdSPC_List VARCHAR NULL
	 , PvdAuthNo VARCHAR(30) NULL
	 , PvdSPC_ACD VARCHAR(2) NULL
	 , PvdUpdateCounter NUMBER(5, 0) NULL
	 , PvdPPO_Provider NUMBER(5, 0) NULL
	 , PvdFlags NUMBER(10, 0) NULL
	 , PvdERRate NUMBER(19, 4) NULL
	 , PvdSubNet VARCHAR(4) NULL
	 , InUse VARCHAR(100) NULL
	 , PvdStatus NUMBER(10, 0) NULL
	 , PvdElectroStartDate DATETIME NULL
	 , PvdElectroEndDate DATETIME NULL
	 , PvdAccredStartDate DATETIME NULL
	 , PvdAccredEndDate DATETIME NULL
	 , PvdRehabStartDate DATETIME NULL
	 , PvdRehabEndDate DATETIME NULL
	 , PvdTraumaStartDate DATETIME NULL
	 , PvdTraumaEndDate DATETIME NULL
	 , OPCERT VARCHAR(7) NULL
	 , PvdDentalStartDate DATETIME NULL
	 , PvdDentalEndDate DATETIME NULL
	 , PvdNPINo VARCHAR(10) NULL
	 , PvdCMSId VARCHAR(6) NULL
	 , CreateDate DATETIME NULL
	 , LastChangedOn DATETIME NULL
);

CREATE TABLE IF NOT EXISTS src.ProviderCluster (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PvdIDNo NUMBER(10, 0) NOT NULL
	 , OrgOdsCustomerId NUMBER(10, 0) NOT NULL
	 , MitchellProviderKey VARCHAR(200) NULL
	 , ProviderClusterKey VARCHAR(200) NULL
	 , ProviderType VARCHAR(30) NULL
);

CREATE TABLE IF NOT EXISTS src.ProviderNetworkEventLog (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , IDField NUMBER(10, 0) NOT NULL
	 , LogDate DATETIME NULL
	 , EventId NUMBER(10, 0) NULL
	 , ClaimIdNo NUMBER(10, 0) NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , UserId NUMBER(10, 0) NULL
	 , NetworkId NUMBER(10, 0) NULL
	 , FileName VARCHAR(255) NULL
	 , ExtraText VARCHAR(1000) NULL
	 , ProcessInfo NUMBER(5, 0) NULL
	 , TieredTypeID NUMBER(5, 0) NULL
	 , TierNumber NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.ProviderNumberCriteria (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProviderNumberCriteriaId NUMBER(5, 0) NOT NULL
	 , ProviderNumber NUMBER(10, 0) NULL
	 , Priority NUMBER(3, 0) NULL
	 , FeeScheduleTable VARCHAR(1) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
);

CREATE TABLE IF NOT EXISTS src.ProviderNumberCriteriaRevenueCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProviderNumberCriteriaId NUMBER(5, 0) NOT NULL
	 , RevenueCode VARCHAR(4) NOT NULL
	 , MatchingProfileNumber NUMBER(3, 0) NULL
	 , AttributeMatchTypeId NUMBER(3, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.ProviderNumberCriteriaTypeOfBill (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProviderNumberCriteriaId NUMBER(5, 0) NOT NULL
	 , TypeOfBill VARCHAR(4) NOT NULL
	 , MatchingProfileNumber NUMBER(3, 0) NULL
	 , AttributeMatchTypeId NUMBER(3, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.ProviderSpecialty (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProviderId NUMBER(10, 0) NOT NULL
	 , SpecialtyCode VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.ProviderSpecialtyToProvType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProviderType VARCHAR(20) NOT NULL
	 , ProviderType_Desc VARCHAR(80) NULL
	 , Specialty VARCHAR(20) NOT NULL
	 , Specialty_Desc VARCHAR(80) NULL
	 , CreateDate DATETIME NULL
	 , ModifyDate DATETIME NULL
	 , LogicalDelete VARCHAR(1) NULL
);

CREATE TABLE IF NOT EXISTS src.Provider_ClientRef (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PvdIdNo NUMBER(10, 0) NOT NULL
	 , ClientRefId VARCHAR(50) NULL
	 , ClientRefId2 VARCHAR(100) NULL
);

CREATE TABLE IF NOT EXISTS src.Provider_Rendering (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PvdIDNo NUMBER(10, 0) NOT NULL
	 , RenderingAddr1 VARCHAR(55) NULL
	 , RenderingAddr2 VARCHAR(55) NULL
	 , RenderingCity VARCHAR(30) NULL
	 , RenderingState VARCHAR(2) NULL
	 , RenderingZip VARCHAR(12) NULL
);

CREATE TABLE IF NOT EXISTS src.ReferenceBillApcLines (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , Line_No NUMBER(5, 0) NOT NULL
	 , PaymentAPC VARCHAR(5) NULL
	 , ServiceIndicator VARCHAR(2) NULL
	 , PaymentIndicator VARCHAR(1) NULL
	 , OutlierAmount NUMBER(19, 4) NULL
	 , PricerAllowed NUMBER(19, 4) NULL
	 , MedicareAmount NUMBER(19, 4) NULL
);

CREATE TABLE IF NOT EXISTS src.ReferenceSupplementBillApcLines (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , SeqNo NUMBER(5, 0) NOT NULL
	 , Line_No NUMBER(5, 0) NOT NULL
	 , PaymentAPC VARCHAR(5) NULL
	 , ServiceIndicator VARCHAR(2) NULL
	 , PaymentIndicator VARCHAR(1) NULL
	 , OutlierAmount NUMBER(19, 4) NULL
	 , PricerAllowed NUMBER(19, 4) NULL
	 , MedicareAmount NUMBER(19, 4) NULL
);

CREATE TABLE IF NOT EXISTS src.RenderingNpiStates( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ApplicationSettingsId NUMBER (10,0) NOT NULL
	 , State VARCHAR (2) NOT NULL
 ); 
CREATE TABLE IF NOT EXISTS src.RevenueCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RevenueCode VARCHAR(4) NOT NULL
	 , RevenueCodeSubCategoryId NUMBER(3, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.RevenueCodeCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RevenueCodeCategoryId NUMBER(3, 0) NOT NULL
	 , Description VARCHAR(100) NULL
	 , NarrativeInformation VARCHAR(1000) NULL
);

CREATE TABLE IF NOT EXISTS src.RevenueCodeSubcategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RevenueCodeSubcategoryId NUMBER(3, 0) NOT NULL
	 , RevenueCodeCategoryId NUMBER(3, 0) NULL
	 , Description VARCHAR(100) NULL
	 , NarrativeInformation VARCHAR(1000) NULL
);

CREATE TABLE IF NOT EXISTS src.RPT_RsnCategories (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CategoryIdNo NUMBER(5, 0) NOT NULL
	 , CatDesc VARCHAR(50) NULL
	 , Priority NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.rsn_Override (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , ShortDesc VARCHAR(50) NULL
	 , LongDesc VARCHAR NULL
	 , CategoryIdNo NUMBER(5, 0) NULL
	 , ClientSpec NUMBER(5, 0) NULL
	 , COAIndex NUMBER(5, 0) NULL
	 , NJPenaltyPct NUMBER(9, 6) NULL
	 , NetworkID NUMBER(10, 0) NULL
	 , SpecialProcessing BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.rsn_REASONS (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , CV_Type VARCHAR(2) NULL
	 , ShortDesc VARCHAR(50) NULL
	 , LongDesc VARCHAR NULL
	 , CategoryIdNo NUMBER(10, 0) NULL
	 , COAIndex NUMBER(5, 0) NULL
	 , OverrideEndnote NUMBER(10, 0) NULL
	 , HardEdit NUMBER(5, 0) NULL
	 , SpecialProcessing BOOLEAN NULL
	 , EndnoteActionId NUMBER(3, 0) NULL
	 , RetainForEapg BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.Rsn_Reasons_3rdParty (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , ShortDesc VARCHAR(50) NULL
	 , LongDesc VARCHAR NULL
);

CREATE TABLE IF NOT EXISTS src.RuleType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleTypeID NUMBER(10, 0) NOT NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR(150) NULL
);

CREATE TABLE IF NOT EXISTS src.ScriptAdvisorBillSource (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillSourceId NUMBER(3, 0) NOT NULL
	 , BillSource VARCHAR(15) NULL
);

CREATE TABLE IF NOT EXISTS src.ScriptAdvisorSettings (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ScriptAdvisorSettingsId NUMBER(3, 0) NOT NULL
	 , IsPharmacyEligible BOOLEAN NULL
	 , EnableSendCardToClaimant BOOLEAN NULL
	 , EnableBillSource BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.ScriptAdvisorSettingsCoverageType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ScriptAdvisorSettingsId NUMBER(3, 0) NOT NULL
	 , CoverageType VARCHAR(2) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.SEC_RightGroups (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RightGroupId NUMBER(10, 0) NOT NULL
	 , RightGroupName VARCHAR(50) NULL
	 , RightGroupDescription VARCHAR(150) NULL
	 , CreatedDate DATETIME NULL
	 , CreatedBy VARCHAR(50) NULL
);

CREATE TABLE IF NOT EXISTS src.SEC_Users (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , UserId NUMBER(10, 0) NOT NULL
	 , LoginName VARCHAR(15) NULL
	 , Password VARCHAR(30) NULL
	 , CreatedBy VARCHAR(50) NULL
	 , CreatedDate DATETIME NULL
	 , UserStatus NUMBER(10, 0) NULL
	 , FirstName VARCHAR(20) NULL
	 , LastName VARCHAR(20) NULL
	 , AccountLocked NUMBER(5, 0) NULL
	 , LockedCounter NUMBER(5, 0) NULL
	 , PasswordCreateDate DATETIME NULL
	 , PasswordCaseFlag NUMBER(5, 0) NULL
	 , ePassword VARCHAR(30) NULL
	 , CurrentSettings VARCHAR NULL
);

CREATE TABLE IF NOT EXISTS src.SEC_User_OfficeGroups (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , SECUserOfficeGroupId NUMBER(10, 0) NOT NULL
	 , UserId NUMBER(10, 0) NULL
	 , OffcGroupId NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.SEC_User_RightGroups (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , SECUserRightGroupId NUMBER(10, 0) NOT NULL
	 , UserId NUMBER(10, 0) NULL
	 , RightGroupId NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.SentryRuleTypeCriteria (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleTypeId NUMBER(10, 0) NOT NULL
	 , CriteriaId NUMBER(10, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.SENTRY_ACTION (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ActionID NUMBER(10, 0) NOT NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR(100) NULL
	 , CompatibilityKey VARCHAR(50) NULL
	 , PredefinedValues VARCHAR NULL
	 , ValueDataType VARCHAR(50) NULL
	 , ValueFormat VARCHAR(250) NULL
	 , BillLineAction NUMBER(10, 0) NULL
	 , AnalyzeFlag NUMBER(5, 0) NULL
	 , ActionCategoryIDNo NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.SENTRY_ACTION_CATEGORY (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ActionCategoryIDNo NUMBER(10, 0) NOT NULL
	 , Description VARCHAR(60) NULL
);

CREATE TABLE IF NOT EXISTS src.SENTRY_CRITERIA (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CriteriaID NUMBER(10, 0) NOT NULL
	 , ParentName VARCHAR(50) NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR(150) NULL
	 , Operators VARCHAR(50) NULL
	 , PredefinedValues VARCHAR NULL
	 , ValueDataType VARCHAR(50) NULL
	 , ValueFormat VARCHAR(250) NULL
	 , NullAllowed NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.SENTRY_PROFILE_RULE (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProfileID NUMBER(10, 0) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , Priority NUMBER(10, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.SENTRY_RULE (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR NULL
	 , CreatedBy VARCHAR(50) NULL
	 , CreationDate DATETIME NULL
	 , PostFixNotation VARCHAR NULL
	 , Priority NUMBER(10, 0) NULL
	 , RuleTypeID NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.SENTRY_RULE_ACTION_DETAIL (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , LineNumber NUMBER(10, 0) NOT NULL
	 , ActionID NUMBER(10, 0) NULL
	 , ActionValue VARCHAR(1000) NULL
);

CREATE TABLE IF NOT EXISTS src.SENTRY_RULE_ACTION_HEADER (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , EndnoteShort VARCHAR(50) NULL
	 , EndnoteLong VARCHAR NULL
);

CREATE TABLE IF NOT EXISTS src.SENTRY_RULE_CONDITION (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , LineNumber NUMBER(10, 0) NOT NULL
	 , GroupFlag VARCHAR(50) NULL
	 , CriteriaID NUMBER(10, 0) NULL
	 , Operator VARCHAR(50) NULL
	 , ConditionValue VARCHAR(60) NULL
	 , AndOr VARCHAR(50) NULL
	 , UdfConditionId NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.SPECIALTY (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , SpcIdNo NUMBER(10, 0) NULL
	 , Code VARCHAR(50) NOT NULL
	 , Description VARCHAR(70) NULL
	 , PayeeSubTypeID NUMBER(10, 0) NULL
	 , TieredTypeID NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.StateSettingMedicare (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingMedicareId NUMBER(10, 0) NOT NULL
	 , PayPercentOfMedicareFee BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.StateSettingsFlorida (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsFloridaId NUMBER(10, 0) NOT NULL
	 , ClaimantInitialServiceOption NUMBER(5, 0) NULL
	 , ClaimantInitialServiceDays NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.StateSettingsHawaii (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsHawaiiId NUMBER(10, 0) NOT NULL
	 , PhysicalMedicineLimitOption NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.StateSettingsNewJersey (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsNewJerseyId NUMBER(10, 0) NOT NULL
	 , ByPassEmergencyServices BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.StateSettingsNewJerseyPolicyPreference (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PolicyPreferenceId NUMBER(10, 0) NOT NULL
	 , ShareCoPayMaximum BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.StateSettingsNewYorkPolicyPreference (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PolicyPreferenceId NUMBER(10, 0) NOT NULL
	 , ShareCoPayMaximum BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.StateSettingsNY (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsNYID NUMBER(10, 0) NOT NULL
	 , NF10PrintDate BOOLEAN NULL
	 , NF10CheckBox1 BOOLEAN NULL
	 , NF10CheckBox18 BOOLEAN NULL
	 , NF10UseUnderwritingCompany BOOLEAN NULL
	 , UnderwritingCompanyUdfId NUMBER(10, 0) NULL
	 , NaicUdfId NUMBER(10, 0) NULL
	 , DisplayNYPrintOptionsWhenZosOrSojIsNY BOOLEAN NULL
	 , NF10DuplicatePrint BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.StateSettingsNyRoomRate (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsNyRoomRateId NUMBER(10, 0) NOT NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
	 , RoomRate NUMBER(19, 4) NULL
);

CREATE TABLE IF NOT EXISTS src.StateSettingsOregon (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsOregonId NUMBER(3, 0) NOT NULL
	 , ApplyOregonFeeSchedule BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.StateSettingsOregonCoverageType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsOregonId NUMBER(3, 0) NOT NULL
	 , CoverageType VARCHAR(2) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.SupplementBillApportionmentEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillId NUMBER(10, 0) NOT NULL
	 , SequenceNumber NUMBER(5, 0) NOT NULL
	 , LineNumber NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.SupplementBillCustomEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillId NUMBER(10, 0) NOT NULL
	 , SequenceNumber NUMBER(5, 0) NOT NULL
	 , LineNumber NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.SupplementBill_Pharm_ApportionmentEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillId NUMBER(10, 0) NOT NULL
	 , SequenceNumber NUMBER(5, 0) NOT NULL
	 , LineNumber NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.SupplementPreCtgDeniedLinesEligibleToPenalty( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER (10,0) NOT NULL
	 , LineNumber NUMBER (5,0) NOT NULL
	 , CtgPenaltyTypeId NUMBER (3,0) NOT NULL
	 , SeqNo NUMBER (5,0) NOT NULL
 ); 
CREATE TABLE IF NOT EXISTS src.SurgicalModifierException (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Modifier VARCHAR(2) NOT NULL
	 , State VARCHAR(2) NOT NULL
	 , CoverageType VARCHAR(2) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
);

CREATE TABLE IF NOT EXISTS src.Tag (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TagId NUMBER(10, 0) NOT NULL
	 , NAME VARCHAR(50) NULL
	 , DateCreated TIMESTAMP_LTZ(7) NULL
	 , DateModified TIMESTAMP_LTZ(7) NULL
	 , CreatedBy VARCHAR(15) NULL
	 , ModifiedBy VARCHAR(15) NULL
);

CREATE TABLE IF NOT EXISTS src.TreatmentCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TreatmentCategoryId NUMBER(3, 0) NOT NULL
	 , Category VARCHAR(50) NULL
	 , Metadata VARCHAR NULL
);

CREATE TABLE IF NOT EXISTS src.TreatmentCategoryRange (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TreatmentCategoryRangeId NUMBER(10, 0) NOT NULL
	 , TreatmentCategoryId NUMBER(3, 0) NULL
	 , StartRange VARCHAR(7) NULL
	 , EndRange VARCHAR(7) NULL
);

CREATE TABLE IF NOT EXISTS src.Ub_Apc_Dict (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , APC VARCHAR(5) NOT NULL
	 , Description VARCHAR(255) NULL
);

CREATE TABLE IF NOT EXISTS src.UB_BillType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TOB VARCHAR(4) NOT NULL
	 , Description VARCHAR NULL
	 , Flag NUMBER(10, 0) NULL
	 , UB_BillTypeID NUMBER(10, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.UB_RevenueCodes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RevenueCode VARCHAR(4) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , PRC_DESC VARCHAR NULL
	 , Flags NUMBER(10, 0) NULL
	 , Vague VARCHAR(1) NULL
	 , PerVisit NUMBER(5, 0) NULL
	 , PerClaimant NUMBER(5, 0) NULL
	 , PerProvider NUMBER(5, 0) NULL
	 , BodyFlags NUMBER(10, 0) NULL
	 , DrugFlag NUMBER(5, 0) NULL
	 , CurativeFlag NUMBER(5, 0) NULL
	 , RevenueCodeSubCategoryId NUMBER(3, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.UDFBill (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
	 , UDFValueText VARCHAR(255) NULL
	 , UDFValueDecimal NUMBER(19, 4) NULL
	 , UDFValueDate DATETIME NULL
);

CREATE TABLE IF NOT EXISTS src.UDFClaim (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ClaimIdNo NUMBER(10, 0) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
	 , UDFValueText VARCHAR(255) NULL
	 , UDFValueDecimal NUMBER(19, 4) NULL
	 , UDFValueDate DATETIME NULL
);

CREATE TABLE IF NOT EXISTS src.UDFClaimant (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CmtIdNo NUMBER(10, 0) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
	 , UDFValueText VARCHAR(255) NULL
	 , UDFValueDecimal NUMBER(19, 4) NULL
	 , UDFValueDate DATETIME NULL
);

CREATE TABLE IF NOT EXISTS src.UdfDataFormat (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , UdfDataFormatId NUMBER(5, 0) NOT NULL
	 , DataFormatName VARCHAR(30) NULL
);

CREATE TABLE IF NOT EXISTS src.UDFLevelChangeTracking (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , UDFLevelChangeTrackingId NUMBER(10, 0) NOT NULL
	 , EntityType NUMBER(10, 0) NULL
	 , EntityId NUMBER(10, 0) NULL
	 , CorrelationId VARCHAR(50) NULL
	 , UDFId NUMBER(10, 0) NULL
	 , PreviousValue VARCHAR NULL
	 , UpdatedValue VARCHAR NULL
	 , UserId NUMBER(10, 0) NULL
	 , ChangeDate DATETIME NULL
);

CREATE TABLE IF NOT EXISTS src.UDFLibrary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
	 , UDFName VARCHAR(50) NULL
	 , ScreenType NUMBER(5, 0) NULL
	 , UDFDescription VARCHAR(1000) NULL
	 , DataFormat NUMBER(5, 0) NULL
	 , RequiredField NUMBER(5, 0) NULL
	 , ReadOnly NUMBER(5, 0) NULL
	 , Invisible NUMBER(5, 0) NULL
	 , TextMaxLength NUMBER(5, 0) NULL
	 , TextMask VARCHAR(50) NULL
	 , TextEnforceLength NUMBER(5, 0) NULL
	 , RestrictRange NUMBER(5, 0) NULL
	 , MinValDecimal FLOAT(24) NULL
	 , MaxValDecimal FLOAT(24) NULL
	 , MinValDate DATETIME NULL
	 , MaxValDate DATETIME NULL
	 , ListAllowMultiple NUMBER(5, 0) NULL
	 , DefaultValueText VARCHAR(100) NULL
	 , DefaultValueDecimal FLOAT(24) NULL
	 , DefaultValueDate DATETIME NULL
	 , UseDefault NUMBER(5, 0) NULL
	 , ReqOnSubmit NUMBER(5, 0) NULL
	 , IncludeDateButton BOOLEAN NULL
);

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

CREATE TABLE IF NOT EXISTS src.UDFProvider (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PvdIdNo NUMBER(10, 0) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
	 , UDFValueText VARCHAR(255) NULL
	 , UDFValueDecimal NUMBER(19, 4) NULL
	 , UDFValueDate DATETIME NULL
);

CREATE TABLE IF NOT EXISTS src.UDFViewOrder (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , OfficeId NUMBER(10, 0) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
	 , ViewOrder NUMBER(5, 0) NULL
);

CREATE TABLE IF NOT EXISTS src.UDF_Sentry_Criteria (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , UdfIdNo NUMBER(10, 0) NULL
	 , CriteriaID NUMBER(10, 0) NOT NULL
	 , ParentName VARCHAR(50) NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR(1000) NULL
	 , Operators VARCHAR(50) NULL
	 , PredefinedValues VARCHAR NULL
	 , ValueDataType VARCHAR(50) NULL
	 , ValueFormat VARCHAR(50) NULL
);

CREATE TABLE IF NOT EXISTS src.Vpn (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , VpnId NUMBER(5, 0) NOT NULL
	 , NetworkName VARCHAR(50) NULL
	 , PendAndSend BOOLEAN NULL
	 , BypassMatching BOOLEAN NULL
	 , AllowsResends BOOLEAN NULL
	 , OdsEligible BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.VPNActivityFlag (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Activity_Flag VARCHAR(1) NOT NULL
	 , AF_Description VARCHAR(50) NULL
	 , AF_ShortDesc VARCHAR(50) NULL
	 , Data_Source VARCHAR(5) NULL
	 , Default_Billable BOOLEAN NULL
	 , Credit BOOLEAN NULL
);

CREATE TABLE IF NOT EXISTS src.VPNBillableFlags (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , SOJ VARCHAR(2) NOT NULL
	 , NetworkID NUMBER(10, 0) NOT NULL
	 , ActivityFlag VARCHAR(2) NOT NULL
	 , Billable VARCHAR(1) NULL
	 , CompanyCode VARCHAR(10) NOT NULL
	 , CompanyName VARCHAR(100) NULL
);

CREATE TABLE IF NOT EXISTS src.VpnBillingCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , VpnBillingCategoryCode VARCHAR(1) NOT NULL
	 , VpnBillingCategoryDescription VARCHAR(30) NULL
);

CREATE TABLE IF NOT EXISTS src.VpnLedger (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TransactionID NUMBER(19, 0) NOT NULL
	 , TransactionTypeID NUMBER(10, 0) NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , Line_No NUMBER(5, 0) NULL
	 , Charged NUMBER(19, 4) NULL
	 , DPAllowed NUMBER(19, 4) NULL
	 , VPNAllowed NUMBER(19, 4) NULL
	 , Savings NUMBER(19, 4) NULL
	 , Credits NUMBER(19, 4) NULL
	 , HasOverride BOOLEAN NULL
	 , EndNotes VARCHAR(200) NULL
	 , NetworkIdNo NUMBER(10, 0) NULL
	 , ProcessFlag NUMBER(5, 0) NULL
	 , LineType NUMBER(10, 0) NULL
	 , DateTimeStamp DATETIME NULL
	 , SeqNo NUMBER(10, 0) NULL
	 , VPN_Ref_Line_No NUMBER(5, 0) NULL
	 , SpecialProcessing BOOLEAN NULL
	 , CreateDate DATETIME NULL
	 , LastChangedOn DATETIME NULL
	 , AdjustedCharged NUMBER(19, 4) NULL
);

CREATE TABLE IF NOT EXISTS src.VpnProcessFlagType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , VpnProcessFlagTypeId NUMBER(5, 0) NOT NULL
	 , VpnProcessFlagType VARCHAR(50) NULL
);

CREATE TABLE IF NOT EXISTS src.VpnSavingTransactionType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , VpnSavingTransactionTypeId NUMBER(10, 0) NOT NULL
	 , VpnSavingTransactionType VARCHAR(50) NULL
);

CREATE TABLE IF NOT EXISTS src.Vpn_Billing_History (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Customer VARCHAR(50) NULL
	 , TransactionID NUMBER(19, 0) NOT NULL
	 , Period DATETIME NOT NULL
	 , ActivityFlag VARCHAR(1) NULL
	 , BillableFlag VARCHAR(1) NULL
	 , Void VARCHAR(4) NULL
	 , CreditType VARCHAR(10) NULL
	 , Network VARCHAR(50) NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , Line_No NUMBER(5, 0) NULL
	 , TransactionDate DATETIME NULL
	 , RepriceDate DATETIME NULL
	 , ClaimNo VARCHAR(50) NULL
	 , ProviderCharges NUMBER(19, 4) NULL
	 , DPAllowed NUMBER(19, 4) NULL
	 , VPNAllowed NUMBER(19, 4) NULL
	 , Savings NUMBER(19, 4) NULL
	 , Credits NUMBER(19, 4) NULL
	 , NetSavings NUMBER(19, 4) NULL
	 , SOJ VARCHAR(2) NULL
	 , seqno NUMBER(10, 0) NULL
	 , CompanyCode VARCHAR(10) NULL
	 , VpnId NUMBER(5, 0) NULL
	 , ProcessFlag NUMBER(5, 0) NULL
	 , SK NUMBER(10, 0) NULL
	 , DATABASE_NAME VARCHAR(100) NULL
	 , SubmittedToFinance BOOLEAN NULL
	 , IsInitialLoad BOOLEAN NULL
	 , VpnBillingCategoryCode VARCHAR(1) NULL
);

CREATE TABLE IF NOT EXISTS src.WeekEndsAndHolidays (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DayOfWeekDate DATETIME NULL
	 , DayName VARCHAR(3) NULL
	 , WeekEndsAndHolidayId NUMBER(10, 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS src.Zip2County (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Zip VARCHAR(5) NOT NULL
	 , County VARCHAR(50) NULL
	 , State VARCHAR(2) NULL
);

CREATE TABLE IF NOT EXISTS src.ZipCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ZipCode VARCHAR(5) NOT NULL
	 , PrimaryRecord BOOLEAN NULL
	 , STATE VARCHAR(2) NULL
	 , City VARCHAR(30) NULL
	 , CityAlias VARCHAR(30) NOT NULL
	 , County VARCHAR(30) NULL
	 , Cbsa VARCHAR(5) NULL
	 , CbsaType VARCHAR(5) NULL
	 , ZipCodeRegionId NUMBER(3, 0) NULL
);

CREATE OR REPLACE TABLE stg.AcceptedTreatmentDate (
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

CREATE OR REPLACE TABLE stg.Adjustment3603rdPartyEndNoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.Adjustment360ApcEndNoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.Adjustment360Category (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Adjustment360CategoryId NUMBER(10, 0) NOT NULL
	 , Name VARCHAR(50) NULL
);

CREATE OR REPLACE TABLE stg.Adjustment360EndNoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId NUMBER(10, 0) NULL
	 , EndnoteTypeId NUMBER(3, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.Adjustment360OverrideEndNoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.Adjustment360SubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Adjustment360SubCategoryId NUMBER(10, 0) NOT NULL
	 , Name VARCHAR(50) NULL
	 , Adjustment360CategoryId NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.Adjustment3rdPartyEndnoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId VARCHAR(100) NULL
);

CREATE OR REPLACE TABLE stg.AdjustmentApcEndNoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId VARCHAR(100) NULL
);

CREATE OR REPLACE TABLE stg.AdjustmentEndNoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId VARCHAR(100) NULL
);

CREATE OR REPLACE TABLE stg.AdjustmentOverrideEndNoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , SubCategoryId VARCHAR(100) NULL
);

CREATE OR REPLACE TABLE stg.Adjustor (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , lAdjIdNo NUMBER(10, 0) NOT NULL
	 , IDNumber VARCHAR(15) NULL
	 , Lastname VARCHAR(30) NULL
	 , FirstName VARCHAR(30) NULL
	 , Address1 VARCHAR(30) NULL
	 , Address2 VARCHAR(30) NULL
	 , City VARCHAR(30) NULL
	 , State VARCHAR(2) NULL
	 , ZipCode VARCHAR(12) NULL
	 , Phone VARCHAR(25) NULL
	 , Fax VARCHAR(25) NULL
	 , Office VARCHAR(120) NULL
	 , EMail VARCHAR(60) NULL
	 , InUse VARCHAR(100) NULL
	 , OfficeIdNo NUMBER(10, 0) NULL
	 , UserId NUMBER(10, 0) NULL
	 , CreateDate DATETIME NULL
	 , LastChangedOn DATETIME NULL
);

CREATE OR REPLACE TABLE stg.AnalysisGroup (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , AnalysisGroupId NUMBER(10, 0) NOT NULL
	 , GroupName VARCHAR(200) NULL
);

CREATE OR REPLACE TABLE stg.AnalysisRule (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , AnalysisRuleId NUMBER(10, 0) NOT NULL
	 , Title VARCHAR(200) NULL
	 , AssemblyQualifiedName VARCHAR(200) NULL
	 , MethodToInvoke VARCHAR(50) NULL
	 , DisplayMessage VARCHAR(200) NULL
	 , DisplayOrder NUMBER(10, 0) NULL
	 , IsActive BOOLEAN NULL
	 , CreateDate TIMESTAMP_LTZ(7) NULL
	 , LastChangedOn TIMESTAMP_LTZ(7) NULL
	 , MessageToken VARCHAR(200) NULL
);

CREATE OR REPLACE TABLE stg.AnalysisRuleGroup (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , AnalysisRuleGroupId NUMBER(10, 0) NOT NULL
	 , AnalysisRuleId NUMBER(10, 0) NULL
	 , AnalysisGroupId NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.AnalysisRuleThreshold (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , AnalysisRuleThresholdId NUMBER(10, 0) NOT NULL
	 , AnalysisRuleId NUMBER(10, 0) NULL
	 , ThresholdKey VARCHAR(50) NULL
	 , ThresholdValue VARCHAR(100) NULL
	 , CreateDate TIMESTAMP_LTZ(7) NULL
	 , LastChangedOn TIMESTAMP_LTZ(7) NULL
);

CREATE OR REPLACE TABLE stg.ApportionmentEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ApportionmentEndnote NUMBER(10, 0) NOT NULL
	 , ShortDescription VARCHAR(50) NULL
	 , LongDescription VARCHAR(500) NULL
);

CREATE OR REPLACE TABLE stg.BillAdjustment (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillLineAdjustmentId NUMBER(19, 0) NOT NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , LineNumber NUMBER(10, 0) NULL
	 , Adjustment NUMBER(19, 4) NULL
	 , EndNote NUMBER(10, 0) NULL
	 , EndNoteTypeId NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.BillApportionmentEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillId NUMBER(10, 0) NOT NULL
	 , LineNumber NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.BillCustomEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillId NUMBER(10, 0) NOT NULL
	 , LineNumber NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.BillExclusionLookUpTable (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReportID NUMBER(3, 0) NOT NULL
	 , ReportName VARCHAR(100) NULL
);

CREATE OR REPLACE TABLE stg.Bills( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER (10,0) NULL
	 , LINE_NO NUMBER (5,0) NULL
	 , LINE_NO_DISP NUMBER (5,0) NULL
	 , OVER_RIDE NUMBER (5,0) NULL
	 , DT_SVC DATETIME NULL
	 , PRC_CD VARCHAR (7) NULL
	 , UNITS FLOAT NULL
	 , TS_CD VARCHAR (14) NULL
	 , CHARGED NUMBER (19,4) NULL
	 , ALLOWED NUMBER (19,4) NULL
	 , ANALYZED NUMBER (19,4) NULL
	 , REASON1 NUMBER (10,0) NULL
	 , REASON2 NUMBER (10,0) NULL
	 , REASON3 NUMBER (10,0) NULL
	 , REASON4 NUMBER (10,0) NULL
	 , REASON5 NUMBER (10,0) NULL
	 , REASON6 NUMBER (10,0) NULL
	 , REASON7 NUMBER (10,0) NULL
	 , REASON8 NUMBER (10,0) NULL
	 , REF_LINE_NO NUMBER (5,0) NULL
	 , SUBNET VARCHAR (9) NULL
	 , OverrideReason NUMBER (5,0) NULL
	 , FEE_SCHEDULE NUMBER (19,4) NULL
	 , POS_RevCode VARCHAR (4) NULL
	 , CTGPenalty NUMBER (19,4) NULL
	 , PrePPOAllowed NUMBER (19,4) NULL
	 , PPODate DATETIME NULL
	 , PPOCTGPenalty NUMBER (19,4) NULL
	 , UCRPerUnit NUMBER (19,4) NULL
	 , FSPerUnit NUMBER (19,4) NULL
	 , HCRA_Surcharge NUMBER (19,4) NULL
	 , EligibleAmt NUMBER (19,4) NULL
	 , DPAllowed NUMBER (19,4) NULL
	 , EndDateOfService DATETIME NULL
	 , AnalyzedCtgPenalty NUMBER (19,4) NULL
	 , AnalyzedCtgPpoPenalty NUMBER (19,4) NULL
	 , RepackagedNdc VARCHAR (13) NULL
	 , OriginalNdc VARCHAR (13) NULL
	 , UnitOfMeasureId NUMBER (3,0) NULL
	 , PackageTypeOriginalNdc VARCHAR (2) NULL
	 , ServiceCode VARCHAR (25) NULL
	 , PreApportionedAmount NUMBER (19,4) NULL
	 , DeductibleApplied NUMBER (19,4) NULL
	 , BillReviewResults NUMBER (19,4) NULL
	 , PreOverriddenDeductible NUMBER (19,4) NULL
	 , RemainingBalance NUMBER (19,4) NULL
	 , CtgCoPayPenalty NUMBER (19,4) NULL
	 , PpoCtgCoPayPenaltyPercentage NUMBER (19,4) NULL
	 , AnalyzedCtgCoPayPenalty NUMBER (19,4) NULL
	 , AnalyzedPpoCtgCoPayPenaltyPercentage NUMBER (19,4) NULL
	 , CtgVunPenalty NUMBER (19,4) NULL
	 , PpoCtgVunPenaltyPercentage NUMBER (19,4) NULL
	 , AnalyzedCtgVunPenalty NUMBER (19,4) NULL
	 , AnalyzedPpoCtgVunPenaltyPercentage NUMBER (19,4) NULL
	 , RenderingNpi VARCHAR (15) NULL
 ); 
CREATE OR REPLACE TABLE stg.BillsOverride (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillsOverrideID NUMBER(10, 0) NOT NULL
	 , BillIDNo NUMBER(10, 0) NULL
	 , LINE_NO NUMBER(5, 0) NULL
	 , UserId NUMBER(10, 0) NULL
	 , DateSaved DATETIME NULL
	 , AmountBefore NUMBER(19, 4) NULL
	 , AmountAfter NUMBER(19, 4) NULL
	 , CodesOverrode VARCHAR(50) NULL
	 , SeqNo NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.BillsProviderNetwork (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , NetworkId NUMBER(10, 0) NULL
	 , NetworkName VARCHAR(50) NULL
);

CREATE OR REPLACE TABLE stg.BILLS_CTG_Endnotes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , Line_No NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
	 , RuleType VARCHAR(2) NULL
	 , RuleId NUMBER(10, 0) NULL
	 , PreCertAction NUMBER(5, 0) NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.BILLS_DRG (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , PricerPassThru NUMBER(19, 4) NULL
	 , PricerCapital_Outlier_Amt NUMBER(19, 4) NULL
	 , PricerCapital_OldHarm_Amt NUMBER(19, 4) NULL
	 , PricerCapital_IME_Amt NUMBER(19, 4) NULL
	 , PricerCapital_HSP_Amt NUMBER(19, 4) NULL
	 , PricerCapital_FSP_Amt NUMBER(19, 4) NULL
	 , PricerCapital_Exceptions_Amt NUMBER(19, 4) NULL
	 , PricerCapital_DSH_Amt NUMBER(19, 4) NULL
	 , PricerCapitalPayment NUMBER(19, 4) NULL
	 , PricerDSH NUMBER(19, 4) NULL
	 , PricerIME NUMBER(19, 4) NULL
	 , PricerCostOutlier NUMBER(19, 4) NULL
	 , PricerHSP NUMBER(19, 4) NULL
	 , PricerFSP NUMBER(19, 4) NULL
	 , PricerTotalPayment NUMBER(19, 4) NULL
	 , PricerReturnMsg VARCHAR(255) NULL
	 , ReturnDRG VARCHAR(3) NULL
	 , ReturnDRGDesc VARCHAR(66) NULL
	 , ReturnMDC VARCHAR(3) NULL
	 , ReturnMDCDesc VARCHAR(66) NULL
	 , ReturnDRGWt FLOAT(24) NULL
	 , ReturnDRGALOS FLOAT(24) NULL
	 , ReturnADX VARCHAR(8) NULL
	 , ReturnSDX VARCHAR(8) NULL
	 , ReturnMPR VARCHAR(8) NULL
	 , ReturnPR2 VARCHAR(8) NULL
	 , ReturnPR3 VARCHAR(8) NULL
	 , ReturnNOR VARCHAR(8) NULL
	 , ReturnNO2 VARCHAR(8) NULL
	 , ReturnCOM VARCHAR(255) NULL
	 , ReturnCMI NUMBER(5, 0) NULL
	 , ReturnDCC VARCHAR(8) NULL
	 , ReturnDX1 VARCHAR(8) NULL
	 , ReturnDX2 VARCHAR(8) NULL
	 , ReturnDX3 VARCHAR(8) NULL
	 , ReturnMCI NUMBER(5, 0) NULL
	 , ReturnOR1 VARCHAR(8) NULL
	 , ReturnOR2 VARCHAR(8) NULL
	 , ReturnOR3 VARCHAR(8) NULL
	 , ReturnTRI NUMBER(5, 0) NULL
	 , SOJ VARCHAR(2) NULL
	 , OPCERT VARCHAR(7) NULL
	 , BlendCaseInclMalp FLOAT(24) NULL
	 , CapitalCost FLOAT(24) NULL
	 , HospBadDebt FLOAT(24) NULL
	 , ExcessPhysMalp FLOAT(24) NULL
	 , SparcsPerCase FLOAT(24) NULL
	 , AltLevelOfCare FLOAT(24) NULL
	 , DRGWgt FLOAT(24) NULL
	 , TransferCapital FLOAT(24) NULL
	 , NYDrgType NUMBER(5, 0) NULL
	 , LOS NUMBER(5, 0) NULL
	 , TrimPoint NUMBER(5, 0) NULL
	 , GroupBlendPercentage FLOAT(24) NULL
	 , AdjustmentFactor FLOAT(24) NULL
	 , HospLongStayGroupPrice FLOAT(24) NULL
	 , TotalDRGCharge NUMBER(19, 4) NULL
	 , BlendCaseAdj FLOAT(24) NULL
	 , CapitalCostAdj FLOAT(24) NULL
	 , NonMedicareCaseMix FLOAT(24) NULL
	 , HighCostChargeConverter FLOAT(24) NULL
	 , DischargeCasePaymentRate NUMBER(19, 4) NULL
	 , DirectMedicalEducation NUMBER(19, 4) NULL
	 , CasePaymentCapitalPerDiem NUMBER(19, 4) NULL
	 , HighCostOutlierThreshold NUMBER(19, 4) NULL
	 , ISAF FLOAT(24) NULL
	 , ReturnSOI NUMBER(5, 0) NULL
	 , CapitalCostPerDischarge NUMBER(19, 4) NULL
	 , ReturnSOIDesc VARCHAR(20) NULL
);

CREATE OR REPLACE TABLE stg.BILLS_Endnotes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER(10, 0) NOT NULL
	 , LINE_NO NUMBER(5, 0) NOT NULL
	 , EndNote NUMBER(5, 0) NOT NULL
	 , Referral VARCHAR(200) NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
	 , EndnoteTypeId NUMBER(3, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.Bills_OverrideEndNotes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , OverrideEndNoteID NUMBER(10, 0) NOT NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , Line_No NUMBER(5, 0) NULL
	 , OverrideEndNote NUMBER(5, 0) NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.Bills_Pharm( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER (10,0) NULL
	 , Line_No NUMBER (5,0) NULL
	 , LINE_NO_DISP NUMBER (5,0) NULL
	 , DateOfService DATETIME NULL
	 , NDC VARCHAR (13) NULL
	 , PriceTypeCode VARCHAR (2) NULL
	 , Units FLOAT NULL
	 , Charged NUMBER (19,4) NULL
	 , Allowed NUMBER (19,4) NULL
	 , EndNote VARCHAR (20) NULL
	 , Override NUMBER (5,0) NULL
	 , Override_Rsn VARCHAR (10) NULL
	 , Analyzed NUMBER (19,4) NULL
	 , CTGPenalty NUMBER (19,4) NULL
	 , PrePPOAllowed NUMBER (19,4) NULL
	 , PPODate DATETIME NULL
	 , POS_RevCode VARCHAR (4) NULL
	 , DPAllowed NUMBER (19,4) NULL
	 , HCRA_Surcharge NUMBER (19,4) NULL
	 , EndDateOfService DATETIME NULL
	 , RepackagedNdc VARCHAR (13) NULL
	 , OriginalNdc VARCHAR (13) NULL
	 , UnitOfMeasureId NUMBER (3,0) NULL
	 , PackageTypeOriginalNdc VARCHAR (2) NULL
	 , PpoCtgPenalty NUMBER (19,4) NULL
	 , ServiceCode VARCHAR (25) NULL
	 , PreApportionedAmount NUMBER (19,4) NULL
	 , DeductibleApplied NUMBER (19,4) NULL
	 , BillReviewResults NUMBER (19,4) NULL
	 , PreOverriddenDeductible NUMBER (19,4) NULL
	 , RemainingBalance NUMBER (19,4) NULL
	 , CtgCoPayPenalty NUMBER (19,4) NULL
	 , PpoCtgCoPayPenaltyPercentage NUMBER (19,4) NULL
	 , CtgVunPenalty NUMBER (19,4) NULL
	 , PpoCtgVunPenaltyPercentage NUMBER (19,4) NULL
	 , RenderingNpi VARCHAR (15) NULL
 ); 
CREATE OR REPLACE TABLE stg.Bills_Pharm_CTG_Endnotes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER(10, 0) NOT NULL
	 , LINE_NO NUMBER(5, 0) NOT NULL
	 , EndNote NUMBER(5, 0) NOT NULL
	 , RuleType VARCHAR(2) NULL
	 , RuleId NUMBER(10, 0) NULL
	 , PreCertAction NUMBER(5, 0) NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.Bills_Pharm_Endnotes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER(10, 0) NOT NULL
	 , LINE_NO NUMBER(5, 0) NOT NULL
	 , EndNote NUMBER(5, 0) NOT NULL
	 , Referral VARCHAR(200) NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
	 , EndnoteTypeId NUMBER(3, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.Bills_Pharm_OverrideEndNotes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , OverrideEndNoteID NUMBER(10, 0) NOT NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , Line_No NUMBER(5, 0) NULL
	 , OverrideEndNote NUMBER(5, 0) NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.Bills_Tax (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillsTaxId NUMBER(10, 0) NOT NULL
	 , TableType NUMBER(5, 0) NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , Line_No NUMBER(5, 0) NULL
	 , SeqNo NUMBER(5, 0) NULL
	 , TaxTypeId NUMBER(5, 0) NULL
	 , ImportTaxRate NUMBER(5, 5) NULL
	 , Tax NUMBER(19, 4) NULL
	 , OverridenTax NUMBER(19, 4) NULL
	 , ImportTaxAmount NUMBER(19, 4) NULL
);

CREATE OR REPLACE TABLE stg.BILL_HDR (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER(10, 0) NOT NULL
	 , CMT_HDR_IDNo NUMBER(10, 0) NULL
	 , DateSaved DATETIME NULL
	 , DateRcv DATETIME NULL
	 , InvoiceNumber VARCHAR(40) NULL
	 , InvoiceDate DATETIME NULL
	 , FileNumber VARCHAR(50) NULL
	 , Note VARCHAR(20) NULL
	 , NoLines NUMBER(5, 0) NULL
	 , AmtCharged NUMBER(19, 4) NULL
	 , AmtAllowed NUMBER(19, 4) NULL
	 , ReasonVersion NUMBER(5, 0) NULL
	 , Region VARCHAR(50) NULL
	 , PvdUpdateCounter NUMBER(5, 0) NULL
	 , FeatureID NUMBER(10, 0) NULL
	 , ClaimDateLoss DATETIME NULL
	 , CV_Type VARCHAR(2) NULL
	 , Flags NUMBER(10, 0) NULL
	 , WhoCreate VARCHAR(15) NULL
	 , WhoLast VARCHAR(15) NULL
	 , AcceptAssignment NUMBER(5, 0) NULL
	 , EmergencyService NUMBER(5, 0) NULL
	 , CmtPaidDeductible NUMBER(19, 4) NULL
	 , InsPaidLimit NUMBER(19, 4) NULL
	 , StatusFlag VARCHAR(2) NULL
	 , OfficeId NUMBER(10, 0) NULL
	 , CmtPaidCoPay NUMBER(19, 4) NULL
	 , AmbulanceMethod NUMBER(5, 0) NULL
	 , StatusDate DATETIME NULL
	 , Category NUMBER(10, 0) NULL
	 , CatDesc VARCHAR(1000) NULL
	 , AssignedUser VARCHAR(15) NULL
	 , CreateDate DATETIME NULL
	 , PvdZOS VARCHAR(12) NULL
	 , PPONumberSent NUMBER(5, 0) NULL
	 , AdmissionDate DATETIME NULL
	 , DischargeDate DATETIME NULL
	 , DischargeStatus NUMBER(5, 0) NULL
	 , TypeOfBill VARCHAR(4) NULL
	 , SentryMessage VARCHAR(1000) NULL
	 , AmbulanceZipOfPickup VARCHAR(12) NULL
	 , AmbulanceNumberOfPatients NUMBER(5, 0) NULL
	 , WhoCreateID NUMBER(10, 0) NULL
	 , WhoLastId NUMBER(10, 0) NULL
	 , NYRequestDate DATETIME NULL
	 , NYReceivedDate DATETIME NULL
	 , ImgDocId VARCHAR(50) NULL
	 , PaymentDecision NUMBER(5, 0) NULL
	 , PvdCMSId VARCHAR(6) NULL
	 , PvdNPINo VARCHAR(15) NULL
	 , DischargeHour VARCHAR(2) NULL
	 , PreCertChanged NUMBER(5, 0) NULL
	 , DueDate DATETIME NULL
	 , AttorneyIDNo NUMBER(10, 0) NULL
	 , AssignedGroup NUMBER(10, 0) NULL
	 , LastChangedOn DATETIME NULL
	 , PrePPOAllowed NUMBER(19, 4) NULL
	 , PPSCode NUMBER(5, 0) NULL
	 , SOI NUMBER(5, 0) NULL
	 , StatementStartDate DATETIME NULL
	 , StatementEndDate DATETIME NULL
	 , DeductibleOverride BOOLEAN NULL
	 , AdmissionType NUMBER(3, 0) NULL
	 , CoverageType VARCHAR(2) NULL
	 , PricingProfileId NUMBER(10, 0) NULL
	 , DesignatedPricingState VARCHAR(2) NULL
	 , DateAnalyzed DATETIME NULL
	 , SentToPpoSysId NUMBER(10, 0) NULL
	 , PricingState VARCHAR(2) NULL
	 , BillVpnEligible BOOLEAN NULL
	 , ApportionmentPercentage NUMBER(5, 2) NULL
	 , BillSourceId NUMBER(3, 0) NULL
	 , OutOfStateProviderNumber NUMBER(10, 0) NULL
	 , FloridaDeductibleRuleEligible BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.Bill_History (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , SeqNo NUMBER(10, 0) NOT NULL
	 , DateCommitted DATETIME NULL
	 , AmtCommitted NUMBER(19, 4) NULL
	 , UserId VARCHAR(15) NULL
	 , AmtCoPay NUMBER(19, 4) NULL
	 , AmtDeductible NUMBER(19, 4) NULL
	 , Flags NUMBER(10, 0) NULL
	 , AmtSalesTax NUMBER(19, 4) NULL
	 , AmtOtherTax NUMBER(19, 4) NULL
	 , DeductibleOverride BOOLEAN NULL
	 , PricingState VARCHAR(2) NULL
	 , ApportionmentPercentage NUMBER(5, 2) NULL
	 , FloridaDeductibleRuleEligible BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.Bill_Payment_Adjustments (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Bill_Payment_Adjustment_ID NUMBER(10, 0) NOT NULL
	 , BillIDNo NUMBER(10, 0) NULL
	 , SeqNo NUMBER(5, 0) NULL
	 , InterestFlags NUMBER(10, 0) NULL
	 , DateInterestStarts DATETIME NULL
	 , DateInterestEnds DATETIME NULL
	 , InterestAdditionalInfoReceived DATETIME NULL
	 , Interest NUMBER(19, 4) NULL
	 , Comments VARCHAR(1000) NULL
);

CREATE OR REPLACE TABLE stg.Bill_Pharm_ApportionmentEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillId NUMBER(10, 0) NOT NULL
	 , LineNumber NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.BILL_SENTRY_ENDNOTE (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillID NUMBER(10, 0) NOT NULL
	 , Line NUMBER(10, 0) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.BIReportAdjustmentCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BIReportAdjustmentCategoryId NUMBER(10, 0) NOT NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR(500) NULL
	 , DisplayPriority NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.BIReportAdjustmentCategoryMapping (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BIReportAdjustmentCategoryId NUMBER(10, 0) NOT NULL
	 , Adjustment360SubCategoryId NUMBER(10, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.Bitmasks (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TableProgramUsed VARCHAR(50) NOT NULL
	 , AttributeUsed VARCHAR(50) NOT NULL
	 , Decimal NUMBER(19, 0) NOT NULL
	 , ConstantName VARCHAR(50) NULL
	 , Bit VARCHAR(50) NULL
	 , Hex VARCHAR(20) NULL
	 , Description VARCHAR(250) NULL
);

CREATE OR REPLACE TABLE stg.CbreToDpEndnoteMapping( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Endnote NUMBER (10,0) NULL
	 , EndnoteTypeId NUMBER (3,0) NULL
	 , CbreEndnote NUMBER (5,0) NULL
	 , PricingState VARCHAR (2) NULL
	 , PricingMethodId NUMBER (3,0) NULL
 ); 
CREATE OR REPLACE TABLE stg.CLAIMANT (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CmtIDNo NUMBER(10, 0) NOT NULL
	 , ClaimIDNo NUMBER(10, 0) NULL
	 , CmtSSN VARCHAR(11) NULL
	 , CmtLastName VARCHAR(60) NULL
	 , CmtFirstName VARCHAR(35) NULL
	 , CmtMI VARCHAR(1) NULL
	 , CmtDOB DATETIME NULL
	 , CmtSEX VARCHAR(1) NULL
	 , CmtAddr1 VARCHAR(55) NULL
	 , CmtAddr2 VARCHAR(55) NULL
	 , CmtCity VARCHAR(30) NULL
	 , CmtState VARCHAR(2) NULL
	 , CmtZip VARCHAR(12) NULL
	 , CmtPhone VARCHAR(25) NULL
	 , CmtOccNo VARCHAR(11) NULL
	 , CmtAttorneyNo NUMBER(10, 0) NULL
	 , CmtPolicyLimit NUMBER(19, 4) NULL
	 , CmtStateOfJurisdiction VARCHAR(2) NULL
	 , CmtDeductible NUMBER(19, 4) NULL
	 , CmtCoPaymentPercentage NUMBER(5, 0) NULL
	 , CmtCoPaymentMax NUMBER(19, 4) NULL
	 , CmtPPO_Eligible NUMBER(5, 0) NULL
	 , CmtCoordBenefits NUMBER(5, 0) NULL
	 , CmtFLCopay NUMBER(5, 0) NULL
	 , CmtCOAExport DATETIME NULL
	 , CmtPGFirstName VARCHAR(30) NULL
	 , CmtPGLastName VARCHAR(30) NULL
	 , CmtDedType NUMBER(5, 0) NULL
	 , ExportToClaimIQ NUMBER(5, 0) NULL
	 , CmtInactive NUMBER(5, 0) NULL
	 , CmtPreCertOption NUMBER(5, 0) NULL
	 , CmtPreCertState VARCHAR(2) NULL
	 , CreateDate DATETIME NULL
	 , LastChangedOn DATETIME NULL
	 , OdsParticipant BOOLEAN NULL
	 , CoverageType VARCHAR(2) NULL
	 , DoNotDisplayCoverageTypeOnEOB BOOLEAN NULL
	 , ShowAllocationsOnEob BOOLEAN NULL
	 , SetPreAllocation BOOLEAN NULL
	 , PharmacyEligible NUMBER(3, 0) NULL
	 , SendCardToClaimant NUMBER(3, 0) NULL
	 , ShareCoPayMaximum BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.ClaimantManualProviderSummary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ManualProviderId NUMBER(10, 0) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NOT NULL
	 , FirstDateOfService DATETIME NULL
	 , LastDateOfService DATETIME NULL
	 , Visits NUMBER(10, 0) NULL
	 , ChargedAmount NUMBER(19, 4) NULL
	 , EvaluatedAmount NUMBER(19, 4) NULL
	 , MinimumEvaluatedAmount NUMBER(19, 4) NULL
	 , MaximumEvaluatedAmount NUMBER(19, 4) NULL
	 , Comments VARCHAR(255) NULL
);

CREATE OR REPLACE TABLE stg.ClaimantProviderSummaryEvaluation (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ClaimantProviderSummaryEvaluationId NUMBER(10, 0) NOT NULL
	 , ClaimantHeaderId NUMBER(10, 0) NULL
	 , EvaluatedAmount NUMBER(19, 4) NULL
	 , MinimumEvaluatedAmount NUMBER(19, 4) NULL
	 , MaximumEvaluatedAmount NUMBER(19, 4) NULL
	 , Comments VARCHAR(255) NULL
);

CREATE OR REPLACE TABLE stg.Claimant_ClientRef (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CmtIdNo NUMBER(10, 0) NOT NULL
	 , CmtSuffix VARCHAR(50) NULL
	 , ClaimIdNo NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.CLAIMS (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ClaimIDNo NUMBER(10, 0) NOT NULL
	 , ClaimNo VARCHAR NULL
	 , DateLoss DATETIME NULL
	 , CV_Code VARCHAR(2) NULL
	 , DiaryIndex NUMBER(10, 0) NULL
	 , LastSaved DATETIME NULL
	 , PolicyNumber VARCHAR(50) NULL
	 , PolicyHoldersName VARCHAR(30) NULL
	 , PaidDeductible NUMBER(19, 4) NULL
	 , Status VARCHAR(1) NULL
	 , InUse VARCHAR(100) NULL
	 , CompanyID NUMBER(10, 0) NULL
	 , OfficeIndex NUMBER(10, 0) NULL
	 , AdjIdNo NUMBER(10, 0) NULL
	 , PaidCoPay NUMBER(19, 4) NULL
	 , AssignedUser VARCHAR(15) NULL
	 , Privatized NUMBER(5, 0) NULL
	 , PolicyEffDate DATETIME NULL
	 , Deductible NUMBER(19, 4) NULL
	 , LossState VARCHAR(2) NULL
	 , AssignedGroup NUMBER(10, 0) NULL
	 , CreateDate DATETIME NULL
	 , LastChangedOn DATETIME NULL
	 , AllowMultiCoverage BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.Claims_ClientRef (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ClaimIdNo NUMBER(10, 0) NOT NULL
	 , ClientRefId VARCHAR(50) NULL
);

CREATE OR REPLACE TABLE stg.CMS_Zip2Region (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , ZIP_Code VARCHAR(5) NOT NULL
	 , State VARCHAR(2) NULL
	 , Region VARCHAR(2) NULL
	 , AmbRegion VARCHAR(2) NULL
	 , RuralFlag NUMBER(5, 0) NULL
	 , ASCRegion NUMBER(5, 0) NULL
	 , PlusFour NUMBER(5, 0) NULL
	 , CarrierId NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.CMT_DX (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER(10, 0) NOT NULL
	 , DX VARCHAR(8) NOT NULL
	 , SeqNum NUMBER(5, 0) NULL
	 , POA VARCHAR(1) NULL
	 , IcdVersion NUMBER(3, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.CMT_HDR (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CMT_HDR_IDNo NUMBER(10, 0) NOT NULL
	 , CmtIDNo NUMBER(10, 0) NULL
	 , PvdIDNo NUMBER(10, 0) NULL
	 , LastChangedOn DATETIME NULL
);

CREATE OR REPLACE TABLE stg.CMT_ICD9 (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER(10, 0) NOT NULL
	 , SeqNo NUMBER(5, 0) NOT NULL
	 , ICD9 VARCHAR(7) NULL
	 , IcdVersion NUMBER(3, 0) NULL
);

CREATE OR REPLACE TABLE stg.CoverageType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , LongName VARCHAR(30) NULL
	 , ShortName VARCHAR(2) NOT NULL
	 , CbreCoverageTypeCode VARCHAR(2) NULL
	 , CoverageTypeCategoryCode VARCHAR(4) NULL
	 , PricingMethodId NUMBER(3, 0) NULL
);

CREATE OR REPLACE TABLE stg.cpt_DX_DICT (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ICD9 VARCHAR(6) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , Flags NUMBER(5, 0) NULL
	 , NonSpecific VARCHAR(1) NULL
	 , AdditionalDigits VARCHAR(1) NULL
	 , Traumatic VARCHAR(1) NULL
	 , DX_DESC VARCHAR NULL
	 , Duration NUMBER(5, 0) NULL
	 , Colossus NUMBER(5, 0) NULL
	 , DiagnosisFamilyId NUMBER(3, 0) NULL
);

CREATE OR REPLACE TABLE stg.cpt_PRC_DICT (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PRC_CD VARCHAR(7) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , PRC_DESC VARCHAR NULL
	 , Flags NUMBER(10, 0) NULL
	 , Vague VARCHAR(1) NULL
	 , PerVisit NUMBER(5, 0) NULL
	 , PerClaimant NUMBER(5, 0) NULL
	 , PerProvider NUMBER(5, 0) NULL
	 , BodyFlags NUMBER(10, 0) NULL
	 , Colossus NUMBER(5, 0) NULL
	 , CMS_Status VARCHAR(1) NULL
	 , DrugFlag NUMBER(5, 0) NULL
	 , CurativeFlag NUMBER(5, 0) NULL
	 , ExclPolicyLimit NUMBER(5, 0) NULL
	 , SpecNetFlag NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.CreditReason (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CreditReasonId NUMBER(10, 0) NOT NULL
	 , CreditReasonDesc VARCHAR(100) NULL
	 , IsVisible BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.CreditReasonOverrideENMap (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CreditReasonOverrideENMapId NUMBER(10, 0) NOT NULL
	 , CreditReasonId NUMBER(10, 0) NULL
	 , OverrideEndnoteId NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.CriticalAccessHospitalInpatientRevenueCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RevenueCode VARCHAR(4) NOT NULL
);

CREATE OR REPLACE TABLE stg.CTG_Endnotes( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Endnote NUMBER (10,0) NULL
	 , ShortDesc VARCHAR (50) NULL
	 , LongDesc VARCHAR (500) NULL
 ); 
CREATE OR REPLACE TABLE stg.CustomBillStatuses (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StatusId NUMBER(10, 0) NOT NULL
	 , StatusName VARCHAR(50) NULL
	 , StatusDescription VARCHAR(300) NULL
);

CREATE OR REPLACE TABLE stg.CustomEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CustomEndnote NUMBER(10, 0) NOT NULL
	 , ShortDescription VARCHAR(50) NULL
	 , LongDescription VARCHAR(500) NULL
);

CREATE OR REPLACE TABLE stg.CustomerBillExclusion (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , Customer VARCHAR(50) NOT NULL
	 , ReportID NUMBER(3, 0) NOT NULL
	 , CreateDate DATETIME NULL
);

CREATE OR REPLACE TABLE stg.DeductibleRuleCriteria (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DeductibleRuleCriteriaId NUMBER(10, 0) NOT NULL
	 , PricingRuleDateCriteriaId NUMBER(3, 0) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
);

CREATE OR REPLACE TABLE stg.DeductibleRuleCriteriaCoverageType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DeductibleRuleCriteriaId NUMBER(10, 0) NOT NULL
	 , CoverageType VARCHAR(5) NOT NULL
);

CREATE OR REPLACE TABLE stg.DeductibleRuleExemptEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
	 , EndnoteTypeId NUMBER(3, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.DemandClaimant (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NOT NULL
	 , ExternalClaimantId NUMBER(10, 0) NULL
	 , OrganizationId VARCHAR(100) NULL
	 , HeightInInches NUMBER(5, 0) NULL
	 , Weight NUMBER(5, 0) NULL
	 , Occupation VARCHAR(50) NULL
	 , BiReportStatus NUMBER(5, 0) NULL
	 , HasDemandPackage NUMBER(10, 0) NULL
	 , FactsOfLoss VARCHAR(250) NULL
	 , PreExistingConditions VARCHAR(100) NULL
	 , Archived BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.DemandPackage (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DemandPackageId NUMBER(10, 0) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NULL
	 , RequestedByUserName VARCHAR(15) NULL
	 , DateTimeReceived TIMESTAMP_LTZ(7) NULL
	 , CorrelationId VARCHAR(36) NULL
	 , PageCount NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.DemandPackageRequestedService (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DemandPackageRequestedServiceId NUMBER(10, 0) NOT NULL
	 , DemandPackageId NUMBER(10, 0) NULL
	 , ReviewRequestOptions VARCHAR NULL
);

CREATE OR REPLACE TABLE stg.DemandPackageUploadedFile (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DemandPackageUploadedFileId NUMBER(10, 0) NOT NULL
	 , DemandPackageId NUMBER(10, 0) NULL
	 , FileName VARCHAR(255) NULL
	 , Size NUMBER(10, 0) NULL
	 , DocStoreId VARCHAR(50) NULL
);

CREATE OR REPLACE TABLE stg.DiagnosisCodeGroup (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DiagnosisCode VARCHAR(8) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , MajorCategory VARCHAR(500) NULL
	 , MinorCategory VARCHAR(500) NULL
);

CREATE OR REPLACE TABLE stg.EncounterType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EncounterTypeId NUMBER(3, 0) NOT NULL
	 , EncounterTypePriority NUMBER(3, 0) NULL
	 , Description VARCHAR(100) NULL
	 , NarrativeInformation VARCHAR NULL
);

CREATE OR REPLACE TABLE stg.EndnoteSubCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EndnoteSubCategoryId NUMBER(3, 0) NOT NULL
	 , Description VARCHAR(50) NULL
);

CREATE OR REPLACE TABLE stg.Esp_Ppo_Billing_Data_Self_Bill (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , COMPANYCODE VARCHAR(10) NULL
	 , TRANSACTIONTYPE VARCHAR(10) NULL
	 , BILL_HDR_AMTALLOWED NUMBER(15, 2) NULL
	 , BILL_HDR_AMTCHARGED NUMBER(15, 2) NULL
	 , BILL_HDR_BILLIDNO NUMBER(10, 0) NULL
	 , BILL_HDR_CMT_HDR_IDNO NUMBER(10, 0) NULL
	 , BILL_HDR_CREATEDATE DATETIME NULL
	 , BILL_HDR_CV_TYPE VARCHAR(5) NULL
	 , BILL_HDR_FORM_TYPE VARCHAR(8) NULL
	 , BILL_HDR_NOLINES NUMBER(10, 0) NULL
	 , BILLS_ALLOWED NUMBER(15, 2) NULL
	 , BILLS_ANALYZED NUMBER(15, 2) NULL
	 , BILLS_CHARGED NUMBER(15, 2) NULL
	 , BILLS_DT_SVC DATETIME NULL
	 , BILLS_LINE_NO NUMBER(10, 0) NULL
	 , CLAIMANT_CLIENTREF_CMTSUFFIX VARCHAR(50) NULL
	 , CLAIMANT_CMTFIRST_NAME VARCHAR(50) NULL
	 , CLAIMANT_CMTIDNO VARCHAR(20) NULL
	 , CLAIMANT_CMTLASTNAME VARCHAR(60) NULL
	 , CMTSTATEOFJURISDICTION VARCHAR(2) NULL
	 , CLAIMS_COMPANYID NUMBER(10, 0) NULL
	 , CLAIMS_CLAIMNO VARCHAR(50) NULL
	 , CLAIMS_DATELOSS DATETIME NULL
	 , CLAIMS_OFFICEINDEX NUMBER(10, 0) NULL
	 , CLAIMS_POLICYHOLDERSNAME VARCHAR(100) NULL
	 , CLAIMS_POLICYNUMBER VARCHAR(50) NULL
	 , PNETWKEVENTLOG_EVENTID NUMBER(10, 0) NULL
	 , PNETWKEVENTLOG_LOGDATE DATETIME NULL
	 , PNETWKEVENTLOG_NETWORKID NUMBER(10, 0) NULL
	 , ACTIVITY_FLAG VARCHAR(1) NULL
	 , PPO_AMTALLOWED NUMBER(15, 2) NULL
	 , PREPPO_AMTALLOWED NUMBER(15, 2) NULL
	 , PREPPO_ALLOWED_FS VARCHAR(1) NULL
	 , PRF_COMPANY_COMPANYNAME VARCHAR(50) NULL
	 , PRF_OFFICE_OFCNAME VARCHAR(50) NULL
	 , PRF_OFFICE_OFCNO VARCHAR(25) NULL
	 , PROVIDER_PVDFIRSTNAME VARCHAR(60) NULL
	 , PROVIDER_PVDGROUP VARCHAR(60) NULL
	 , PROVIDER_PVDLASTNAME VARCHAR(60) NULL
	 , PROVIDER_PVDTIN VARCHAR(15) NULL
	 , PROVIDER_STATE VARCHAR(5) NULL
	 , UDFCLAIM_UDFVALUETEXT VARCHAR(255) NULL
	 , ENTRY_DATE DATETIME NULL
	 , UDFCLAIMANT_UDFVALUETEXT VARCHAR(255) NULL
	 , SOURCE_DB VARCHAR(20) NULL
	 , CLAIMS_CV_CODE VARCHAR(5) NULL
	 , VPN_TRANSACTIONID NUMBER(19, 0) NOT NULL
	 , VPN_TRANSACTIONTYPEID NUMBER(10, 0) NULL
	 , VPN_BILLIDNO NUMBER(10, 0) NULL
	 , VPN_LINE_NO NUMBER(5, 0) NULL
	 , VPN_CHARGED NUMBER(19, 4) NULL
	 , VPN_DPALLOWED NUMBER(19, 4) NULL
	 , VPN_VPNALLOWED NUMBER(19, 4) NULL
	 , VPN_SAVINGS NUMBER(19, 4) NULL
	 , VPN_CREDITS NUMBER(19, 4) NULL
	 , VPN_HASOVERRIDE BOOLEAN NULL
	 , VPN_ENDNOTES VARCHAR(200) NULL
	 , VPN_NETWORKIDNO NUMBER(10, 0) NULL
	 , VPN_PROCESSFLAG NUMBER(5, 0) NULL
	 , VPN_LINETYPE NUMBER(10, 0) NULL
	 , VPN_DATETIMESTAMP DATETIME NULL
	 , VPN_SEQNO NUMBER(10, 0) NULL
	 , VPN_VPN_REF_LINE_NO NUMBER(5, 0) NULL
	 , VPN_NETWORKNAME VARCHAR(50) NULL
	 , VPN_SOJ VARCHAR(2) NULL
	 , VPN_CAT3 NUMBER(10, 0) NULL
	 , VPN_PPODATESTAMP DATETIME NULL
	 , VPN_NINTEYDAYS NUMBER(10, 0) NULL
	 , VPN_BILL_TYPE VARCHAR(1) NULL
	 , VPN_NET_SAVINGS NUMBER(19, 4) NULL
	 , CREDIT BOOLEAN NULL
	 , RECON BOOLEAN NULL
	 , DELETED BOOLEAN NULL
	 , STATUS_FLAG VARCHAR(2) NULL
	 , DATE_SAVED DATETIME NULL
	 , SUB_NETWORK VARCHAR(50) NULL
	 , INVALID_CREDIT BOOLEAN NULL
	 , PROVIDER_SPECIALTY VARCHAR(50) NULL
	 , ADJUSTOR_IDNUMBER VARCHAR(25) NULL
	 , ACP_FLAG VARCHAR(1) NULL
	 , OVERRIDE_ENDNOTES VARCHAR NULL
	 , OVERRIDE_ENDNOTES_DESC VARCHAR NULL
);


CREATE OR REPLACE TABLE stg.ETL_ControlFiles
(
	Control_File_Name VARCHAR(255) NOT NULL,		
	Product  VARCHAR(25)NOT NULL,				
	Load_Type VARCHAR(25)NOT NULL,				
	Ods_Cutoff_Posting_Group_Audit_Id INT NOT NULL,	
	Snapshot_Date Datetime NOT NULL,				
	Target_Table_Name VARCHAR(100) NOT NULL,		
	Total_Files  INT NULL,						
	File_Number INT NULL,							
	File_Name VARCHAR(255)NOT NULL,				
	Total_Row_Count INT NULL,						
	Total_Records_In_Source INT NULL,				
	Current_Replication_ID  INT NULL,				
	Previous_Replication_ID  INT NULL,				
	Ods_Version VARCHAR(20) NOT NULL,
	File_Size NUMBER(10,3) NULL
);

COMMENT ON COLUMN stg.ETL_ControlFiles.Control_File_Name IS 'Control File Name.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Product  IS'Data Source Name. Sample Values: ACS, WCS etc.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Load_Type IS'The type of load. 0 is for full load, 1 is for incremental load.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Ods_Cutoff_Posting_Group_Audit_Id IS'Last ods posting group coming from ods.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Snapshot_Date    IS'Snapshot Date of load (Create date of control file).';
COMMENT ON COLUMN stg.ETL_ControlFiles.Target_Table_Name IS'Target Table Name (without schema).';
COMMENT ON COLUMN stg.ETL_ControlFiles.Total_Files IS'Total number of files for the target table.';
COMMENT ON COLUMN stg.ETL_ControlFiles.File_Number IS'The sequence of the file.';
COMMENT ON COLUMN stg.ETL_ControlFiles.File_Name   IS'The file name.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Total_Row_Count IS'Total number of rows in the file.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Total_Records_In_Source IS'Total number of rows extracted from the source on ODS side.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Current_Replication_ID IS'Identity value generated per extraction on ODS side to detect gaps between consecutive posting groups.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Previous_Replication_ID IS'Identity value of the previous extraction on ODS side.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Ods_Version   IS'Current Ods Version';
COMMENT ON COLUMN stg.ETL_ControlFiles.File_Size   IS'The file size in MB';

CREATE OR REPLACE TABLE stg.EvaluationSummary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NOT NULL
	 , Details VARCHAR NULL
	 , CreatedBy VARCHAR(50) NULL
	 , CreatedDate TIMESTAMP_LTZ(7) NULL
	 , ModifiedBy VARCHAR(50) NULL
	 , ModifiedDate TIMESTAMP_LTZ(7) NULL
	 , EvaluationSummaryTemplateVersionId NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.EvaluationSummaryHistory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EvaluationSummaryHistoryId NUMBER(10, 0) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NULL
	 , EvaluationSummary VARCHAR NULL
	 , CreatedBy VARCHAR(50) NULL
	 , CreatedDate TIMESTAMP_LTZ(7) NULL
);

CREATE OR REPLACE TABLE stg.EvaluationSummaryTemplateVersion (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EvaluationSummaryTemplateVersionId NUMBER(10, 0) NOT NULL
	 , Template VARCHAR NULL
	 , TemplateHash BINARY(32) NULL
	 , CreatedDate TIMESTAMP_LTZ(7) NULL
);

CREATE OR REPLACE TABLE stg.EventLog (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EventLogId NUMBER(10, 0) NOT NULL
	 , ObjectName VARCHAR(50) NULL
	 , ObjectId NUMBER(10, 0) NULL
	 , UserName VARCHAR(15) NULL
	 , LogDate TIMESTAMP_LTZ(7) NULL
	 , ActionName VARCHAR(20) NULL
	 , OrganizationId VARCHAR(100) NULL
);

CREATE OR REPLACE TABLE stg.EventLogDetail (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EventLogDetailId NUMBER(10, 0) NOT NULL
	 , EventLogId NUMBER(10, 0) NULL
	 , PropertyName VARCHAR(50) NULL
	 , OldValue VARCHAR NULL
	 , NewValue VARCHAR NULL
);

CREATE OR REPLACE TABLE stg.ExtractCat (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CatIdNo NUMBER(10, 0) NOT NULL
	 , Description VARCHAR(50) NULL
);

CREATE OR REPLACE TABLE stg.GeneralInterestRuleBaseType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , GeneralInterestRuleBaseTypeId NUMBER(3, 0) NOT NULL
	 , GeneralInterestRuleBaseTypeName VARCHAR(50) NULL
);

CREATE OR REPLACE TABLE stg.GeneralInterestRuleSetting (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , GeneralInterestRuleBaseTypeId NUMBER(3, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.Icd10DiagnosisVersion (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DiagnosisCode VARCHAR(8) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , NonSpecific BOOLEAN NULL
	 , Traumatic BOOLEAN NULL
	 , Duration NUMBER(5, 0) NULL
	 , Description VARCHAR NULL
	 , DiagnosisFamilyId NUMBER(3, 0) NULL
	 , TotalCharactersRequired NUMBER(3, 0) NULL
	 , PlaceholderRequired BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.ICD10ProcedureCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ICDProcedureCode VARCHAR(7) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , Description VARCHAR(300) NULL
	 , PASGrpNo NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.IcdDiagnosisCodeDictionary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DiagnosisCode VARCHAR(8) NOT NULL
	 , IcdVersion NUMBER(3, 0) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , NonSpecific BOOLEAN NULL
	 , Traumatic BOOLEAN NULL
	 , Duration NUMBER(3, 0) NULL
	 , Description VARCHAR NULL
	 , DiagnosisFamilyId NUMBER(3, 0) NULL
	 , DiagnosisSeverityId NUMBER(3, 0) NULL
	 , LateralityId NUMBER(3, 0) NULL
	 , TotalCharactersRequired NUMBER(3, 0) NULL
	 , PlaceholderRequired BOOLEAN NULL
	 , Flags NUMBER(5, 0) NULL
	 , AdditionalDigits BOOLEAN NULL
	 , Colossus NUMBER(5, 0) NULL
	 , InjuryNatureId NUMBER(3, 0) NULL
	 , EncounterSubcategoryId NUMBER(3, 0) NULL
);

CREATE OR REPLACE TABLE stg.IcdDiagnosisCodeDictionaryBodyPart (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DiagnosisCode VARCHAR(8) NOT NULL
	 , IcdVersion NUMBER(3, 0) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , NcciBodyPartId NUMBER(3, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.InjuryNature (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , InjuryNatureId NUMBER(3, 0) NOT NULL
	 , InjuryNaturePriority NUMBER(3, 0) NULL
	 , Description VARCHAR(100) NULL
	 , NarrativeInformation VARCHAR NULL
);

CREATE OR REPLACE TABLE stg.lkp_SPC (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , lkp_SpcId NUMBER(10, 0) NOT NULL
	 , LongName VARCHAR(50) NULL
	 , ShortName VARCHAR(4) NULL
	 , Mult NUMBER(19, 4) NULL
	 , NCD92 NUMBER(5, 0) NULL
	 , NCD93 NUMBER(5, 0) NULL
	 , PlusFour NUMBER(5, 0) NULL
	 , CbreSpecialtyCode VARCHAR(12) NULL
);

CREATE OR REPLACE TABLE stg.lkp_TS (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ShortName VARCHAR(2) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , LongName VARCHAR(100) NULL
	 , Global NUMBER(5, 0) NULL
	 , AnesMedDirect NUMBER(5, 0) NULL
	 , AffectsPricing NUMBER(5, 0) NULL
	 , IsAssistantSurgery BOOLEAN NULL
	 , IsCoSurgeon BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.ManualProvider (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ManualProviderId NUMBER(10, 0) NOT NULL
	 , TIN VARCHAR(15) NULL
	 , LastName VARCHAR(60) NULL
	 , FirstName VARCHAR(35) NULL
	 , GroupName VARCHAR(60) NULL
	 , Address1 VARCHAR(55) NULL
	 , Address2 VARCHAR(55) NULL
	 , City VARCHAR(30) NULL
	 , State VARCHAR(2) NULL
	 , Zip VARCHAR(12) NULL
);

CREATE OR REPLACE TABLE stg.ManualProviderSpecialty (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ManualProviderId NUMBER(10, 0) NOT NULL
	 , Specialty VARCHAR(12) NOT NULL
);

CREATE OR REPLACE TABLE stg.MedicalCodeCutOffs (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CodeTypeID NUMBER(10, 0) NOT NULL
	 , CodeType VARCHAR(50) NULL
	 , Code VARCHAR(50) NOT NULL
	 , FormType VARCHAR(10) NOT NULL
	 , MaxChargedPerUnit FLOAT(53) NULL
	 , MaxUnitsPerEncounter FLOAT(53) NULL
);

CREATE OR REPLACE TABLE stg.MedicareStatusIndicatorRule (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , MedicareStatusIndicatorRuleId NUMBER(10, 0) NOT NULL
	 , MedicareStatusIndicatorRuleName VARCHAR(50) NULL
	 , StatusIndicator VARCHAR(500) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
	 , Endnote NUMBER(10, 0) NULL
	 , EditActionId NUMBER(3, 0) NULL
	 , Comments VARCHAR(1000) NULL
);

CREATE OR REPLACE TABLE stg.MedicareStatusIndicatorRuleCoverageType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , MedicareStatusIndicatorRuleId NUMBER(10, 0) NOT NULL
	 , ShortName VARCHAR(2) NOT NULL
);

CREATE OR REPLACE TABLE stg.MedicareStatusIndicatorRulePlaceOfService (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , MedicareStatusIndicatorRuleId NUMBER(10, 0) NOT NULL
	 , PlaceOfService VARCHAR(4) NOT NULL
);

CREATE OR REPLACE TABLE stg.MedicareStatusIndicatorRuleProcedureCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , MedicareStatusIndicatorRuleId NUMBER(10, 0) NOT NULL
	 , ProcedureCode VARCHAR(7) NOT NULL
);

CREATE OR REPLACE TABLE stg.MedicareStatusIndicatorRuleProviderSpecialty (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , MedicareStatusIndicatorRuleId NUMBER(10, 0) NOT NULL
	 , ProviderSpecialty VARCHAR(6) NOT NULL
);

CREATE OR REPLACE TABLE stg.ModifierByState (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , State VARCHAR(2) NOT NULL
	 , ProcedureServiceCategoryId NUMBER(3, 0) NOT NULL
	 , ModifierDictionaryId NUMBER(10, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.ModifierDictionary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ModifierDictionaryId NUMBER(10, 0) NOT NULL
	 , Modifier VARCHAR(2) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
	 , Description VARCHAR(100) NULL
	 , Global BOOLEAN NULL
	 , AnesMedDirect BOOLEAN NULL
	 , AffectsPricing BOOLEAN NULL
	 , IsCoSurgeon BOOLEAN NULL
	 , IsAssistantSurgery BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.ModifierToProcedureCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProcedureCode VARCHAR(5) NOT NULL
	 , Modifier VARCHAR(2) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , SojFlag NUMBER(5, 0) NULL
	 , RequiresGuidelineReview BOOLEAN NULL
	 , Reference VARCHAR(255) NULL
	 , Comments VARCHAR(255) NULL
);

CREATE OR REPLACE TABLE stg.NcciBodyPart (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , NcciBodyPartId NUMBER(3, 0) NOT NULL
	 , Description VARCHAR(100) NULL
	 , NarrativeInformation VARCHAR NULL
);

CREATE OR REPLACE TABLE stg.NcciBodyPartToHybridBodyPartTranslation (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , NcciBodyPartId NUMBER(3, 0) NOT NULL
	 , HybridBodyPartId NUMBER(5, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.Note (
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

CREATE OR REPLACE TABLE stg.ny_Pharmacy (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , NDCCode VARCHAR(13) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , Description VARCHAR(125) NULL
	 , Fee NUMBER(19, 4) NOT NULL
	 , TypeOfDrug NUMBER(5, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.ny_specialty (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RatingCode VARCHAR(12) NOT NULL
	 , Desc_ VARCHAR(70) NULL
	 , CbreSpecialtyCode VARCHAR(12) NULL
);

CREATE OR REPLACE TABLE stg.pa_PlaceOfService (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , POS NUMBER(5, 0) NOT NULL
	 , Description VARCHAR(255) NULL
	 , Facility NUMBER(5, 0) NULL
	 , MHL NUMBER(5, 0) NULL
	 , PlusFour NUMBER(5, 0) NULL
	 , Institution NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.PlaceOfServiceDictionary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PlaceOfServiceCode NUMBER(5, 0) NOT NULL
	 , Description VARCHAR(255) NULL
	 , Facility NUMBER(5, 0) NULL
	 , MHL NUMBER(5, 0) NULL
	 , PlusFour NUMBER(5, 0) NULL
	 , Institution NUMBER(10, 0) NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
);

CREATE OR REPLACE TABLE stg.PostingGroupAudit (
	  PostingGroupAuditId NUMBER(10, 0) NOT NULL
	, OltpPostingGroupAuditId NUMBER(10, 0) NOT NULL
	, PostingGroupId NUMBER(3, 0) NOT NULL
	, CustomerId NUMBER(10, 0) NOT NULL
	, Status VARCHAR(2) NOT NULL
	, DataExtractTypeId NUMBER(10, 0) NOT NULL
	, OdsVersion VARCHAR(10) NULL
	, SnapshotCreateDate DATETIME NULL
	, SnapshotDropDate DATETIME NULL
	, CreateDate DATETIME NOT NULL
	, LastChangeDate DATETIME NOT NULL
);

CREATE OR REPLACE TABLE stg.PrePPOBillInfo( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DateSentToPPO DATETIME NULL
	 , ClaimNo VARCHAR (50) NULL
	 , ClaimIDNo NUMBER (10,0) NULL
	 , CompanyID NUMBER (10,0) NULL
	 , OfficeIndex NUMBER (10,0) NULL
	 , CV_Code VARCHAR (2) NULL
	 , DateLoss DATETIME NULL
	 , Deductible NUMBER (19,4) NULL
	 , PaidCoPay NUMBER (19,4) NULL
	 , PaidDeductible NUMBER (19,4) NULL
	 , LossState VARCHAR (2) NULL
	 , CmtIDNo NUMBER (10,0) NULL
	 , CmtCoPaymentMax NUMBER (19,4) NULL
	 , CmtCoPaymentPercentage NUMBER (5,0) NULL
	 , CmtDedType NUMBER (5,0) NULL
	 , CmtDeductible NUMBER (19,4) NULL
	 , CmtFLCopay NUMBER (5,0) NULL
	 , CmtPolicyLimit NUMBER (19,4) NULL
	 , CmtStateOfJurisdiction VARCHAR (2) NULL
	 , PvdIDNo NUMBER (10,0) NULL
	 , PvdTIN VARCHAR (15) NULL
	 , PvdSPC_List VARCHAR (50) NULL
	 , PvdTitle VARCHAR (5) NULL
	 , PvdFlags NUMBER (10,0) NULL
	 , DateSaved DATETIME NULL
	 , DateRcv DATETIME NULL
	 , InvoiceDate DATETIME NULL
	 , NoLines NUMBER (5,0) NULL
	 , AmtCharged NUMBER (19,4) NULL
	 , AmtAllowed NUMBER (19,4) NULL
	 , Region VARCHAR (50) NULL
	 , FeatureID NUMBER (10,0) NULL
	 , Flags NUMBER (10,0) NULL
	 , WhoCreate VARCHAR (15) NULL
	 , WhoLast VARCHAR (15) NULL
	 , CmtPaidDeductible NUMBER (19,4) NULL
	 , InsPaidLimit NUMBER (19,4) NULL
	 , StatusFlag VARCHAR (2) NULL
	 , CmtPaidCoPay NUMBER (19,4) NULL
	 , Category NUMBER (10,0) NULL
	 , CatDesc VARCHAR (1000) NULL
	 , CreateDate DATETIME NULL
	 , PvdZOS VARCHAR (12) NULL
	 , AdmissionDate DATETIME NULL
	 , DischargeDate DATETIME NULL
	 , DischargeStatus NUMBER (5,0) NULL
	 , TypeOfBill VARCHAR (4) NULL
	 , PaymentDecision NUMBER (5,0) NULL
	 , PPONumberSent NUMBER (5,0) NULL
	 , BillIDNo NUMBER (10,0) NULL
	 , LINE_NO NUMBER (5,0) NULL
	 , LINE_NO_DISP NUMBER (5,0) NULL
	 , OVER_RIDE NUMBER (5,0) NULL
	 , DT_SVC DATETIME NULL
	 , PRC_CD VARCHAR (7) NULL
	 , UNITS FLOAT NULL
	 , TS_CD VARCHAR (14) NULL
	 , CHARGED NUMBER (19,4) NULL
	 , ALLOWED NUMBER (19,4) NULL
	 , ANALYZED NUMBER (19,4) NULL
	 , REF_LINE_NO NUMBER (5,0) NULL
	 , SUBNET VARCHAR (9) NULL
	 , FEE_SCHEDULE NUMBER (19,4) NULL
	 , POS_RevCode VARCHAR (4) NULL
	 , CTGPenalty NUMBER (19,4) NULL
	 , PrePPOAllowed NUMBER (19,4) NULL
	 , PPODate DATETIME NULL
	 , PPOCTGPenalty NUMBER (19,4) NULL
	 , UCRPerUnit NUMBER (19,4) NULL
	 , FSPerUnit NUMBER (19,4) NULL
	 , HCRA_Surcharge NUMBER (19,4) NULL
	 , NDC VARCHAR (13) NULL
	 , PriceTypeCode VARCHAR (2) NULL
	 , PharmacyLine NUMBER (5,0) NULL
	 , Endnotes VARCHAR (50) NULL
	 , SentryEN VARCHAR (250) NULL
	 , CTGEN VARCHAR (250) NULL
	 , CTGRuleType VARCHAR (250) NULL
	 , CTGRuleID VARCHAR (250) NULL
	 , OverrideEN VARCHAR (50) NULL
	 , UserId NUMBER (10,0) NULL
	 , DateOverriden DATETIME NULL
	 , AmountBeforeOverride NUMBER (19,4) NULL
	 , AmountAfterOverride NUMBER (19,4) NULL
	 , CodesOverriden VARCHAR (50) NULL
	 , NetworkID NUMBER (10,0) NULL
	 , BillSnapshot VARCHAR (30) NULL
	 , PPOSavings NUMBER (19,4) NULL
	 , RevisedDate DATETIME NULL
	 , ReconsideredDate DATETIME NULL
	 , TierNumber NUMBER (5,0) NULL
	 , PPOBillInfoID NUMBER (10,0) NULL
	 , PrePPOBillInfoID NUMBER (10,0) NULL
	 , CtgCoPayPenalty NUMBER (19,4) NULL
	 , PpoCtgCoPayPenaltyPercentage NUMBER (19,4) NULL
	 , CtgVunPenalty NUMBER (19,4) NULL
	 , PpoCtgVunPenaltyPercentage NUMBER (19,4) NULL
 ); 
CREATE OR REPLACE TABLE stg.prf_COMPANY (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CompanyId NUMBER(10, 0) NOT NULL
	 , CompanyName VARCHAR(50) NULL
	 , LastChangedOn DATETIME NULL
);

CREATE OR REPLACE TABLE stg.prf_CTGMaxPenaltyLines (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CTGMaxPenLineID NUMBER(10, 0) NOT NULL
	 , ProfileId NUMBER(10, 0) NULL
	 , DatesBasedOn NUMBER(5, 0) NULL
	 , MaxPenaltyPercent NUMBER(5, 0) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
);

CREATE OR REPLACE TABLE stg.prf_CTGPenalty (
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

CREATE OR REPLACE TABLE stg.prf_CTGPenaltyLines (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CTGPenLineID NUMBER(10, 0) NOT NULL
	 , ProfileId NUMBER(10, 0) NULL
	 , PenaltyType NUMBER(5, 0) NULL
	 , FeeSchedulePercent NUMBER(5, 0) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
	 , TurnAroundTime NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.Prf_CustomIcdAction (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CustomIcdActionId NUMBER(10, 0) NOT NULL
	 , ProfileId NUMBER(10, 0) NULL
	 , IcdVersionId NUMBER(3, 0) NULL
	 , Action NUMBER(5, 0) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
);

CREATE OR REPLACE TABLE stg.prf_Office (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CompanyId NUMBER(10, 0) NULL
	 , OfficeId NUMBER(10, 0) NOT NULL
	 , OfcNo VARCHAR(4) NULL
	 , OfcName VARCHAR(40) NULL
	 , OfcAddr1 VARCHAR(30) NULL
	 , OfcAddr2 VARCHAR(30) NULL
	 , OfcCity VARCHAR(30) NULL
	 , OfcState VARCHAR(2) NULL
	 , OfcZip VARCHAR(12) NULL
	 , OfcPhone VARCHAR(20) NULL
	 , OfcDefault NUMBER(5, 0) NULL
	 , OfcClaimMask VARCHAR(50) NULL
	 , OfcTinMask VARCHAR(50) NULL
	 , Version NUMBER(5, 0) NULL
	 , OfcEdits NUMBER(10, 0) NULL
	 , OfcCOAEnabled NUMBER(5, 0) NULL
	 , CTGEnabled NUMBER(5, 0) NULL
	 , LastChangedOn DATETIME NULL
	 , AllowMultiCoverage BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.Prf_OfficeUDF (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , OfficeId NUMBER(10, 0) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.prf_PPO (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PPOSysId NUMBER(10, 0) NOT NULL
	 , ProfileId NUMBER(10, 0) NULL
	 , PPOId NUMBER(10, 0) NULL
	 , bStatus NUMBER(5, 0) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
	 , AutoSend NUMBER(5, 0) NULL
	 , AutoResend NUMBER(5, 0) NULL
	 , BypassMatching NUMBER(5, 0) NULL
	 , UseProviderNetworkEnrollment NUMBER(5, 0) NULL
	 , TieredTypeId NUMBER(5, 0) NULL
	 , Priority NUMBER(5, 0) NULL
	 , PolicyEffectiveDate DATETIME NULL
	 , BillFormType NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.prf_Profile (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProfileId NUMBER(10, 0) NOT NULL
	 , OfficeId NUMBER(10, 0) NULL
	 , CoverageId VARCHAR(2) NULL
	 , StateId VARCHAR(2) NULL
	 , AnHeader VARCHAR NULL
	 , AnFooter VARCHAR NULL
	 , ExHeader VARCHAR NULL
	 , ExFooter VARCHAR NULL
	 , AnalystEdits NUMBER(19, 0) NULL
	 , DxEdits NUMBER(10, 0) NULL
	 , DxNonTraumaDays NUMBER(10, 0) NULL
	 , DxNonSpecDays NUMBER(10, 0) NULL
	 , PrintCopies NUMBER(10, 0) NULL
	 , NewPvdState VARCHAR(2) NULL
	 , bDuration NUMBER(5, 0) NULL
	 , bLimits NUMBER(5, 0) NULL
	 , iDurPct NUMBER(5, 0) NULL
	 , iLimitPct NUMBER(5, 0) NULL
	 , PolicyLimit NUMBER(19, 4) NULL
	 , CoPayPercent NUMBER(10, 0) NULL
	 , CoPayMax NUMBER(19, 4) NULL
	 , Deductible NUMBER(19, 4) NULL
	 , PolicyWarn NUMBER(5, 0) NULL
	 , PolicyWarnPerc NUMBER(10, 0) NULL
	 , FeeSchedules NUMBER(10, 0) NULL
	 , DefaultProfile NUMBER(5, 0) NULL
	 , FeeAncillaryPct NUMBER(5, 0) NULL
	 , iGapdol NUMBER(5, 0) NULL
	 , iGapTreatmnt NUMBER(5, 0) NULL
	 , bGapTreatmnt NUMBER(5, 0) NULL
	 , bGapdol NUMBER(5, 0) NULL
	 , bPrintAdjustor NUMBER(5, 0) NULL
	 , sPrinterName VARCHAR(50) NULL
	 , ErEdits NUMBER(10, 0) NULL
	 , ErAllowedDays NUMBER(10, 0) NULL
	 , UcrFsRules NUMBER(10, 0) NULL
	 , LogoIdNo NUMBER(10, 0) NULL
	 , LogoJustify NUMBER(5, 0) NULL
	 , BillLine VARCHAR(50) NULL
	 , Version NUMBER(5, 0) NULL
	 , ClaimDeductible NUMBER(5, 0) NULL
	 , IncludeCommitted NUMBER(5, 0) NULL
	 , FLMedicarePercent NUMBER(5, 0) NULL
	 , UseLevelOfServiceUrl NUMBER(5, 0) NULL
	 , LevelOfServiceURL VARCHAR(250) NULL
	 , CCIPrimary NUMBER(5, 0) NULL
	 , CCISecondary NUMBER(5, 0) NULL
	 , CCIMutuallyExclusive NUMBER(5, 0) NULL
	 , CCIComprehensiveComponent NUMBER(5, 0) NULL
	 , PayDRGAllowance NUMBER(5, 0) NULL
	 , FLHospEmPriceOn NUMBER(5, 0) NULL
	 , EnableBillRelease NUMBER(5, 0) NULL
	 , DisableSubmitBill NUMBER(5, 0) NULL
	 , MaxPaymentsPerBill NUMBER(5, 0) NULL
	 , NoOfPmtPerBill NUMBER(10, 0) NULL
	 , DefaultDueDate NUMBER(5, 0) NULL
	 , CheckForNJCarePaths NUMBER(5, 0) NULL
	 , NJCarePathPercentFS NUMBER(5, 0) NULL
	 , ApplyEndnoteForNJCarePaths NUMBER(5, 0) NULL
	 , FLMedicarePercent2008 NUMBER(5, 0) NULL
	 , RequireEndnoteDuringOverride NUMBER(5, 0) NULL
	 , StorePerUnitFSandUCR NUMBER(5, 0) NULL
	 , UseProviderNetworkEnrollment NUMBER(5, 0) NULL
	 , UseASCRule NUMBER(5, 0) NULL
	 , AsstCoSurgeonEligible NUMBER(5, 0) NULL
	 , LastChangedOn DATETIME NULL
	 , IsNJPhysMedCapAfterCTG NUMBER(5, 0) NULL
	 , IsEligibleAmtFeeBased NUMBER(5, 0) NULL
	 , HideClaimTreeTotalsGrid NUMBER(5, 0) NULL
	 , SortBillsBy NUMBER(5, 0) NULL
	 , SortBillsByOrder NUMBER(5, 0) NULL
	 , ApplyNJEmergencyRoomBenchmarkFee NUMBER(5, 0) NULL
	 , AllowIcd10ForNJCarePaths NUMBER(5, 0) NULL
	 , EnableOverrideDeductible BOOLEAN NULL
	 , AnalyzeDiagnosisPointers BOOLEAN NULL
	 , MedicareFeePercent NUMBER(5, 0) NULL
	 , EnableSupplementalNdcData BOOLEAN NULL
	 , ApplyOriginalNdcAwp BOOLEAN NULL
	 , NdcAwpNotAvailable NUMBER(3, 0) NULL
	 , PayEapgAllowance NUMBER(5, 0) NULL
	 , MedicareInpatientApcEnabled BOOLEAN NULL
	 , MedicareOutpatientAscEnabled BOOLEAN NULL
	 , MedicareAscEnabled BOOLEAN NULL
	 , UseMedicareInpatientApcFee BOOLEAN NULL
	 , MedicareInpatientDrgEnabled BOOLEAN NULL
	 , MedicareInpatientDrgPricingType NUMBER(5, 0) NULL
	 , MedicarePhysicianEnabled BOOLEAN NULL
	 , MedicareAmbulanceEnabled BOOLEAN NULL
	 , MedicareDmeposEnabled BOOLEAN NULL
	 , MedicareAspDrugAndClinicalEnabled BOOLEAN NULL
	 , MedicareInpatientPricingType NUMBER(5, 0) NULL
	 , MedicareOutpatientPricingRulesEnabled BOOLEAN NULL
	 , MedicareAscPricingRulesEnabled BOOLEAN NULL
	 , NjUseAdmitTypeEnabled BOOLEAN NULL
	 , MedicareClinicalLabEnabled BOOLEAN NULL
	 , MedicareInpatientEnabled BOOLEAN NULL
	 , MedicareOutpatientApcEnabled BOOLEAN NULL
	 , MedicareAspDrugEnabled BOOLEAN NULL
	 , ShowAllocationsOnEob BOOLEAN NULL
	 , EmergencyCarePricingRuleId NUMBER(3, 0) NULL
	 , OutOfStatePricingEffectiveDateId NUMBER(3, 0) NULL
	 , PreAllocation BOOLEAN NULL
	 , AssistantCoSurgeonModifiers NUMBER(5, 0) NULL
	 , AssistantSurgeryModifierNotMedicallyNecessary NUMBER(5, 0) NULL
	 , AssistantSurgeryModifierRequireAdditionalDocument NUMBER(5, 0) NULL
	 , CoSurgeryModifierNotMedicallyNecessary NUMBER(5, 0) NULL
	 , CoSurgeryModifierRequireAdditionalDocument NUMBER(5, 0) NULL
	 , DxNoDiagnosisDays NUMBER(10, 0) NULL
	 , ModifierExempted BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.ProcedureCodeGroup (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProcedureCode VARCHAR(7) NOT NULL
	 , MajorCategory VARCHAR(500) NULL
	 , MinorCategory VARCHAR(500) NULL
);

CREATE OR REPLACE TABLE stg.ProcedureServiceCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProcedureServiceCategoryId NUMBER(3, 0) NOT NULL
	 , ProcedureServiceCategoryName VARCHAR(50) NULL
	 , ProcedureServiceCategoryDescription VARCHAR(100) NULL
	 , LegacyTableName VARCHAR(100) NULL
	 , LegacyBitValue NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.ProcessAudit (
	  ProcessAuditId NUMBER(10, 0) NOT NULL
	, PostingGroupAuditId NUMBER(10, 0) NOT NULL
	, ProcessId NUMBER(5, 0) NOT NULL
	, Status VARCHAR(2) NOT NULL
	, TotalRecordsInSource NUMBER(19, 0) NULL
	, TotalRecordsInTarget NUMBER(19, 0) NULL
	, TotalDeletedRecords NUMBER(10, 0) NULL
	, ControlRowCount NUMBER(10, 0) NULL
	, ExtractRowCount NUMBER(10, 0) NULL
	, UpdateRowCount NUMBER(10, 0) NULL
	, LoadRowCount NUMBER(10, 0) NULL
	, ExtractDate DATETIME NULL
	, LastUpdateDate DATETIME NULL
	, LoadDate DATETIME NULL
	, CreateDate DATETIME NOT NULL
	, LastChangeDate DATETIME NOT NULL
);

CREATE OR REPLACE TABLE stg.ProvidedLink( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProvidedLinkId NUMBER (10,0) NULL
	 , Title VARCHAR (100) NULL
	 , URL VARCHAR (150) NULL
	 , OrderIndex NUMBER (3,0) NULL
 ); 
CREATE OR REPLACE TABLE stg.PROVIDER (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PvdIDNo NUMBER(10, 0) NOT NULL
	 , PvdMID NUMBER(10, 0) NULL
	 , PvdSource NUMBER(5, 0) NULL
	 , PvdTIN VARCHAR(15) NULL
	 , PvdLicNo VARCHAR(30) NULL
	 , PvdCertNo VARCHAR(30) NULL
	 , PvdLastName VARCHAR(60) NULL
	 , PvdFirstName VARCHAR(35) NULL
	 , PvdMI VARCHAR(1) NULL
	 , PvdTitle VARCHAR(5) NULL
	 , PvdGroup VARCHAR(60) NULL
	 , PvdAddr1 VARCHAR(55) NULL
	 , PvdAddr2 VARCHAR(55) NULL
	 , PvdCity VARCHAR(30) NULL
	 , PvdState VARCHAR(2) NULL
	 , PvdZip VARCHAR(12) NULL
	 , PvdZipPerf VARCHAR(12) NULL
	 , PvdPhone VARCHAR(25) NULL
	 , PvdFAX VARCHAR(13) NULL
	 , PvdSPC_List VARCHAR NULL
	 , PvdAuthNo VARCHAR(30) NULL
	 , PvdSPC_ACD VARCHAR(2) NULL
	 , PvdUpdateCounter NUMBER(5, 0) NULL
	 , PvdPPO_Provider NUMBER(5, 0) NULL
	 , PvdFlags NUMBER(10, 0) NULL
	 , PvdERRate NUMBER(19, 4) NULL
	 , PvdSubNet VARCHAR(4) NULL
	 , InUse VARCHAR(100) NULL
	 , PvdStatus NUMBER(10, 0) NULL
	 , PvdElectroStartDate DATETIME NULL
	 , PvdElectroEndDate DATETIME NULL
	 , PvdAccredStartDate DATETIME NULL
	 , PvdAccredEndDate DATETIME NULL
	 , PvdRehabStartDate DATETIME NULL
	 , PvdRehabEndDate DATETIME NULL
	 , PvdTraumaStartDate DATETIME NULL
	 , PvdTraumaEndDate DATETIME NULL
	 , OPCERT VARCHAR(7) NULL
	 , PvdDentalStartDate DATETIME NULL
	 , PvdDentalEndDate DATETIME NULL
	 , PvdNPINo VARCHAR(10) NULL
	 , PvdCMSId VARCHAR(6) NULL
	 , CreateDate DATETIME NULL
	 , LastChangedOn DATETIME NULL
);

CREATE OR REPLACE TABLE stg.ProviderCluster (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PvdIDNo NUMBER(10, 0) NOT NULL
	 , OrgOdsCustomerId NUMBER(10, 0) NOT NULL
	 , MitchellProviderKey VARCHAR(200) NULL
	 , ProviderClusterKey VARCHAR(200) NULL
	 , ProviderType VARCHAR(30) NULL
);

CREATE OR REPLACE TABLE stg.ProviderNetworkEventLog (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , IDField NUMBER(10, 0) NOT NULL
	 , LogDate DATETIME NULL
	 , EventId NUMBER(10, 0) NULL
	 , ClaimIdNo NUMBER(10, 0) NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , UserId NUMBER(10, 0) NULL
	 , NetworkId NUMBER(10, 0) NULL
	 , FileName VARCHAR(255) NULL
	 , ExtraText VARCHAR(1000) NULL
	 , ProcessInfo NUMBER(5, 0) NULL
	 , TieredTypeID NUMBER(5, 0) NULL
	 , TierNumber NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.ProviderNumberCriteria (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProviderNumberCriteriaId NUMBER(5, 0) NOT NULL
	 , ProviderNumber NUMBER(10, 0) NULL
	 , Priority NUMBER(3, 0) NULL
	 , FeeScheduleTable VARCHAR(1) NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
);

CREATE OR REPLACE TABLE stg.ProviderNumberCriteriaRevenueCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProviderNumberCriteriaId NUMBER(5, 0) NOT NULL
	 , RevenueCode VARCHAR(4) NOT NULL
	 , MatchingProfileNumber NUMBER(3, 0) NULL
	 , AttributeMatchTypeId NUMBER(3, 0) NULL
);

CREATE OR REPLACE TABLE stg.ProviderNumberCriteriaTypeOfBill (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProviderNumberCriteriaId NUMBER(5, 0) NOT NULL
	 , TypeOfBill VARCHAR(4) NOT NULL
	 , MatchingProfileNumber NUMBER(3, 0) NULL
	 , AttributeMatchTypeId NUMBER(3, 0) NULL
);

CREATE OR REPLACE TABLE stg.ProviderSpecialty (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProviderId NUMBER(10, 0) NOT NULL
	 , SpecialtyCode VARCHAR(50) NOT NULL
);

CREATE OR REPLACE TABLE stg.ProviderSpecialtyToProvType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProviderType VARCHAR(20) NOT NULL
	 , ProviderType_Desc VARCHAR(80) NULL
	 , Specialty VARCHAR(20) NOT NULL
	 , Specialty_Desc VARCHAR(80) NULL
	 , CreateDate DATETIME NULL
	 , ModifyDate DATETIME NULL
	 , LogicalDelete VARCHAR(1) NULL
);

CREATE OR REPLACE TABLE stg.Provider_ClientRef (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PvdIdNo NUMBER(10, 0) NOT NULL
	 , ClientRefId VARCHAR(50) NULL
	 , ClientRefId2 VARCHAR(100) NULL
);

CREATE OR REPLACE TABLE stg.Provider_Rendering (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PvdIDNo NUMBER(10, 0) NOT NULL
	 , RenderingAddr1 VARCHAR(55) NULL
	 , RenderingAddr2 VARCHAR(55) NULL
	 , RenderingCity VARCHAR(30) NULL
	 , RenderingState VARCHAR(2) NULL
	 , RenderingZip VARCHAR(12) NULL
);

CREATE OR REPLACE TABLE stg.ReferenceBillApcLines (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , Line_No NUMBER(5, 0) NOT NULL
	 , PaymentAPC VARCHAR(5) NULL
	 , ServiceIndicator VARCHAR(2) NULL
	 , PaymentIndicator VARCHAR(1) NULL
	 , OutlierAmount NUMBER(19, 4) NULL
	 , PricerAllowed NUMBER(19, 4) NULL
	 , MedicareAmount NUMBER(19, 4) NULL
);

CREATE OR REPLACE TABLE stg.ReferenceSupplementBillApcLines (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , SeqNo NUMBER(5, 0) NOT NULL
	 , Line_No NUMBER(5, 0) NOT NULL
	 , PaymentAPC VARCHAR(5) NULL
	 , ServiceIndicator VARCHAR(2) NULL
	 , PaymentIndicator VARCHAR(1) NULL
	 , OutlierAmount NUMBER(19, 4) NULL
	 , PricerAllowed NUMBER(19, 4) NULL
	 , MedicareAmount NUMBER(19, 4) NULL
);

CREATE OR REPLACE TABLE stg.RenderingNpiStates( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ApplicationSettingsId NUMBER (10,0) NULL
	 , State VARCHAR (2) NULL
 ); 
CREATE OR REPLACE TABLE stg.RevenueCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RevenueCode VARCHAR(4) NOT NULL
	 , RevenueCodeSubCategoryId NUMBER(3, 0) NULL
);

CREATE OR REPLACE TABLE stg.RevenueCodeCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RevenueCodeCategoryId NUMBER(3, 0) NOT NULL
	 , Description VARCHAR(100) NULL
	 , NarrativeInformation VARCHAR(1000) NULL
);

CREATE OR REPLACE TABLE stg.RevenueCodeSubcategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RevenueCodeSubcategoryId NUMBER(3, 0) NOT NULL
	 , RevenueCodeCategoryId NUMBER(3, 0) NULL
	 , Description VARCHAR(100) NULL
	 , NarrativeInformation VARCHAR(1000) NULL
);

CREATE OR REPLACE TABLE stg.RPT_RsnCategories (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CategoryIdNo NUMBER(5, 0) NOT NULL
	 , CatDesc VARCHAR(50) NULL
	 , Priority NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.rsn_Override (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , ShortDesc VARCHAR(50) NULL
	 , LongDesc VARCHAR NULL
	 , CategoryIdNo NUMBER(5, 0) NULL
	 , ClientSpec NUMBER(5, 0) NULL
	 , COAIndex NUMBER(5, 0) NULL
	 , NJPenaltyPct NUMBER(9, 6) NULL
	 , NetworkID NUMBER(10, 0) NULL
	 , SpecialProcessing BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.rsn_REASONS (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , CV_Type VARCHAR(2) NULL
	 , ShortDesc VARCHAR(50) NULL
	 , LongDesc VARCHAR NULL
	 , CategoryIdNo NUMBER(10, 0) NULL
	 , COAIndex NUMBER(5, 0) NULL
	 , OverrideEndnote NUMBER(10, 0) NULL
	 , HardEdit NUMBER(5, 0) NULL
	 , SpecialProcessing BOOLEAN NULL
	 , EndnoteActionId NUMBER(3, 0) NULL
	 , RetainForEapg BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.Rsn_Reasons_3rdParty (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ReasonNumber NUMBER(10, 0) NOT NULL
	 , ShortDesc VARCHAR(50) NULL
	 , LongDesc VARCHAR NULL
);

CREATE OR REPLACE TABLE stg.RuleType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleTypeID NUMBER(10, 0) NOT NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR(150) NULL
);

CREATE OR REPLACE TABLE stg.ScriptAdvisorBillSource (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillSourceId NUMBER(3, 0) NOT NULL
	 , BillSource VARCHAR(15) NULL
);

CREATE OR REPLACE TABLE stg.ScriptAdvisorSettings (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ScriptAdvisorSettingsId NUMBER(3, 0) NOT NULL
	 , IsPharmacyEligible BOOLEAN NULL
	 , EnableSendCardToClaimant BOOLEAN NULL
	 , EnableBillSource BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.ScriptAdvisorSettingsCoverageType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ScriptAdvisorSettingsId NUMBER(3, 0) NOT NULL
	 , CoverageType VARCHAR(2) NOT NULL
);

CREATE OR REPLACE TABLE stg.SEC_RightGroups (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RightGroupId NUMBER(10, 0) NOT NULL
	 , RightGroupName VARCHAR(50) NULL
	 , RightGroupDescription VARCHAR(150) NULL
	 , CreatedDate DATETIME NULL
	 , CreatedBy VARCHAR(50) NULL
);

CREATE OR REPLACE TABLE stg.SEC_Users (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , UserId NUMBER(10, 0) NOT NULL
	 , LoginName VARCHAR(15) NULL
	 , Password VARCHAR(30) NULL
	 , CreatedBy VARCHAR(50) NULL
	 , CreatedDate DATETIME NULL
	 , UserStatus NUMBER(10, 0) NULL
	 , FirstName VARCHAR(20) NULL
	 , LastName VARCHAR(20) NULL
	 , AccountLocked NUMBER(5, 0) NULL
	 , LockedCounter NUMBER(5, 0) NULL
	 , PasswordCreateDate DATETIME NULL
	 , PasswordCaseFlag NUMBER(5, 0) NULL
	 , ePassword VARCHAR(30) NULL
	 , CurrentSettings VARCHAR NULL
);

CREATE OR REPLACE TABLE stg.SEC_User_OfficeGroups (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , SECUserOfficeGroupId NUMBER(10, 0) NOT NULL
	 , UserId NUMBER(10, 0) NULL
	 , OffcGroupId NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.SEC_User_RightGroups (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , SECUserRightGroupId NUMBER(10, 0) NOT NULL
	 , UserId NUMBER(10, 0) NULL
	 , RightGroupId NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.SentryRuleTypeCriteria (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleTypeId NUMBER(10, 0) NOT NULL
	 , CriteriaId NUMBER(10, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.SENTRY_ACTION (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ActionID NUMBER(10, 0) NOT NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR(100) NULL
	 , CompatibilityKey VARCHAR(50) NULL
	 , PredefinedValues VARCHAR NULL
	 , ValueDataType VARCHAR(50) NULL
	 , ValueFormat VARCHAR(250) NULL
	 , BillLineAction NUMBER(10, 0) NULL
	 , AnalyzeFlag NUMBER(5, 0) NULL
	 , ActionCategoryIDNo NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.SENTRY_ACTION_CATEGORY (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ActionCategoryIDNo NUMBER(10, 0) NOT NULL
	 , Description VARCHAR(60) NULL
);

CREATE OR REPLACE TABLE stg.SENTRY_CRITERIA (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CriteriaID NUMBER(10, 0) NOT NULL
	 , ParentName VARCHAR(50) NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR(150) NULL
	 , Operators VARCHAR(50) NULL
	 , PredefinedValues VARCHAR NULL
	 , ValueDataType VARCHAR(50) NULL
	 , ValueFormat VARCHAR(250) NULL
	 , NullAllowed NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.SENTRY_PROFILE_RULE (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProfileID NUMBER(10, 0) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , Priority NUMBER(10, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.SENTRY_RULE (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR NULL
	 , CreatedBy VARCHAR(50) NULL
	 , CreationDate DATETIME NULL
	 , PostFixNotation VARCHAR NULL
	 , Priority NUMBER(10, 0) NULL
	 , RuleTypeID NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.SENTRY_RULE_ACTION_DETAIL (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , LineNumber NUMBER(10, 0) NOT NULL
	 , ActionID NUMBER(10, 0) NULL
	 , ActionValue VARCHAR(1000) NULL
);

CREATE OR REPLACE TABLE stg.SENTRY_RULE_ACTION_HEADER (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , EndnoteShort VARCHAR(50) NULL
	 , EndnoteLong VARCHAR NULL
);

CREATE OR REPLACE TABLE stg.SENTRY_RULE_CONDITION (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , LineNumber NUMBER(10, 0) NOT NULL
	 , GroupFlag VARCHAR(50) NULL
	 , CriteriaID NUMBER(10, 0) NULL
	 , Operator VARCHAR(50) NULL
	 , ConditionValue VARCHAR(60) NULL
	 , AndOr VARCHAR(50) NULL
	 , UdfConditionId NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.SPECIALTY (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , SpcIdNo NUMBER(10, 0) NULL
	 , Code VARCHAR(50) NOT NULL
	 , Description VARCHAR(70) NULL
	 , PayeeSubTypeID NUMBER(10, 0) NULL
	 , TieredTypeID NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.StateSettingMedicare (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingMedicareId NUMBER(10, 0) NOT NULL
	 , PayPercentOfMedicareFee BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.StateSettingsFlorida (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsFloridaId NUMBER(10, 0) NOT NULL
	 , ClaimantInitialServiceOption NUMBER(5, 0) NULL
	 , ClaimantInitialServiceDays NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.StateSettingsHawaii (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsHawaiiId NUMBER(10, 0) NOT NULL
	 , PhysicalMedicineLimitOption NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.StateSettingsNewJersey (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsNewJerseyId NUMBER(10, 0) NOT NULL
	 , ByPassEmergencyServices BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.StateSettingsNewJerseyPolicyPreference (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PolicyPreferenceId NUMBER(10, 0) NOT NULL
	 , ShareCoPayMaximum BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.StateSettingsNewYorkPolicyPreference (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PolicyPreferenceId NUMBER(10, 0) NOT NULL
	 , ShareCoPayMaximum BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.StateSettingsNY (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsNYID NUMBER(10, 0) NOT NULL
	 , NF10PrintDate BOOLEAN NULL
	 , NF10CheckBox1 BOOLEAN NULL
	 , NF10CheckBox18 BOOLEAN NULL
	 , NF10UseUnderwritingCompany BOOLEAN NULL
	 , UnderwritingCompanyUdfId NUMBER(10, 0) NULL
	 , NaicUdfId NUMBER(10, 0) NULL
	 , DisplayNYPrintOptionsWhenZosOrSojIsNY BOOLEAN NULL
	 , NF10DuplicatePrint BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.StateSettingsNyRoomRate (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsNyRoomRateId NUMBER(10, 0) NOT NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
	 , RoomRate NUMBER(19, 4) NULL
);

CREATE OR REPLACE TABLE stg.StateSettingsOregon (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsOregonId NUMBER(3, 0) NOT NULL
	 , ApplyOregonFeeSchedule BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.StateSettingsOregonCoverageType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsOregonId NUMBER(3, 0) NOT NULL
	 , CoverageType VARCHAR(2) NOT NULL
);

CREATE OR REPLACE TABLE stg.SupplementBillApportionmentEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillId NUMBER(10, 0) NOT NULL
	 , SequenceNumber NUMBER(5, 0) NOT NULL
	 , LineNumber NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.SupplementBillCustomEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillId NUMBER(10, 0) NOT NULL
	 , SequenceNumber NUMBER(5, 0) NOT NULL
	 , LineNumber NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.SupplementBill_Pharm_ApportionmentEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillId NUMBER(10, 0) NOT NULL
	 , SequenceNumber NUMBER(5, 0) NOT NULL
	 , LineNumber NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.SupplementPreCtgDeniedLinesEligibleToPenalty( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER (10,0) NULL
	 , LineNumber NUMBER (5,0) NULL
	 , CtgPenaltyTypeId NUMBER (3,0) NULL
	 , SeqNo NUMBER (5,0) NULL
 ); 
CREATE OR REPLACE TABLE stg.SurgicalModifierException (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Modifier VARCHAR(2) NOT NULL
	 , State VARCHAR(2) NOT NULL
	 , CoverageType VARCHAR(2) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
);

CREATE OR REPLACE TABLE stg.Tag (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TagId NUMBER(10, 0) NOT NULL
	 , NAME VARCHAR(50) NULL
	 , DateCreated TIMESTAMP_LTZ(7) NULL
	 , DateModified TIMESTAMP_LTZ(7) NULL
	 , CreatedBy VARCHAR(15) NULL
	 , ModifiedBy VARCHAR(15) NULL
);

CREATE OR REPLACE TABLE stg.TreatmentCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TreatmentCategoryId NUMBER(3, 0) NOT NULL
	 , Category VARCHAR(50) NULL
	 , Metadata VARCHAR NULL
);

CREATE OR REPLACE TABLE stg.TreatmentCategoryRange (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TreatmentCategoryRangeId NUMBER(10, 0) NOT NULL
	 , TreatmentCategoryId NUMBER(3, 0) NULL
	 , StartRange VARCHAR(7) NULL
	 , EndRange VARCHAR(7) NULL
);

CREATE OR REPLACE TABLE stg.Ub_Apc_Dict (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , APC VARCHAR(5) NOT NULL
	 , Description VARCHAR(255) NULL
);

CREATE OR REPLACE TABLE stg.UB_BillType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TOB VARCHAR(4) NOT NULL
	 , Description VARCHAR NULL
	 , Flag NUMBER(10, 0) NULL
	 , UB_BillTypeID NUMBER(10, 0) NULL
);

CREATE OR REPLACE TABLE stg.UB_RevenueCodes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RevenueCode VARCHAR(4) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , PRC_DESC VARCHAR NULL
	 , Flags NUMBER(10, 0) NULL
	 , Vague VARCHAR(1) NULL
	 , PerVisit NUMBER(5, 0) NULL
	 , PerClaimant NUMBER(5, 0) NULL
	 , PerProvider NUMBER(5, 0) NULL
	 , BodyFlags NUMBER(10, 0) NULL
	 , DrugFlag NUMBER(5, 0) NULL
	 , CurativeFlag NUMBER(5, 0) NULL
	 , RevenueCodeSubCategoryId NUMBER(3, 0) NULL
);

CREATE OR REPLACE TABLE stg.UDFBill (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
	 , UDFValueText VARCHAR(255) NULL
	 , UDFValueDecimal NUMBER(19, 4) NULL
	 , UDFValueDate DATETIME NULL
);

CREATE OR REPLACE TABLE stg.UDFClaim (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ClaimIdNo NUMBER(10, 0) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
	 , UDFValueText VARCHAR(255) NULL
	 , UDFValueDecimal NUMBER(19, 4) NULL
	 , UDFValueDate DATETIME NULL
);

CREATE OR REPLACE TABLE stg.UDFClaimant (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CmtIdNo NUMBER(10, 0) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
	 , UDFValueText VARCHAR(255) NULL
	 , UDFValueDecimal NUMBER(19, 4) NULL
	 , UDFValueDate DATETIME NULL
);

CREATE OR REPLACE TABLE stg.UdfDataFormat (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , UdfDataFormatId NUMBER(5, 0) NOT NULL
	 , DataFormatName VARCHAR(30) NULL
);

CREATE OR REPLACE TABLE stg.UDFLevelChangeTracking (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , UDFLevelChangeTrackingId NUMBER(10, 0) NOT NULL
	 , EntityType NUMBER(10, 0) NULL
	 , EntityId NUMBER(10, 0) NULL
	 , CorrelationId VARCHAR(50) NULL
	 , UDFId NUMBER(10, 0) NULL
	 , PreviousValue VARCHAR NULL
	 , UpdatedValue VARCHAR NULL
	 , UserId NUMBER(10, 0) NULL
	 , ChangeDate DATETIME NULL
);

CREATE OR REPLACE TABLE stg.UDFLibrary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
	 , UDFName VARCHAR(50) NULL
	 , ScreenType NUMBER(5, 0) NULL
	 , UDFDescription VARCHAR(1000) NULL
	 , DataFormat NUMBER(5, 0) NULL
	 , RequiredField NUMBER(5, 0) NULL
	 , ReadOnly NUMBER(5, 0) NULL
	 , Invisible NUMBER(5, 0) NULL
	 , TextMaxLength NUMBER(5, 0) NULL
	 , TextMask VARCHAR(50) NULL
	 , TextEnforceLength NUMBER(5, 0) NULL
	 , RestrictRange NUMBER(5, 0) NULL
	 , MinValDecimal FLOAT(24) NULL
	 , MaxValDecimal FLOAT(24) NULL
	 , MinValDate DATETIME NULL
	 , MaxValDate DATETIME NULL
	 , ListAllowMultiple NUMBER(5, 0) NULL
	 , DefaultValueText VARCHAR(100) NULL
	 , DefaultValueDecimal FLOAT(24) NULL
	 , DefaultValueDate DATETIME NULL
	 , UseDefault NUMBER(5, 0) NULL
	 , ReqOnSubmit NUMBER(5, 0) NULL
	 , IncludeDateButton BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.UDFListValues (
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

CREATE OR REPLACE TABLE stg.UDFProvider (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PvdIdNo NUMBER(10, 0) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
	 , UDFValueText VARCHAR(255) NULL
	 , UDFValueDecimal NUMBER(19, 4) NULL
	 , UDFValueDate DATETIME NULL
);

CREATE OR REPLACE TABLE stg.UDFViewOrder (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , OfficeId NUMBER(10, 0) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
	 , ViewOrder NUMBER(5, 0) NULL
);

CREATE OR REPLACE TABLE stg.UDF_Sentry_Criteria (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , UdfIdNo NUMBER(10, 0) NULL
	 , CriteriaID NUMBER(10, 0) NOT NULL
	 , ParentName VARCHAR(50) NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR(1000) NULL
	 , Operators VARCHAR(50) NULL
	 , PredefinedValues VARCHAR NULL
	 , ValueDataType VARCHAR(50) NULL
	 , ValueFormat VARCHAR(50) NULL
);

CREATE OR REPLACE TABLE stg.Vpn (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , VpnId NUMBER(5, 0) NOT NULL
	 , NetworkName VARCHAR(50) NULL
	 , PendAndSend BOOLEAN NULL
	 , BypassMatching BOOLEAN NULL
	 , AllowsResends BOOLEAN NULL
	 , OdsEligible BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.VPNActivityFlag (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Activity_Flag VARCHAR(1) NOT NULL
	 , AF_Description VARCHAR(50) NULL
	 , AF_ShortDesc VARCHAR(50) NULL
	 , Data_Source VARCHAR(5) NULL
	 , Default_Billable BOOLEAN NULL
	 , Credit BOOLEAN NULL
);

CREATE OR REPLACE TABLE stg.VPNBillableFlags (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , SOJ VARCHAR(2) NOT NULL
	 , NetworkID NUMBER(10, 0) NOT NULL
	 , ActivityFlag VARCHAR(2) NOT NULL
	 , Billable VARCHAR(1) NULL
	 , CompanyCode VARCHAR(10) NOT NULL
	 , CompanyName VARCHAR(100) NULL
);

CREATE OR REPLACE TABLE stg.VpnBillingCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , VpnBillingCategoryCode VARCHAR(1) NOT NULL
	 , VpnBillingCategoryDescription VARCHAR(30) NULL
);

CREATE OR REPLACE TABLE stg.VpnLedger (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TransactionID NUMBER(19, 0) NOT NULL
	 , TransactionTypeID NUMBER(10, 0) NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , Line_No NUMBER(5, 0) NULL
	 , Charged NUMBER(19, 4) NULL
	 , DPAllowed NUMBER(19, 4) NULL
	 , VPNAllowed NUMBER(19, 4) NULL
	 , Savings NUMBER(19, 4) NULL
	 , Credits NUMBER(19, 4) NULL
	 , HasOverride BOOLEAN NULL
	 , EndNotes VARCHAR(200) NULL
	 , NetworkIdNo NUMBER(10, 0) NULL
	 , ProcessFlag NUMBER(5, 0) NULL
	 , LineType NUMBER(10, 0) NULL
	 , DateTimeStamp DATETIME NULL
	 , SeqNo NUMBER(10, 0) NULL
	 , VPN_Ref_Line_No NUMBER(5, 0) NULL
	 , SpecialProcessing BOOLEAN NULL
	 , CreateDate DATETIME NULL
	 , LastChangedOn DATETIME NULL
	 , AdjustedCharged NUMBER(19, 4) NULL
);

CREATE OR REPLACE TABLE stg.VpnProcessFlagType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , VpnProcessFlagTypeId NUMBER(5, 0) NOT NULL
	 , VpnProcessFlagType VARCHAR(50) NULL
);

CREATE OR REPLACE TABLE stg.VpnSavingTransactionType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , VpnSavingTransactionTypeId NUMBER(10, 0) NOT NULL
	 , VpnSavingTransactionType VARCHAR(50) NULL
);

CREATE OR REPLACE TABLE stg.Vpn_Billing_History (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Customer VARCHAR(50) NULL
	 , TransactionID NUMBER(19, 0) NOT NULL
	 , Period DATETIME NOT NULL
	 , ActivityFlag VARCHAR(1) NULL
	 , BillableFlag VARCHAR(1) NULL
	 , Void VARCHAR(4) NULL
	 , CreditType VARCHAR(10) NULL
	 , Network VARCHAR(50) NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , Line_No NUMBER(5, 0) NULL
	 , TransactionDate DATETIME NULL
	 , RepriceDate DATETIME NULL
	 , ClaimNo VARCHAR(50) NULL
	 , ProviderCharges NUMBER(19, 4) NULL
	 , DPAllowed NUMBER(19, 4) NULL
	 , VPNAllowed NUMBER(19, 4) NULL
	 , Savings NUMBER(19, 4) NULL
	 , Credits NUMBER(19, 4) NULL
	 , NetSavings NUMBER(19, 4) NULL
	 , SOJ VARCHAR(2) NULL
	 , seqno NUMBER(10, 0) NULL
	 , CompanyCode VARCHAR(10) NULL
	 , VpnId NUMBER(5, 0) NULL
	 , ProcessFlag NUMBER(5, 0) NULL
	 , SK NUMBER(10, 0) NULL
	 , DATABASE_NAME VARCHAR(100) NULL
	 , SubmittedToFinance BOOLEAN NULL
	 , IsInitialLoad BOOLEAN NULL
	 , VpnBillingCategoryCode VARCHAR(1) NULL
);

CREATE OR REPLACE TABLE stg.WeekEndsAndHolidays (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DayOfWeekDate DATETIME NULL
	 , DayName VARCHAR(3) NULL
	 , WeekEndsAndHolidayId NUMBER(10, 0) NOT NULL
);

CREATE OR REPLACE TABLE stg.Zip2County (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Zip VARCHAR(5) NOT NULL
	 , County VARCHAR(50) NULL
	 , State VARCHAR(2) NULL
);

CREATE OR REPLACE TABLE stg.ZipCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ZipCode VARCHAR(5) NOT NULL
	 , PrimaryRecord BOOLEAN NULL
	 , STATE VARCHAR(2) NULL
	 , City VARCHAR(30) NULL
	 , CityAlias VARCHAR(30) NOT NULL
	 , County VARCHAR(30) NULL
	 , Cbsa VARCHAR(5) NULL
	 , CbsaType VARCHAR(5) NULL
	 , ZipCodeRegionId NUMBER(3, 0) NULL
);

