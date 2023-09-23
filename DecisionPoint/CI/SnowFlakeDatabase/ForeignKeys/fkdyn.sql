
ALTER TABLE adm.Process_File_Audit 
    ADD CONSTRAINT FK_ProcessFileAudit_ProcessInjestAudit
	FOREIGN KEY (Process_Audit_Id)
    REFERENCES adm.Process_Injest_Audit (Process_Audit_Id);

ALTER TABLE adm.Process_Injest_Audit 
    ADD CONSTRAINT FK_ProcessInjestAudit_PostingGroupInjestAudit
	FOREIGN KEY(Posting_Group_Audit_Id) 
	REFERENCES ADM.Posting_Group_Injest_Audit (Posting_Group_Audit_Id) ;
