IF OBJECT_ID('adm.FK_ProcessAudit_PostingGroupAudit', 'F') IS NULL
ALTER TABLE adm.ProcessAudit ADD CONSTRAINT FK_ProcessAudit_PostingGroupAudit
    FOREIGN KEY (PostingGroupAuditId)
    REFERENCES adm.PostingGroupAudit(PostingGroupAuditId)
GO
