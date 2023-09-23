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

