
ALTER TABLE adm.Process_Injest_Audit 
    ADD CONSTRAINT FK_ProcessInjestAudit_PostingGroupInjestAudit
	FOREIGN KEY(Posting_Group_Audit_Id) 
	REFERENCES ADM.Posting_Group_Injest_Audit (Posting_Group_Audit_Id) ;
