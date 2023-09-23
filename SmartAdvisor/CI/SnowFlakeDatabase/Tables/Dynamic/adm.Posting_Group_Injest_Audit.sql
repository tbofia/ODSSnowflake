
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
