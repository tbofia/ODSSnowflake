
ALTER TABLE adm.Process_File_Audit 
    ADD CONSTRAINT FK_ProcessFileAudit_ProcessInjestAudit
	FOREIGN KEY (Process_Audit_Id)
    REFERENCES adm.Process_Injest_Audit (Process_Audit_Id);
