CREATE OR REPLACE FUNCTION aw.if_DemandPackageUploadedFile(
		if_OdsPostingGroupAuditId INT
)
RETURNS TABLE  (
		 OdsPostingGroupAuditId NUMBER(10,0)
		,OdsCustomerId NUMBER(10,0)
		,OdsCreateDate DATETIME
		,OdsSnapshotDate DATETIME
		,OdsRowIsCurrent INT
		,OdsHashbytesValue BINARY(8000)
		,DmlOperation VARCHAR(1)
		,DemandPackageUploadedFileId NUMBER(10,0)
		,DemandPackageId NUMBER(10,0)
		,FileName VARCHAR(255)
		,Size NUMBER(10,0)
		,DocStoreId VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DemandPackageUploadedFileId
		,t.DemandPackageId
		,t.FileName
		,t.Size
		,t.DocStoreId
FROM src.DemandPackageUploadedFile t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandPackageUploadedFileId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DemandPackageUploadedFile
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandPackageUploadedFileId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandPackageUploadedFileId = s.DemandPackageUploadedFileId
WHERE t.DmlOperation <> 'D'

$$;


