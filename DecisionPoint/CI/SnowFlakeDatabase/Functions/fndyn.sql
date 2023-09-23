CREATE OR REPLACE FUNCTION adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate (
OdsCustomerId INT,
SnapshotDate DATETIME)
RETURNS INT
AS
$$

SELECT MAX(PostingGroupAuditId)
FROM rpt.PostingGroupAudit pga
WHERE pga.CustomerId = CASE WHEN IFNULL(OdsCustomerId,0) = 0 THEN pga.CustomerId ELSE OdsCustomerId END
AND pga.SnapshotCreateDate <= IFNULL(SnapshotDate,Current_timestamp()::timestampNTZ) 
AND Status = 'FI'
$$;


CREATE OR REPLACE FUNCTION aw.if_AcceptedTreatmentDate(
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
		,AcceptedTreatmentDateId NUMBER(10,0)
		,DemandClaimantId NUMBER(10,0)
		,TreatmentDate TIMESTAMP_LTZ(7)
		,Comments VARCHAR(255)
		,TreatmentCategoryId NUMBER(3,0)
		,LastUpdatedBy VARCHAR(15)
		,LastUpdatedDate TIMESTAMP_LTZ(7) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.AcceptedTreatmentDateId
		,t.DemandClaimantId
		,t.TreatmentDate
		,t.Comments
		,t.TreatmentCategoryId
		,t.LastUpdatedBy
		,t.LastUpdatedDate
FROM src.AcceptedTreatmentDate t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AcceptedTreatmentDateId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AcceptedTreatmentDate
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AcceptedTreatmentDateId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AcceptedTreatmentDateId = s.AcceptedTreatmentDateId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_AnalysisGroup(
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
		,AnalysisGroupId NUMBER(10,0)
		,GroupName VARCHAR(200) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.AnalysisGroupId
		,t.GroupName
FROM src.AnalysisGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AnalysisGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AnalysisGroup
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AnalysisGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AnalysisGroupId = s.AnalysisGroupId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_AnalysisRule(
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
		,AnalysisRuleId NUMBER(10,0)
		,Title VARCHAR(200)
		,AssemblyQualifiedName VARCHAR(200)
		,MethodToInvoke VARCHAR(50)
		,DisplayMessage VARCHAR(200)
		,DisplayOrder NUMBER(10,0)
		,IsActive BOOLEAN
		,CreateDate TIMESTAMP_LTZ(7)
		,LastChangedOn TIMESTAMP_LTZ(7)
		,MessageToken VARCHAR(200) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.AnalysisRuleId
		,t.Title
		,t.AssemblyQualifiedName
		,t.MethodToInvoke
		,t.DisplayMessage
		,t.DisplayOrder
		,t.IsActive
		,t.CreateDate
		,t.LastChangedOn
		,t.MessageToken
FROM src.AnalysisRule t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AnalysisRuleId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AnalysisRule
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AnalysisRuleId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AnalysisRuleId = s.AnalysisRuleId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_AnalysisRuleGroup(
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
		,AnalysisRuleGroupId NUMBER(10,0)
		,AnalysisRuleId NUMBER(10,0)
		,AnalysisGroupId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.AnalysisRuleGroupId
		,t.AnalysisRuleId
		,t.AnalysisGroupId
FROM src.AnalysisRuleGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AnalysisRuleGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AnalysisRuleGroup
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AnalysisRuleGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AnalysisRuleGroupId = s.AnalysisRuleGroupId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_AnalysisRuleThreshold(
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
		,AnalysisRuleThresholdId NUMBER(10,0)
		,AnalysisRuleId NUMBER(10,0)
		,ThresholdKey VARCHAR(50)
		,ThresholdValue VARCHAR(100)
		,CreateDate TIMESTAMP_LTZ(7)
		,LastChangedOn TIMESTAMP_LTZ(7) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.AnalysisRuleThresholdId
		,t.AnalysisRuleId
		,t.ThresholdKey
		,t.ThresholdValue
		,t.CreateDate
		,t.LastChangedOn
FROM src.AnalysisRuleThreshold t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AnalysisRuleThresholdId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AnalysisRuleThreshold
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AnalysisRuleThresholdId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AnalysisRuleThresholdId = s.AnalysisRuleThresholdId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_ClaimantManualProviderSummary(
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
		,ManualProviderId NUMBER(10,0)
		,DemandClaimantId NUMBER(10,0)
		,FirstDateOfService DATETIME
		,LastDateOfService DATETIME
		,Visits NUMBER(10,0)
		,ChargedAmount NUMBER(19,4)
		,EvaluatedAmount NUMBER(19,4)
		,MinimumEvaluatedAmount NUMBER(19,4)
		,MaximumEvaluatedAmount NUMBER(19,4)
		,Comments VARCHAR(255) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ManualProviderId
		,t.DemandClaimantId
		,t.FirstDateOfService
		,t.LastDateOfService
		,t.Visits
		,t.ChargedAmount
		,t.EvaluatedAmount
		,t.MinimumEvaluatedAmount
		,t.MaximumEvaluatedAmount
		,t.Comments
FROM src.ClaimantManualProviderSummary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ManualProviderId,
		DemandClaimantId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimantManualProviderSummary
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ManualProviderId,
		DemandClaimantId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ManualProviderId = s.ManualProviderId
	AND t.DemandClaimantId = s.DemandClaimantId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_ClaimantProviderSummaryEvaluation(
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
		,ClaimantProviderSummaryEvaluationId NUMBER(10,0)
		,ClaimantHeaderId NUMBER(10,0)
		,EvaluatedAmount NUMBER(19,4)
		,MinimumEvaluatedAmount NUMBER(19,4)
		,MaximumEvaluatedAmount NUMBER(19,4)
		,Comments VARCHAR(255) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ClaimantProviderSummaryEvaluationId
		,t.ClaimantHeaderId
		,t.EvaluatedAmount
		,t.MinimumEvaluatedAmount
		,t.MaximumEvaluatedAmount
		,t.Comments
FROM src.ClaimantProviderSummaryEvaluation t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimantProviderSummaryEvaluationId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimantProviderSummaryEvaluation
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimantProviderSummaryEvaluationId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimantProviderSummaryEvaluationId = s.ClaimantProviderSummaryEvaluationId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_DemandClaimant(
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
		,DemandClaimantId NUMBER(10,0)
		,ExternalClaimantId NUMBER(10,0)
		,OrganizationId VARCHAR(100)
		,HeightInInches NUMBER(5,0)
		,Weight NUMBER(5,0)
		,Occupation VARCHAR(50)
		,BiReportStatus NUMBER(5,0)
		,HasDemandPackage NUMBER(10,0)
		,FactsOfLoss VARCHAR(250)
		,PreExistingConditions VARCHAR(100)
		,Archived BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DemandClaimantId
		,t.ExternalClaimantId
		,t.OrganizationId
		,t.HeightInInches
		,t.Weight
		,t.Occupation
		,t.BiReportStatus
		,t.HasDemandPackage
		,t.FactsOfLoss
		,t.PreExistingConditions
		,t.Archived
FROM src.DemandClaimant t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandClaimantId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DemandClaimant
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandClaimantId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandClaimantId = s.DemandClaimantId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_DemandPackage(
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
		,DemandPackageId NUMBER(10,0)
		,DemandClaimantId NUMBER(10,0)
		,RequestedByUserName VARCHAR(15)
		,DateTimeReceived TIMESTAMP_LTZ(7)
		,CorrelationId VARCHAR(36)
		,PageCount NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DemandPackageId
		,t.DemandClaimantId
		,t.RequestedByUserName
		,t.DateTimeReceived
		,t.CorrelationId
		,t.PageCount
FROM src.DemandPackage t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandPackageId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DemandPackage
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandPackageId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandPackageId = s.DemandPackageId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_DemandPackageRequestedService(
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
		,DemandPackageRequestedServiceId NUMBER(10,0)
		,DemandPackageId NUMBER(10,0)
		,ReviewRequestOptions VARCHAR )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DemandPackageRequestedServiceId
		,t.DemandPackageId
		,t.ReviewRequestOptions
FROM src.DemandPackageRequestedService t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandPackageRequestedServiceId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DemandPackageRequestedService
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandPackageRequestedServiceId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandPackageRequestedServiceId = s.DemandPackageRequestedServiceId
WHERE t.DmlOperation <> 'D'

$$;


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


CREATE OR REPLACE FUNCTION aw.if_EvaluationSummary(
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
		,DemandClaimantId NUMBER(10,0)
		,Details VARCHAR
		,CreatedBy VARCHAR(50)
		,CreatedDate TIMESTAMP_LTZ(7)
		,ModifiedBy VARCHAR(50)
		,ModifiedDate TIMESTAMP_LTZ(7)
		,EvaluationSummaryTemplateVersionId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DemandClaimantId
		,t.Details
		,t.CreatedBy
		,t.CreatedDate
		,t.ModifiedBy
		,t.ModifiedDate
		,t.EvaluationSummaryTemplateVersionId
FROM src.EvaluationSummary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandClaimantId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EvaluationSummary
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandClaimantId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandClaimantId = s.DemandClaimantId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_EvaluationSummaryHistory(
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
		,EvaluationSummaryHistoryId NUMBER(10,0)
		,DemandClaimantId NUMBER(10,0)
		,EvaluationSummary VARCHAR
		,CreatedBy VARCHAR(50)
		,CreatedDate TIMESTAMP_LTZ(7) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.EvaluationSummaryHistoryId
		,t.DemandClaimantId
		,t.EvaluationSummary
		,t.CreatedBy
		,t.CreatedDate
FROM src.EvaluationSummaryHistory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EvaluationSummaryHistoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EvaluationSummaryHistory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EvaluationSummaryHistoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EvaluationSummaryHistoryId = s.EvaluationSummaryHistoryId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_EvaluationSummaryTemplateVersion(
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
		,EvaluationSummaryTemplateVersionId NUMBER(10,0)
		,Template VARCHAR
		,TemplateHash BINARY(32)
		,CreatedDate TIMESTAMP_LTZ(7) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.EvaluationSummaryTemplateVersionId
		,t.Template
		,t.TemplateHash
		,t.CreatedDate
FROM src.EvaluationSummaryTemplateVersion t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EvaluationSummaryTemplateVersionId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EvaluationSummaryTemplateVersion
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EvaluationSummaryTemplateVersionId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EvaluationSummaryTemplateVersionId = s.EvaluationSummaryTemplateVersionId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_EventLog(
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
		,EventLogId NUMBER(10,0)
		,ObjectName VARCHAR(50)
		,ObjectId NUMBER(10,0)
		,UserName VARCHAR(15)
		,LogDate TIMESTAMP_LTZ(7)
		,ActionName VARCHAR(20)
		,OrganizationId VARCHAR(100) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.EventLogId
		,t.ObjectName
		,t.ObjectId
		,t.UserName
		,t.LogDate
		,t.ActionName
		,t.OrganizationId
FROM src.EventLog t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EventLogId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EventLog
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EventLogId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EventLogId = s.EventLogId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_EventLogDetail(
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
		,EventLogDetailId NUMBER(10,0)
		,EventLogId NUMBER(10,0)
		,PropertyName VARCHAR(50)
		,OldValue VARCHAR
		,NewValue VARCHAR )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.EventLogDetailId
		,t.EventLogId
		,t.PropertyName
		,t.OldValue
		,t.NewValue
FROM src.EventLogDetail t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EventLogDetailId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EventLogDetail
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EventLogDetailId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EventLogDetailId = s.EventLogDetailId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_ManualProvider(
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
		,ManualProviderId NUMBER(10,0)
		,TIN VARCHAR(15)
		,LastName VARCHAR(60)
		,FirstName VARCHAR(35)
		,GroupName VARCHAR(60)
		,Address1 VARCHAR(55)
		,Address2 VARCHAR(55)
		,City VARCHAR(30)
		,State VARCHAR(2)
		,Zip VARCHAR(12) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ManualProviderId
		,t.TIN
		,t.LastName
		,t.FirstName
		,t.GroupName
		,t.Address1
		,t.Address2
		,t.City
		,t.State
		,t.Zip
FROM src.ManualProvider t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ManualProviderId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ManualProvider
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ManualProviderId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ManualProviderId = s.ManualProviderId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_ManualProviderSpecialty(
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
		,ManualProviderId NUMBER(10,0)
		,Specialty VARCHAR(12) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ManualProviderId
		,t.Specialty
FROM src.ManualProviderSpecialty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ManualProviderId,
		Specialty,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ManualProviderSpecialty
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ManualProviderId,
		Specialty) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ManualProviderId = s.ManualProviderId
	AND t.Specialty = s.Specialty
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_Note(
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
		,NoteId NUMBER(10,0)
		,DateCreated TIMESTAMP_LTZ(7)
		,DateModified TIMESTAMP_LTZ(7)
		,CreatedBy VARCHAR(15)
		,ModifiedBy VARCHAR(15)
		,Flag NUMBER(3,0)
		,Content VARCHAR(250)
		,NoteContext NUMBER(5,0)
		,DemandClaimantId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.NoteId
		,t.DateCreated
		,t.DateModified
		,t.CreatedBy
		,t.ModifiedBy
		,t.Flag
		,t.Content
		,t.NoteContext
		,t.DemandClaimantId
FROM src.Note t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NoteId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Note
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NoteId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NoteId = s.NoteId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_PROVIDEDLINK(
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
		,PROVIDEDLINKID NUMBER(10,0)
		,TITLE VARCHAR(100)
		,URL VARCHAR(150)
		,ORDERINDEX	NUMBER(3,0))
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PROVIDEDLINKID
		,t.TITLE
		,t.URL
		,t.ORDERINDEX

FROM src.PROVIDEDLINK t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PROVIDEDLINKID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PROVIDEDLINK
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PROVIDEDLINKID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PROVIDEDLINKID = s.PROVIDEDLINKID
WHERE t.DmlOperation <> 'D'

$$;
CREATE OR REPLACE FUNCTION aw.if_Tag(
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
		,TagId NUMBER(10,0)
		,NAME VARCHAR(50)
		,DateCreated TIMESTAMP_LTZ(7)
		,DateModified TIMESTAMP_LTZ(7)
		,CreatedBy VARCHAR(15)
		,ModifiedBy VARCHAR(15) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.TagId
		,t.NAME
		,t.DateCreated
		,t.DateModified
		,t.CreatedBy
		,t.ModifiedBy
FROM src.Tag t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TagId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Tag
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TagId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TagId = s.TagId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_TreatmentCategory(
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
		,TreatmentCategoryId NUMBER(3,0)
		,Category VARCHAR(50)
		,Metadata VARCHAR )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.TreatmentCategoryId
		,t.Category
		,t.Metadata
FROM src.TreatmentCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TreatmentCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.TreatmentCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TreatmentCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TreatmentCategoryId = s.TreatmentCategoryId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION aw.if_TreatmentCategoryRange(
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
		,TreatmentCategoryRangeId NUMBER(10,0)
		,TreatmentCategoryId NUMBER(3,0)
		,StartRange VARCHAR(7)
		,EndRange VARCHAR(7) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.TreatmentCategoryRangeId
		,t.TreatmentCategoryId
		,t.StartRange
		,t.EndRange
FROM src.TreatmentCategoryRange t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TreatmentCategoryRangeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.TreatmentCategoryRange
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TreatmentCategoryRangeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TreatmentCategoryRangeId = s.TreatmentCategoryRangeId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Adjustment3603rdPartyEndNoteSubCategory(
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
		,ReasonNumber NUMBER(10,0)
		,SubCategoryId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ReasonNumber
		,t.SubCategoryId
FROM src.Adjustment3603rdPartyEndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment3603rdPartyEndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Adjustment360ApcEndNoteSubCategory(
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
		,ReasonNumber NUMBER(10,0)
		,SubCategoryId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ReasonNumber
		,t.SubCategoryId
FROM src.Adjustment360ApcEndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment360ApcEndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Adjustment360Category(
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
		,Adjustment360CategoryId NUMBER(10,0)
		,Name VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.Adjustment360CategoryId
		,t.Name
FROM src.Adjustment360Category t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Adjustment360CategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment360Category
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Adjustment360CategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Adjustment360CategoryId = s.Adjustment360CategoryId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Adjustment360EndNoteSubCategory(
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
		,ReasonNumber NUMBER(10,0)
		,SubCategoryId NUMBER(10,0)
		,EndnoteTypeId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ReasonNumber
		,t.SubCategoryId
		,t.EndnoteTypeId
FROM src.Adjustment360EndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		EndnoteTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment360EndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber,
		EndnoteTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
	AND t.EndnoteTypeId = s.EndnoteTypeId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Adjustment360OverrideEndNoteSubCategory(
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
		,ReasonNumber NUMBER(10,0)
		,SubCategoryId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ReasonNumber
		,t.SubCategoryId
FROM src.Adjustment360OverrideEndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment360OverrideEndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Adjustment360SubCategory(
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
		,Adjustment360SubCategoryId NUMBER(10,0)
		,Name VARCHAR(50)
		,Adjustment360CategoryId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.Adjustment360SubCategoryId
		,t.Name
		,t.Adjustment360CategoryId
FROM src.Adjustment360SubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Adjustment360SubCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment360SubCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Adjustment360SubCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Adjustment360SubCategoryId = s.Adjustment360SubCategoryId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Adjustment3rdPartyEndnoteSubCategory(
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
		,ReasonNumber NUMBER(10,0)
		,SubCategoryId VARCHAR(100) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ReasonNumber
		,t.SubCategoryId
FROM src.Adjustment3rdPartyEndnoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment3rdPartyEndnoteSubCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_AdjustmentApcEndNoteSubCategory(
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
		,ReasonNumber NUMBER(10,0)
		,SubCategoryId VARCHAR(100) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ReasonNumber
		,t.SubCategoryId
FROM src.AdjustmentApcEndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AdjustmentApcEndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_AdjustmentEndNoteSubCategory(
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
		,ReasonNumber NUMBER(10,0)
		,SubCategoryId VARCHAR(100) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ReasonNumber
		,t.SubCategoryId
FROM src.AdjustmentEndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AdjustmentEndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_AdjustmentOverrideEndNoteSubCategory(
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
		,ReasonNumber NUMBER(10,0)
		,SubCategoryId VARCHAR(100) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ReasonNumber
		,t.SubCategoryId
FROM src.AdjustmentOverrideEndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AdjustmentOverrideEndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Adjustor(
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
		,lAdjIdNo NUMBER(10,0)
		,IDNumber VARCHAR(15)
		,Lastname VARCHAR(30)
		,FirstName VARCHAR(30)
		,Address1 VARCHAR(30)
		,Address2 VARCHAR(30)
		,City VARCHAR(30)
		,State VARCHAR(2)
		,ZipCode VARCHAR(12)
		,Phone VARCHAR(25)
		,Fax VARCHAR(25)
		,Office VARCHAR(120)
		,EMail VARCHAR(60)
		,InUse VARCHAR(100)
		,OfficeIdNo NUMBER(10,0)
		,UserId NUMBER(10,0)
		,CreateDate DATETIME
		,LastChangedOn DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.lAdjIdNo
		,t.IDNumber
		,t.Lastname
		,t.FirstName
		,t.Address1
		,t.Address2
		,t.City
		,t.State
		,t.ZipCode
		,t.Phone
		,t.Fax
		,t.Office
		,t.EMail
		,t.InUse
		,t.OfficeIdNo
		,t.UserId
		,t.CreateDate
		,t.LastChangedOn
FROM src.Adjustor t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		lAdjIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustor
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		lAdjIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.lAdjIdNo = s.lAdjIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ApportionmentEndnote(
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
		,ApportionmentEndnote NUMBER(10,0)
		,ShortDescription VARCHAR(50)
		,LongDescription VARCHAR(500) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ApportionmentEndnote
		,t.ShortDescription
		,t.LongDescription
FROM src.ApportionmentEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ApportionmentEndnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ApportionmentEndnote
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ApportionmentEndnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ApportionmentEndnote = s.ApportionmentEndnote
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_BillAdjustment(
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
		,BillLineAdjustmentId NUMBER(19,0)
		,BillIdNo NUMBER(10,0)
		,LineNumber NUMBER(10,0)
		,Adjustment NUMBER(19,4)
		,EndNote NUMBER(10,0)
		,EndNoteTypeId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillLineAdjustmentId
		,t.BillIdNo
		,t.LineNumber
		,t.Adjustment
		,t.EndNote
		,t.EndNoteTypeId
FROM src.BillAdjustment t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillLineAdjustmentId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillAdjustment
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillLineAdjustmentId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillLineAdjustmentId = s.BillLineAdjustmentId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_BillApportionmentEndnote(
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
		,BillId NUMBER(10,0)
		,LineNumber NUMBER(5,0)
		,Endnote NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillId
		,t.LineNumber
		,t.Endnote
FROM src.BillApportionmentEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillId,
		LineNumber,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillApportionmentEndnote
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillId,
		LineNumber,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillId = s.BillId
	AND t.LineNumber = s.LineNumber
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_BillCustomEndnote(
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
		,BillId NUMBER(10,0)
		,LineNumber NUMBER(5,0)
		,Endnote NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillId
		,t.LineNumber
		,t.Endnote
FROM src.BillCustomEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillId,
		LineNumber,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillCustomEndnote
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillId,
		LineNumber,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillId = s.BillId
	AND t.LineNumber = s.LineNumber
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_BillExclusionLookUpTable(
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
		,ReportID NUMBER(3,0)
		,ReportName VARCHAR(100) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ReportID
		,t.ReportName
FROM src.BillExclusionLookUpTable t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReportID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillExclusionLookUpTable
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReportID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReportID = s.ReportID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_BILLS(
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
		,BillIDNo NUMBER(10,0)
		,LINE_NO NUMBER(5,0)
		,LINE_NO_DISP NUMBER(5,0)
		,OVER_RIDE NUMBER(5,0)
		,DT_SVC DATETIME
		,PRC_CD VARCHAR(7)
		,UNITS FLOAT(24)
		,TS_CD VARCHAR(14)
		,CHARGED NUMBER(19,4)
		,ALLOWED NUMBER(19,4)
		,ANALYZED NUMBER(19,4)
		,REASON1 NUMBER(10,0)
		,REASON2 NUMBER(10,0)
		,REASON3 NUMBER(10,0)
		,REASON4 NUMBER(10,0)
		,REASON5 NUMBER(10,0)
		,REASON6 NUMBER(10,0)
		,REASON7 NUMBER(10,0)
		,REASON8 NUMBER(10,0)
		,REF_LINE_NO NUMBER(5,0)
		,SUBNET VARCHAR(9)
		,OverrideReason NUMBER(5,0)
		,FEE_SCHEDULE NUMBER(19,4)
		,POS_RevCode VARCHAR(4)
		,CTGPenalty NUMBER(19,4)
		,PrePPOAllowed NUMBER(19,4)
		,PPODate DATETIME
		,PPOCTGPenalty NUMBER(19,4)
		,UCRPerUnit NUMBER(19,4)
		,FSPerUnit NUMBER(19,4)
		,HCRA_Surcharge NUMBER(19,4)
		,EligibleAmt NUMBER(19,4)
		,DPAllowed NUMBER(19,4)
		,EndDateOfService DATETIME
		,AnalyzedCtgPenalty NUMBER(19,4)
		,AnalyzedCtgPpoPenalty NUMBER(19,4)
		,RepackagedNdc VARCHAR(13)
		,OriginalNdc VARCHAR(13)
		,UnitOfMeasureId NUMBER(3,0)
		,PackageTypeOriginalNdc VARCHAR(2)
		,ServiceCode VARCHAR(25)
		,PreApportionedAmount NUMBER(19,4)
		,DeductibleApplied NUMBER(19,4)
		,BillReviewResults NUMBER(19,4)
		,PreOverriddenDeductible NUMBER(19,4)
		,RemainingBalance NUMBER(19,4) 
		,CtgCoPayPenalty NUMBER(19,4) 
	    ,PpoCtgCoPayPenaltyPercentage NUMBER(19,4) 
	    ,AnalyzedCtgCoPayPenalty NUMBER(19,4) 
	    ,AnalyzedPpoCtgCoPayPenaltyPercentage NUMBER(19,4) 
	    ,CtgVunPenalty NUMBER(19,4) 
	    ,PpoCtgVunPenaltyPercentage NUMBER(19,4) 
	    ,AnalyzedCtgVunPenalty NUMBER(19,4) 
	    ,AnalyzedPpoCtgVunPenaltyPercentage NUMBER(19,4)
		,RenderingNpi  VARCHAR(15) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIDNo
		,t.LINE_NO
		,t.LINE_NO_DISP
		,t.OVER_RIDE
		,t.DT_SVC
		,t.PRC_CD
		,t.UNITS
		,t.TS_CD
		,t.CHARGED
		,t.ALLOWED
		,t.ANALYZED
		,t.REASON1
		,t.REASON2
		,t.REASON3
		,t.REASON4
		,t.REASON5
		,t.REASON6
		,t.REASON7
		,t.REASON8
		,t.REF_LINE_NO
		,t.SUBNET
		,t.OverrideReason
		,t.FEE_SCHEDULE
		,t.POS_RevCode
		,t.CTGPenalty
		,t.PrePPOAllowed
		,t.PPODate
		,t.PPOCTGPenalty
		,t.UCRPerUnit
		,t.FSPerUnit
		,t.HCRA_Surcharge
		,t.EligibleAmt
		,t.DPAllowed
		,t.EndDateOfService
		,t.AnalyzedCtgPenalty
		,t.AnalyzedCtgPpoPenalty
		,t.RepackagedNdc
		,t.OriginalNdc
		,t.UnitOfMeasureId
		,t.PackageTypeOriginalNdc
		,t.ServiceCode
		,t.PreApportionedAmount
		,t.DeductibleApplied
		,t.BillReviewResults
		,t.PreOverriddenDeductible
		,t.RemainingBalance
		,t.CtgCoPayPenalty 
		,t.PpoCtgCoPayPenaltyPercentage 
		,t.AnalyzedCtgCoPayPenalty 
		,t.AnalyzedPpoCtgCoPayPenaltyPercentage 
		,t.CtgVunPenalty 
		,t.PpoCtgVunPenaltyPercentage 
		,t.AnalyzedCtgVunPenalty 
		,t.AnalyzedPpoCtgVunPenaltyPercentage 
		,t.RenderingNpi
FROM src.BILLS t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		LINE_NO,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILLS
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		LINE_NO) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.LINE_NO = s.LINE_NO
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_BillsOverride(
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
		,BillsOverrideID NUMBER(10,0)
		,BillIDNo NUMBER(10,0)
		,LINE_NO NUMBER(5,0)
		,UserId NUMBER(10,0)
		,DateSaved DATETIME
		,AmountBefore NUMBER(19,4)
		,AmountAfter NUMBER(19,4)
		,CodesOverrode VARCHAR(50)
		,SeqNo NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillsOverrideID
		,t.BillIDNo
		,t.LINE_NO
		,t.UserId
		,t.DateSaved
		,t.AmountBefore
		,t.AmountAfter
		,t.CodesOverrode
		,t.SeqNo
FROM src.BillsOverride t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillsOverrideID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillsOverride
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillsOverrideID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillsOverrideID = s.BillsOverrideID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_BillsProviderNetwork(
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
		,BillIdNo NUMBER(10,0)
		,NetworkId NUMBER(10,0)
		,NetworkName VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIdNo
		,t.NetworkId
		,t.NetworkName
FROM src.BillsProviderNetwork t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillsProviderNetwork
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_BILLS_CTG_Endnotes(
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
		,BillIdNo NUMBER(10,0)
		,Line_No NUMBER(5,0)
		,Endnote NUMBER(10,0)
		,RuleType VARCHAR(2)
		,RuleId NUMBER(10,0)
		,PreCertAction NUMBER(5,0)
		,PercentDiscount FLOAT(24)
		,ActionId NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIdNo
		,t.Line_No
		,t.Endnote
		,t.RuleType
		,t.RuleId
		,t.PreCertAction
		,t.PercentDiscount
		,t.ActionId
FROM src.BILLS_CTG_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Line_No,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILLS_CTG_Endnotes
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		Line_No,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.Line_No = s.Line_No
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_BILLS_DRG(
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
		,BillIdNo NUMBER(10,0)
		,PricerPassThru NUMBER(19,4)
		,PricerCapital_Outlier_Amt NUMBER(19,4)
		,PricerCapital_OldHarm_Amt NUMBER(19,4)
		,PricerCapital_IME_Amt NUMBER(19,4)
		,PricerCapital_HSP_Amt NUMBER(19,4)
		,PricerCapital_FSP_Amt NUMBER(19,4)
		,PricerCapital_Exceptions_Amt NUMBER(19,4)
		,PricerCapital_DSH_Amt NUMBER(19,4)
		,PricerCapitalPayment NUMBER(19,4)
		,PricerDSH NUMBER(19,4)
		,PricerIME NUMBER(19,4)
		,PricerCostOutlier NUMBER(19,4)
		,PricerHSP NUMBER(19,4)
		,PricerFSP NUMBER(19,4)
		,PricerTotalPayment NUMBER(19,4)
		,PricerReturnMsg VARCHAR(255)
		,ReturnDRG VARCHAR(3)
		,ReturnDRGDesc VARCHAR(66)
		,ReturnMDC VARCHAR(3)
		,ReturnMDCDesc VARCHAR(66)
		,ReturnDRGWt FLOAT(24)
		,ReturnDRGALOS FLOAT(24)
		,ReturnADX VARCHAR(8)
		,ReturnSDX VARCHAR(8)
		,ReturnMPR VARCHAR(8)
		,ReturnPR2 VARCHAR(8)
		,ReturnPR3 VARCHAR(8)
		,ReturnNOR VARCHAR(8)
		,ReturnNO2 VARCHAR(8)
		,ReturnCOM VARCHAR(255)
		,ReturnCMI NUMBER(5,0)
		,ReturnDCC VARCHAR(8)
		,ReturnDX1 VARCHAR(8)
		,ReturnDX2 VARCHAR(8)
		,ReturnDX3 VARCHAR(8)
		,ReturnMCI NUMBER(5,0)
		,ReturnOR1 VARCHAR(8)
		,ReturnOR2 VARCHAR(8)
		,ReturnOR3 VARCHAR(8)
		,ReturnTRI NUMBER(5,0)
		,SOJ VARCHAR(2)
		,OPCERT VARCHAR(7)
		,BlendCaseInclMalp FLOAT(24)
		,CapitalCost FLOAT(24)
		,HospBadDebt FLOAT(24)
		,ExcessPhysMalp FLOAT(24)
		,SparcsPerCase FLOAT(24)
		,AltLevelOfCare FLOAT(24)
		,DRGWgt FLOAT(24)
		,TransferCapital FLOAT(24)
		,NYDrgType NUMBER(5,0)
		,LOS NUMBER(5,0)
		,TrimPoint NUMBER(5,0)
		,GroupBlendPercentage FLOAT(24)
		,AdjustmentFactor FLOAT(24)
		,HospLongStayGroupPrice FLOAT(24)
		,TotalDRGCharge NUMBER(19,4)
		,BlendCaseAdj FLOAT(24)
		,CapitalCostAdj FLOAT(24)
		,NonMedicareCaseMix FLOAT(24)
		,HighCostChargeConverter FLOAT(24)
		,DischargeCasePaymentRate NUMBER(19,4)
		,DirectMedicalEducation NUMBER(19,4)
		,CasePaymentCapitalPerDiem NUMBER(19,4)
		,HighCostOutlierThreshold NUMBER(19,4)
		,ISAF FLOAT(24)
		,ReturnSOI NUMBER(5,0)
		,CapitalCostPerDischarge NUMBER(19,4)
		,ReturnSOIDesc VARCHAR(20) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIdNo
		,t.PricerPassThru
		,t.PricerCapital_Outlier_Amt
		,t.PricerCapital_OldHarm_Amt
		,t.PricerCapital_IME_Amt
		,t.PricerCapital_HSP_Amt
		,t.PricerCapital_FSP_Amt
		,t.PricerCapital_Exceptions_Amt
		,t.PricerCapital_DSH_Amt
		,t.PricerCapitalPayment
		,t.PricerDSH
		,t.PricerIME
		,t.PricerCostOutlier
		,t.PricerHSP
		,t.PricerFSP
		,t.PricerTotalPayment
		,t.PricerReturnMsg
		,t.ReturnDRG
		,t.ReturnDRGDesc
		,t.ReturnMDC
		,t.ReturnMDCDesc
		,t.ReturnDRGWt
		,t.ReturnDRGALOS
		,t.ReturnADX
		,t.ReturnSDX
		,t.ReturnMPR
		,t.ReturnPR2
		,t.ReturnPR3
		,t.ReturnNOR
		,t.ReturnNO2
		,t.ReturnCOM
		,t.ReturnCMI
		,t.ReturnDCC
		,t.ReturnDX1
		,t.ReturnDX2
		,t.ReturnDX3
		,t.ReturnMCI
		,t.ReturnOR1
		,t.ReturnOR2
		,t.ReturnOR3
		,t.ReturnTRI
		,t.SOJ
		,t.OPCERT
		,t.BlendCaseInclMalp
		,t.CapitalCost
		,t.HospBadDebt
		,t.ExcessPhysMalp
		,t.SparcsPerCase
		,t.AltLevelOfCare
		,t.DRGWgt
		,t.TransferCapital
		,t.NYDrgType
		,t.LOS
		,t.TrimPoint
		,t.GroupBlendPercentage
		,t.AdjustmentFactor
		,t.HospLongStayGroupPrice
		,t.TotalDRGCharge
		,t.BlendCaseAdj
		,t.CapitalCostAdj
		,t.NonMedicareCaseMix
		,t.HighCostChargeConverter
		,t.DischargeCasePaymentRate
		,t.DirectMedicalEducation
		,t.CasePaymentCapitalPerDiem
		,t.HighCostOutlierThreshold
		,t.ISAF
		,t.ReturnSOI
		,t.CapitalCostPerDischarge
		,t.ReturnSOIDesc
FROM src.BILLS_DRG t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILLS_DRG
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_BILLS_Endnotes(
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
		,BillIDNo NUMBER(10,0)
		,LINE_NO NUMBER(5,0)
		,EndNote NUMBER(5,0)
		,Referral VARCHAR(200)
		,PercentDiscount FLOAT(24)
		,ActionId NUMBER(5,0)
		,EndnoteTypeId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIDNo
		,t.LINE_NO
		,t.EndNote
		,t.Referral
		,t.PercentDiscount
		,t.ActionId
		,t.EndnoteTypeId
FROM src.BILLS_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote,
		EndnoteTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILLS_Endnotes
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote,
		EndnoteTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.LINE_NO = s.LINE_NO
	AND t.EndNote = s.EndNote
	AND t.EndnoteTypeId = s.EndnoteTypeId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Bills_OverrideEndNotes(
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
		,OverrideEndNoteID NUMBER(10,0)
		,BillIdNo NUMBER(10,0)
		,Line_No NUMBER(5,0)
		,OverrideEndNote NUMBER(5,0)
		,PercentDiscount FLOAT(24)
		,ActionId NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.OverrideEndNoteID
		,t.BillIdNo
		,t.Line_No
		,t.OverrideEndNote
		,t.PercentDiscount
		,t.ActionId
FROM src.Bills_OverrideEndNotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OverrideEndNoteID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_OverrideEndNotes
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OverrideEndNoteID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OverrideEndNoteID = s.OverrideEndNoteID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Bills_Pharm(
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
		,BillIdNo NUMBER(10,0)
		,Line_No NUMBER(5,0)
		,LINE_NO_DISP NUMBER(5,0)
		,DateOfService DATETIME
		,NDC VARCHAR(13)
		,PriceTypeCode VARCHAR(2)
		,Units FLOAT(24)
		,Charged NUMBER(19,4)
		,Allowed NUMBER(19,4)
		,EndNote VARCHAR(20)
		,Override NUMBER(5,0)
		,Override_Rsn VARCHAR(10)
		,Analyzed NUMBER(19,4)
		,CTGPenalty NUMBER(19,4)
		,PrePPOAllowed NUMBER(19,4)
		,PPODate DATETIME
		,POS_RevCode VARCHAR(4)
		,DPAllowed NUMBER(19,4)
		,HCRA_Surcharge NUMBER(19,4)
		,EndDateOfService DATETIME
		,RepackagedNdc VARCHAR(13)
		,OriginalNdc VARCHAR(13)
		,UnitOfMeasureId NUMBER(3,0)
		,PackageTypeOriginalNdc VARCHAR(2)
		,PpoCtgPenalty NUMBER(19,4)
		,ServiceCode VARCHAR(25)
		,PreApportionedAmount NUMBER(19,4)
		,DeductibleApplied NUMBER(19,4)
		,BillReviewResults NUMBER(19,4)
		,PreOverriddenDeductible NUMBER(19,4)
		,RemainingBalance NUMBER(19,4) 
		,CtgCoPayPenalty NUMBER(19,4) 
	    ,PpoCtgCoPayPenaltyPercentage NUMBER(19,4) 
	    ,CtgVunPenalty NUMBER(19,4) 
	    ,PpoCtgVunPenaltyPercentage NUMBER(19,4)
		,RenderingNpi VARCHAR(15) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIdNo
		,t.Line_No
		,t.LINE_NO_DISP
		,t.DateOfService
		,t.NDC
		,t.PriceTypeCode
		,t.Units
		,t.Charged
		,t.Allowed
		,t.EndNote
		,t.Override
		,t.Override_Rsn
		,t.Analyzed
		,t.CTGPenalty
		,t.PrePPOAllowed
		,t.PPODate
		,t.POS_RevCode
		,t.DPAllowed
		,t.HCRA_Surcharge
		,t.EndDateOfService
		,t.RepackagedNdc
		,t.OriginalNdc
		,t.UnitOfMeasureId
		,t.PackageTypeOriginalNdc
		,t.PpoCtgPenalty
		,t.ServiceCode
		,t.PreApportionedAmount
		,t.DeductibleApplied
		,t.BillReviewResults
		,t.PreOverriddenDeductible
		,t.RemainingBalance
		,t.CtgCoPayPenalty 
		,t.PpoCtgCoPayPenaltyPercentage 
		,t.CtgVunPenalty
		,t.PpoCtgVunPenaltyPercentage
		,t.RenderingNpi
FROM src.Bills_Pharm t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Line_No,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Pharm
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		Line_No) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.Line_No = s.Line_No
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Bills_Pharm_CTG_Endnotes(
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
		,BillIDNo NUMBER(10,0)
		,LINE_NO NUMBER(5,0)
		,EndNote NUMBER(5,0)
		,RuleType VARCHAR(2)
		,RuleId NUMBER(10,0)
		,PreCertAction NUMBER(5,0)
		,PercentDiscount FLOAT(24)
		,ActionId NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIDNo
		,t.LINE_NO
		,t.EndNote
		,t.RuleType
		,t.RuleId
		,t.PreCertAction
		,t.PercentDiscount
		,t.ActionId
FROM src.Bills_Pharm_CTG_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Pharm_CTG_Endnotes
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.LINE_NO = s.LINE_NO
	AND t.EndNote = s.EndNote
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Bills_Pharm_Endnotes(
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
		,BillIDNo NUMBER(10,0)
		,LINE_NO NUMBER(5,0)
		,EndNote NUMBER(5,0)
		,Referral VARCHAR(200)
		,PercentDiscount FLOAT(24)
		,ActionId NUMBER(5,0)
		,EndnoteTypeId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIDNo
		,t.LINE_NO
		,t.EndNote
		,t.Referral
		,t.PercentDiscount
		,t.ActionId
		,t.EndnoteTypeId
FROM src.Bills_Pharm_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote,
		EndnoteTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Pharm_Endnotes
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote,
		EndnoteTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.LINE_NO = s.LINE_NO
	AND t.EndNote = s.EndNote
	AND t.EndnoteTypeId = s.EndnoteTypeId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Bills_Pharm_OverrideEndNotes(
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
		,OverrideEndNoteID NUMBER(10,0)
		,BillIdNo NUMBER(10,0)
		,Line_No NUMBER(5,0)
		,OverrideEndNote NUMBER(5,0)
		,PercentDiscount FLOAT(24)
		,ActionId NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.OverrideEndNoteID
		,t.BillIdNo
		,t.Line_No
		,t.OverrideEndNote
		,t.PercentDiscount
		,t.ActionId
FROM src.Bills_Pharm_OverrideEndNotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OverrideEndNoteID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Pharm_OverrideEndNotes
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OverrideEndNoteID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OverrideEndNoteID = s.OverrideEndNoteID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Bills_Tax(
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
		,BillsTaxId NUMBER(10,0)
		,TableType NUMBER(5,0)
		,BillIdNo NUMBER(10,0)
		,Line_No NUMBER(5,0)
		,SeqNo NUMBER(5,0)
		,TaxTypeId NUMBER(5,0)
		,ImportTaxRate NUMBER(5,5)
		,Tax NUMBER(19,4)
		,OverridenTax NUMBER(19,4)
		,ImportTaxAmount NUMBER(19,4) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillsTaxId
		,t.TableType
		,t.BillIdNo
		,t.Line_No
		,t.SeqNo
		,t.TaxTypeId
		,t.ImportTaxRate
		,t.Tax
		,t.OverridenTax
		,t.ImportTaxAmount
FROM src.Bills_Tax t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillsTaxId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Tax
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillsTaxId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillsTaxId = s.BillsTaxId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_BILL_HDR(
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
		,BillIDNo NUMBER(10,0)
		,CMT_HDR_IDNo NUMBER(10,0)
		,DateSaved DATETIME
		,DateRcv DATETIME
		,InvoiceNumber VARCHAR(40)
		,InvoiceDate DATETIME
		,FileNumber VARCHAR(50)
		,Note VARCHAR(20)
		,NoLines NUMBER(5,0)
		,AmtCharged NUMBER(19,4)
		,AmtAllowed NUMBER(19,4)
		,ReasonVersion NUMBER(5,0)
		,Region VARCHAR(50)
		,PvdUpdateCounter NUMBER(5,0)
		,FeatureID NUMBER(10,0)
		,ClaimDateLoss DATETIME
		,CV_Type VARCHAR(2)
		,Flags NUMBER(10,0)
		,WhoCreate VARCHAR(15)
		,WhoLast VARCHAR(15)
		,AcceptAssignment NUMBER(5,0)
		,EmergencyService NUMBER(5,0)
		,CmtPaidDeductible NUMBER(19,4)
		,InsPaidLimit NUMBER(19,4)
		,StatusFlag VARCHAR(2)
		,OfficeId NUMBER(10,0)
		,CmtPaidCoPay NUMBER(19,4)
		,AmbulanceMethod NUMBER(5,0)
		,StatusDate DATETIME
		,Category NUMBER(10,0)
		,CatDesc VARCHAR(1000)
		,AssignedUser VARCHAR(15)
		,CreateDate DATETIME
		,PvdZOS VARCHAR(12)
		,PPONumberSent NUMBER(5,0)
		,AdmissionDate DATETIME
		,DischargeDate DATETIME
		,DischargeStatus NUMBER(5,0)
		,TypeOfBill VARCHAR(4)
		,SentryMessage VARCHAR(1000)
		,AmbulanceZipOfPickup VARCHAR(12)
		,AmbulanceNumberOfPatients NUMBER(5,0)
		,WhoCreateID NUMBER(10,0)
		,WhoLastId NUMBER(10,0)
		,NYRequestDate DATETIME
		,NYReceivedDate DATETIME
		,ImgDocId VARCHAR(50)
		,PaymentDecision NUMBER(5,0)
		,PvdCMSId VARCHAR(6)
		,PvdNPINo VARCHAR(15)
		,DischargeHour VARCHAR(2)
		,PreCertChanged NUMBER(5,0)
		,DueDate DATETIME
		,AttorneyIDNo NUMBER(10,0)
		,AssignedGroup NUMBER(10,0)
		,LastChangedOn DATETIME
		,PrePPOAllowed NUMBER(19,4)
		,PPSCode NUMBER(5,0)
		,SOI NUMBER(5,0)
		,StatementStartDate DATETIME
		,StatementEndDate DATETIME
		,DeductibleOverride BOOLEAN
		,AdmissionType NUMBER(3,0)
		,CoverageType VARCHAR(2)
		,PricingProfileId NUMBER(10,0)
		,DesignatedPricingState VARCHAR(2)
		,DateAnalyzed DATETIME
		,SentToPpoSysId NUMBER(10,0)
		,PricingState VARCHAR(2)
		,BillVpnEligible BOOLEAN
		,ApportionmentPercentage NUMBER(5,2)
		,BillSourceId NUMBER(3,0)
		,OutOfStateProviderNumber NUMBER(10,0)
		,FloridaDeductibleRuleEligible BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIDNo
		,t.CMT_HDR_IDNo
		,t.DateSaved
		,t.DateRcv
		,t.InvoiceNumber
		,t.InvoiceDate
		,t.FileNumber
		,t.Note
		,t.NoLines
		,t.AmtCharged
		,t.AmtAllowed
		,t.ReasonVersion
		,t.Region
		,t.PvdUpdateCounter
		,t.FeatureID
		,t.ClaimDateLoss
		,t.CV_Type
		,t.Flags
		,t.WhoCreate
		,t.WhoLast
		,t.AcceptAssignment
		,t.EmergencyService
		,t.CmtPaidDeductible
		,t.InsPaidLimit
		,t.StatusFlag
		,t.OfficeId
		,t.CmtPaidCoPay
		,t.AmbulanceMethod
		,t.StatusDate
		,t.Category
		,t.CatDesc
		,t.AssignedUser
		,t.CreateDate
		,t.PvdZOS
		,t.PPONumberSent
		,t.AdmissionDate
		,t.DischargeDate
		,t.DischargeStatus
		,t.TypeOfBill
		,t.SentryMessage
		,t.AmbulanceZipOfPickup
		,t.AmbulanceNumberOfPatients
		,t.WhoCreateID
		,t.WhoLastId
		,t.NYRequestDate
		,t.NYReceivedDate
		,t.ImgDocId
		,t.PaymentDecision
		,t.PvdCMSId
		,t.PvdNPINo
		,t.DischargeHour
		,t.PreCertChanged
		,t.DueDate
		,t.AttorneyIDNo
		,t.AssignedGroup
		,t.LastChangedOn
		,t.PrePPOAllowed
		,t.PPSCode
		,t.SOI
		,t.StatementStartDate
		,t.StatementEndDate
		,t.DeductibleOverride
		,t.AdmissionType
		,t.CoverageType
		,t.PricingProfileId
		,t.DesignatedPricingState
		,t.DateAnalyzed
		,t.SentToPpoSysId
		,t.PricingState
		,t.BillVpnEligible
		,t.ApportionmentPercentage
		,t.BillSourceId
		,t.OutOfStateProviderNumber
		,t.FloridaDeductibleRuleEligible
FROM src.BILL_HDR t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILL_HDR
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Bill_History(
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
		,BillIdNo NUMBER(10,0)
		,SeqNo NUMBER(10,0)
		,DateCommitted DATETIME
		,AmtCommitted NUMBER(19,4)
		,UserId VARCHAR(15)
		,AmtCoPay NUMBER(19,4)
		,AmtDeductible NUMBER(19,4)
		,Flags NUMBER(10,0)
		,AmtSalesTax NUMBER(19,4)
		,AmtOtherTax NUMBER(19,4)
		,DeductibleOverride BOOLEAN
		,PricingState VARCHAR(2)
		,ApportionmentPercentage NUMBER(5,2)
		,FloridaDeductibleRuleEligible BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIdNo
		,t.SeqNo
		,t.DateCommitted
		,t.AmtCommitted
		,t.UserId
		,t.AmtCoPay
		,t.AmtDeductible
		,t.Flags
		,t.AmtSalesTax
		,t.AmtOtherTax
		,t.DeductibleOverride
		,t.PricingState
		,t.ApportionmentPercentage
		,t.FloridaDeductibleRuleEligible
FROM src.Bill_History t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		SeqNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill_History
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		SeqNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.SeqNo = s.SeqNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Bill_Payment_Adjustments(
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
		,Bill_Payment_Adjustment_ID NUMBER(10,0)
		,BillIDNo NUMBER(10,0)
		,SeqNo NUMBER(5,0)
		,InterestFlags NUMBER(10,0)
		,DateInterestStarts DATETIME
		,DateInterestEnds DATETIME
		,InterestAdditionalInfoReceived DATETIME
		,Interest NUMBER(19,4)
		,Comments VARCHAR(1000) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.Bill_Payment_Adjustment_ID
		,t.BillIDNo
		,t.SeqNo
		,t.InterestFlags
		,t.DateInterestStarts
		,t.DateInterestEnds
		,t.InterestAdditionalInfoReceived
		,t.Interest
		,t.Comments
FROM src.Bill_Payment_Adjustments t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Bill_Payment_Adjustment_ID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill_Payment_Adjustments
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Bill_Payment_Adjustment_ID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Bill_Payment_Adjustment_ID = s.Bill_Payment_Adjustment_ID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Bill_Pharm_ApportionmentEndnote(
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
		,BillId NUMBER(10,0)
		,LineNumber NUMBER(5,0)
		,Endnote NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillId
		,t.LineNumber
		,t.Endnote
FROM src.Bill_Pharm_ApportionmentEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillId,
		LineNumber,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill_Pharm_ApportionmentEndnote
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillId,
		LineNumber,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillId = s.BillId
	AND t.LineNumber = s.LineNumber
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Bill_Sentry_Endnote(
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
		,BillID NUMBER(10,0)
		,Line NUMBER(10,0)
		,RuleID NUMBER(10,0)
		,PercentDiscount FLOAT(24)
		,ActionId NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillID
		,t.Line
		,t.RuleID
		,t.PercentDiscount
		,t.ActionId
FROM src.Bill_Sentry_Endnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillID,
		Line,
		RuleID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill_Sentry_Endnote
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillID,
		Line,
		RuleID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillID = s.BillID
	AND t.Line = s.Line
	AND t.RuleID = s.RuleID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_BIReportAdjustmentCategory(
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
		,BIReportAdjustmentCategoryId NUMBER(10,0)
		,Name VARCHAR(50)
		,Description VARCHAR(500)
		,DisplayPriority NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BIReportAdjustmentCategoryId
		,t.Name
		,t.Description
		,t.DisplayPriority
FROM src.BIReportAdjustmentCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BIReportAdjustmentCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BIReportAdjustmentCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BIReportAdjustmentCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BIReportAdjustmentCategoryId = s.BIReportAdjustmentCategoryId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_BIReportAdjustmentCategoryMapping(
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
		,BIReportAdjustmentCategoryId NUMBER(10,0)
		,Adjustment360SubCategoryId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BIReportAdjustmentCategoryId
		,t.Adjustment360SubCategoryId
FROM src.BIReportAdjustmentCategoryMapping t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BIReportAdjustmentCategoryId,
		Adjustment360SubCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BIReportAdjustmentCategoryMapping
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BIReportAdjustmentCategoryId,
		Adjustment360SubCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BIReportAdjustmentCategoryId = s.BIReportAdjustmentCategoryId
	AND t.Adjustment360SubCategoryId = s.Adjustment360SubCategoryId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Bitmasks(
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
		,TableProgramUsed VARCHAR(50)
		,AttributeUsed VARCHAR(50)
		,Decimal NUMBER(19,0)
		,ConstantName VARCHAR(50)
		,Bit VARCHAR(50)
		,Hex VARCHAR(20)
		,Description VARCHAR(250) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.TableProgramUsed
		,t.AttributeUsed
		,t.Decimal
		,t.ConstantName
		,t.Bit
		,t.Hex
		,t.Description
FROM src.Bitmasks t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TableProgramUsed,
		AttributeUsed,
		Decimal,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bitmasks
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TableProgramUsed,
		AttributeUsed,
		Decimal) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TableProgramUsed = s.TableProgramUsed
	AND t.AttributeUsed = s.AttributeUsed
	AND t.Decimal = s.Decimal
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_CBRETODPENDNOTEMAPPING(
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
		,ENDNOTE NUMBER(10,0)
		,ENDNOTETYPEID NUMBER(3,0)
		,CBREENDNOTE NUMBER(5,0)
		,PRICINGSTATE VARCHAR(2)
		,PRICINGMETHODID NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ENDNOTE
		,t.ENDNOTETYPEID
		,t.CBREENDNOTE
		,t.PRICINGSTATE
		,t.PRICINGMETHODID
FROM src.CBRETODPENDNOTEMAPPING t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ENDNOTE,ENDNOTETYPEID,CBREENDNOTE,PRICINGSTATE,PRICINGMETHODID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CBRETODPENDNOTEMAPPING
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ENDNOTE,ENDNOTETYPEID,CBREENDNOTE,PRICINGSTATE,PRICINGMETHODID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ENDNOTE = s.ENDNOTE
	AND t.ENDNOTETYPEID = s.ENDNOTETYPEID
	AND t.CBREENDNOTE = s.CBREENDNOTE
	AND t.PRICINGSTATE = s.PRICINGSTATE
	AND t.PRICINGMETHODID = s.PRICINGMETHODID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_CLAIMANT(
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
		,CmtIDNo NUMBER(10,0)
		,ClaimIDNo NUMBER(10,0)
		,CmtSSN VARCHAR(11)
		,CmtLastName VARCHAR(60)
		,CmtFirstName VARCHAR(35)
		,CmtMI VARCHAR(1)
		,CmtDOB DATETIME
		,CmtSEX VARCHAR(1)
		,CmtAddr1 VARCHAR(55)
		,CmtAddr2 VARCHAR(55)
		,CmtCity VARCHAR(30)
		,CmtState VARCHAR(2)
		,CmtZip VARCHAR(12)
		,CmtPhone VARCHAR(25)
		,CmtOccNo VARCHAR(11)
		,CmtAttorneyNo NUMBER(10,0)
		,CmtPolicyLimit NUMBER(19,4)
		,CmtStateOfJurisdiction VARCHAR(2)
		,CmtDeductible NUMBER(19,4)
		,CmtCoPaymentPercentage NUMBER(5,0)
		,CmtCoPaymentMax NUMBER(19,4)
		,CmtPPO_Eligible NUMBER(5,0)
		,CmtCoordBenefits NUMBER(5,0)
		,CmtFLCopay NUMBER(5,0)
		,CmtCOAExport DATETIME
		,CmtPGFirstName VARCHAR(30)
		,CmtPGLastName VARCHAR(30)
		,CmtDedType NUMBER(5,0)
		,ExportToClaimIQ NUMBER(5,0)
		,CmtInactive NUMBER(5,0)
		,CmtPreCertOption NUMBER(5,0)
		,CmtPreCertState VARCHAR(2)
		,CreateDate DATETIME
		,LastChangedOn DATETIME
		,OdsParticipant BOOLEAN
		,CoverageType VARCHAR(2)
		,DoNotDisplayCoverageTypeOnEOB BOOLEAN
		,ShowAllocationsOnEob BOOLEAN
		,SetPreAllocation BOOLEAN
		,PharmacyEligible NUMBER(3,0)
		,SendCardToClaimant NUMBER(3,0)
		,ShareCoPayMaximum BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CmtIDNo
		,t.ClaimIDNo
		,t.CmtSSN
		,t.CmtLastName
		,t.CmtFirstName
		,t.CmtMI
		,t.CmtDOB
		,t.CmtSEX
		,t.CmtAddr1
		,t.CmtAddr2
		,t.CmtCity
		,t.CmtState
		,t.CmtZip
		,t.CmtPhone
		,t.CmtOccNo
		,t.CmtAttorneyNo
		,t.CmtPolicyLimit
		,t.CmtStateOfJurisdiction
		,t.CmtDeductible
		,t.CmtCoPaymentPercentage
		,t.CmtCoPaymentMax
		,t.CmtPPO_Eligible
		,t.CmtCoordBenefits
		,t.CmtFLCopay
		,t.CmtCOAExport
		,t.CmtPGFirstName
		,t.CmtPGLastName
		,t.CmtDedType
		,t.ExportToClaimIQ
		,t.CmtInactive
		,t.CmtPreCertOption
		,t.CmtPreCertState
		,t.CreateDate
		,t.LastChangedOn
		,t.OdsParticipant
		,t.CoverageType
		,t.DoNotDisplayCoverageTypeOnEOB
		,t.ShowAllocationsOnEob
		,t.SetPreAllocation
		,t.PharmacyEligible
		,t.SendCardToClaimant
		,t.ShareCoPayMaximum
FROM src.CLAIMANT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CmtIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CLAIMANT
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CmtIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CmtIDNo = s.CmtIDNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Claimant_ClientRef(
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
		,CmtIdNo NUMBER(10,0)
		,CmtSuffix VARCHAR(50)
		,ClaimIdNo NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CmtIdNo
		,t.CmtSuffix
		,t.ClaimIdNo
FROM src.Claimant_ClientRef t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CmtIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Claimant_ClientRef
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CmtIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CmtIdNo = s.CmtIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_CLAIMS(
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
		,ClaimIDNo NUMBER(10,0)
		,ClaimNo VARCHAR
		,DateLoss DATETIME
		,CV_Code VARCHAR(2)
		,DiaryIndex NUMBER(10,0)
		,LastSaved DATETIME
		,PolicyNumber VARCHAR(50)
		,PolicyHoldersName VARCHAR(30)
		,PaidDeductible NUMBER(19,4)
		,Status VARCHAR(1)
		,InUse VARCHAR(100)
		,CompanyID NUMBER(10,0)
		,OfficeIndex NUMBER(10,0)
		,AdjIdNo NUMBER(10,0)
		,PaidCoPay NUMBER(19,4)
		,AssignedUser VARCHAR(15)
		,Privatized NUMBER(5,0)
		,PolicyEffDate DATETIME
		,Deductible NUMBER(19,4)
		,LossState VARCHAR(2)
		,AssignedGroup NUMBER(10,0)
		,CreateDate DATETIME
		,LastChangedOn DATETIME
		,AllowMultiCoverage BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ClaimIDNo
		,t.ClaimNo
		,t.DateLoss
		,t.CV_Code
		,t.DiaryIndex
		,t.LastSaved
		,t.PolicyNumber
		,t.PolicyHoldersName
		,t.PaidDeductible
		,t.Status
		,t.InUse
		,t.CompanyID
		,t.OfficeIndex
		,t.AdjIdNo
		,t.PaidCoPay
		,t.AssignedUser
		,t.Privatized
		,t.PolicyEffDate
		,t.Deductible
		,t.LossState
		,t.AssignedGroup
		,t.CreateDate
		,t.LastChangedOn
		,t.AllowMultiCoverage
FROM src.CLAIMS t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CLAIMS
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimIDNo = s.ClaimIDNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Claims_ClientRef(
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
		,ClaimIdNo NUMBER(10,0)
		,ClientRefId VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ClaimIdNo
		,t.ClientRefId
FROM src.Claims_ClientRef t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Claims_ClientRef
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimIdNo = s.ClaimIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_CMS_Zip2Region(
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
		,StartDate DATETIME
		,EndDate DATETIME
		,ZIP_Code VARCHAR(5)
		,State VARCHAR(2)
		,Region VARCHAR(2)
		,AmbRegion VARCHAR(2)
		,RuralFlag NUMBER(5,0)
		,ASCRegion NUMBER(5,0)
		,PlusFour NUMBER(5,0)
		,CarrierId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StartDate
		,t.EndDate
		,t.ZIP_Code
		,t.State
		,t.Region
		,t.AmbRegion
		,t.RuralFlag
		,t.ASCRegion
		,t.PlusFour
		,t.CarrierId
FROM src.CMS_Zip2Region t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StartDate,
		ZIP_Code,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMS_Zip2Region
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StartDate,
		ZIP_Code) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StartDate = s.StartDate
	AND t.ZIP_Code = s.ZIP_Code
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_CMT_DX(
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
		,BillIDNo NUMBER(10,0)
		,DX VARCHAR(8)
		,SeqNum NUMBER(5,0)
		,POA VARCHAR(1)
		,IcdVersion NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIDNo
		,t.DX
		,t.SeqNum
		,t.POA
		,t.IcdVersion
FROM src.CMT_DX t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		DX,
		IcdVersion,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMT_DX
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		DX,
		IcdVersion) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.DX = s.DX
	AND t.IcdVersion = s.IcdVersion
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_CMT_HDR(
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
		,CMT_HDR_IDNo NUMBER(10,0)
		,CmtIDNo NUMBER(10,0)
		,PvdIDNo NUMBER(10,0)
		,LastChangedOn DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CMT_HDR_IDNo
		,t.CmtIDNo
		,t.PvdIDNo
		,t.LastChangedOn
FROM src.CMT_HDR t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CMT_HDR_IDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMT_HDR
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CMT_HDR_IDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CMT_HDR_IDNo = s.CMT_HDR_IDNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_CMT_ICD9(
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
		,BillIDNo NUMBER(10,0)
		,SeqNo NUMBER(5,0)
		,ICD9 VARCHAR(7)
		,IcdVersion NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIDNo
		,t.SeqNo
		,t.ICD9
		,t.IcdVersion
FROM src.CMT_ICD9 t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		SeqNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMT_ICD9
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		SeqNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.SeqNo = s.SeqNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_CoverageType(
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
		,LongName VARCHAR(30)
		,ShortName VARCHAR(2)
		,CbreCoverageTypeCode VARCHAR(2)
		,CoverageTypeCategoryCode VARCHAR(4)
		,PricingMethodId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.LongName
		,t.ShortName
		,t.CbreCoverageTypeCode
		,t.CoverageTypeCategoryCode
		,t.PricingMethodId
FROM src.CoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ShortName,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CoverageType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ShortName) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ShortName = s.ShortName
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_cpt_DX_DICT(
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
		,ICD9 VARCHAR(6)
		,StartDate DATETIME
		,EndDate DATETIME
		,Flags NUMBER(5,0)
		,NonSpecific VARCHAR(1)
		,AdditionalDigits VARCHAR(1)
		,Traumatic VARCHAR(1)
		,DX_DESC VARCHAR
		,Duration NUMBER(5,0)
		,Colossus NUMBER(5,0)
		,DiagnosisFamilyId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ICD9
		,t.StartDate
		,t.EndDate
		,t.Flags
		,t.NonSpecific
		,t.AdditionalDigits
		,t.Traumatic
		,t.DX_DESC
		,t.Duration
		,t.Colossus
		,t.DiagnosisFamilyId
FROM src.cpt_DX_DICT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ICD9,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.cpt_DX_DICT
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ICD9,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ICD9 = s.ICD9
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_cpt_PRC_DICT(
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
		,PRC_CD VARCHAR(7)
		,StartDate DATETIME
		,EndDate DATETIME
		,PRC_DESC VARCHAR
		,Flags NUMBER(10,0)
		,Vague VARCHAR(1)
		,PerVisit NUMBER(5,0)
		,PerClaimant NUMBER(5,0)
		,PerProvider NUMBER(5,0)
		,BodyFlags NUMBER(10,0)
		,Colossus NUMBER(5,0)
		,CMS_Status VARCHAR(1)
		,DrugFlag NUMBER(5,0)
		,CurativeFlag NUMBER(5,0)
		,ExclPolicyLimit NUMBER(5,0)
		,SpecNetFlag NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PRC_CD
		,t.StartDate
		,t.EndDate
		,t.PRC_DESC
		,t.Flags
		,t.Vague
		,t.PerVisit
		,t.PerClaimant
		,t.PerProvider
		,t.BodyFlags
		,t.Colossus
		,t.CMS_Status
		,t.DrugFlag
		,t.CurativeFlag
		,t.ExclPolicyLimit
		,t.SpecNetFlag
FROM src.cpt_PRC_DICT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PRC_CD,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.cpt_PRC_DICT
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PRC_CD,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PRC_CD = s.PRC_CD
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_CreditReason(
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
		,CreditReasonId NUMBER(10,0)
		,CreditReasonDesc VARCHAR(100)
		,IsVisible BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CreditReasonId
		,t.CreditReasonDesc
		,t.IsVisible
FROM src.CreditReason t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CreditReasonId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CreditReason
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CreditReasonId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CreditReasonId = s.CreditReasonId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_CreditReasonOverrideENMap(
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
		,CreditReasonOverrideENMapId NUMBER(10,0)
		,CreditReasonId NUMBER(10,0)
		,OverrideEndnoteId NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CreditReasonOverrideENMapId
		,t.CreditReasonId
		,t.OverrideEndnoteId
FROM src.CreditReasonOverrideENMap t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CreditReasonOverrideENMapId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CreditReasonOverrideENMap
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CreditReasonOverrideENMapId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CreditReasonOverrideENMapId = s.CreditReasonOverrideENMapId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_CriticalAccessHospitalInpatientRevenueCode(
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
		,RevenueCode VARCHAR(4) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RevenueCode
FROM src.CriticalAccessHospitalInpatientRevenueCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CriticalAccessHospitalInpatientRevenueCode
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCode = s.RevenueCode
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_CTG_Endnotes(
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
		,Endnote NUMBER(10,0)
		,ShortDesc VARCHAR(50)
		,LongDesc VARCHAR(500) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.Endnote
		,t.ShortDesc
		,t.LongDesc
FROM src.CTG_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CTG_Endnotes
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_CustomBillStatuses(
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
		,StatusId NUMBER(10,0)
		,StatusName VARCHAR(50)
		,StatusDescription VARCHAR(300) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StatusId
		,t.StatusName
		,t.StatusDescription
FROM src.CustomBillStatuses t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StatusId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CustomBillStatuses
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StatusId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StatusId = s.StatusId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_CustomEndnote(
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
		,CustomEndnote NUMBER(10,0)
		,ShortDescription VARCHAR(50)
		,LongDescription VARCHAR(500) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CustomEndnote
		,t.ShortDescription
		,t.LongDescription
FROM src.CustomEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CustomEndnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CustomEndnote
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CustomEndnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CustomEndnote = s.CustomEndnote
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_CustomerBillExclusion(
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
		,BillIdNo NUMBER(10,0)
		,Customer VARCHAR(50)
		,ReportID NUMBER(3,0)
		,CreateDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIdNo
		,t.Customer
		,t.ReportID
		,t.CreateDate
FROM src.CustomerBillExclusion t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Customer,
		ReportID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CustomerBillExclusion
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		Customer,
		ReportID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.Customer = s.Customer
	AND t.ReportID = s.ReportID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_DeductibleRuleCriteria(
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
		,DeductibleRuleCriteriaId NUMBER(10,0)
		,PricingRuleDateCriteriaId NUMBER(3,0)
		,StartDate DATETIME
		,EndDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DeductibleRuleCriteriaId
		,t.PricingRuleDateCriteriaId
		,t.StartDate
		,t.EndDate
FROM src.DeductibleRuleCriteria t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DeductibleRuleCriteriaId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DeductibleRuleCriteria
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DeductibleRuleCriteriaId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DeductibleRuleCriteriaId = s.DeductibleRuleCriteriaId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_DeductibleRuleCriteriaCoverageType(
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
		,DeductibleRuleCriteriaId NUMBER(10,0)
		,CoverageType VARCHAR(5) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DeductibleRuleCriteriaId
		,t.CoverageType
FROM src.DeductibleRuleCriteriaCoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DeductibleRuleCriteriaId,
		CoverageType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DeductibleRuleCriteriaCoverageType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DeductibleRuleCriteriaId,
		CoverageType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DeductibleRuleCriteriaId = s.DeductibleRuleCriteriaId
	AND t.CoverageType = s.CoverageType
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_DeductibleRuleExemptEndnote(
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
		,Endnote NUMBER(10,0)
		,EndnoteTypeId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.Endnote
		,t.EndnoteTypeId
FROM src.DeductibleRuleExemptEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Endnote,
		EndnoteTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DeductibleRuleExemptEndnote
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Endnote,
		EndnoteTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Endnote = s.Endnote
	AND t.EndnoteTypeId = s.EndnoteTypeId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_DiagnosisCodeGroup(
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
		,DiagnosisCode VARCHAR(8)
		,StartDate DATETIME
		,EndDate DATETIME
		,MajorCategory VARCHAR(500)
		,MinorCategory VARCHAR(500) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DiagnosisCode
		,t.StartDate
		,t.EndDate
		,t.MajorCategory
		,t.MinorCategory
FROM src.DiagnosisCodeGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DiagnosisCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DiagnosisCodeGroup
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DiagnosisCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DiagnosisCode = s.DiagnosisCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_EncounterType(
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
		,EncounterTypeId NUMBER(3,0)
		,EncounterTypePriority NUMBER(3,0)
		,Description VARCHAR(100)
		,NarrativeInformation VARCHAR )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.EncounterTypeId
		,t.EncounterTypePriority
		,t.Description
		,t.NarrativeInformation
FROM src.EncounterType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EncounterTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EncounterType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EncounterTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EncounterTypeId = s.EncounterTypeId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_EndnoteSubCategory(
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
		,EndnoteSubCategoryId NUMBER(3,0)
		,Description VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.EndnoteSubCategoryId
		,t.Description
FROM src.EndnoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EndnoteSubCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EndnoteSubCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EndnoteSubCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EndnoteSubCategoryId = s.EndnoteSubCategoryId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Esp_Ppo_Billing_Data_Self_Bill(
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
		,COMPANYCODE VARCHAR(10)
		,TRANSACTIONTYPE VARCHAR(10)
		,BILL_HDR_AMTALLOWED NUMBER(15,2)
		,BILL_HDR_AMTCHARGED NUMBER(15,2)
		,BILL_HDR_BILLIDNO NUMBER(10,0)
		,BILL_HDR_CMT_HDR_IDNO NUMBER(10,0)
		,BILL_HDR_CREATEDATE DATETIME
		,BILL_HDR_CV_TYPE VARCHAR(5)
		,BILL_HDR_FORM_TYPE VARCHAR(8)
		,BILL_HDR_NOLINES NUMBER(10,0)
		,BILLS_ALLOWED NUMBER(15,2)
		,BILLS_ANALYZED NUMBER(15,2)
		,BILLS_CHARGED NUMBER(15,2)
		,BILLS_DT_SVC DATETIME
		,BILLS_LINE_NO NUMBER(10,0)
		,CLAIMANT_CLIENTREF_CMTSUFFIX VARCHAR(50)
		,CLAIMANT_CMTFIRST_NAME VARCHAR(50)
		,CLAIMANT_CMTIDNO VARCHAR(20)
		,CLAIMANT_CMTLASTNAME VARCHAR(60)
		,CMTSTATEOFJURISDICTION VARCHAR(2)
		,CLAIMS_COMPANYID NUMBER(10,0)
		,CLAIMS_CLAIMNO VARCHAR(50)
		,CLAIMS_DATELOSS DATETIME
		,CLAIMS_OFFICEINDEX NUMBER(10,0)
		,CLAIMS_POLICYHOLDERSNAME VARCHAR(100)
		,CLAIMS_POLICYNUMBER VARCHAR(50)
		,PNETWKEVENTLOG_EVENTID NUMBER(10,0)
		,PNETWKEVENTLOG_LOGDATE DATETIME
		,PNETWKEVENTLOG_NETWORKID NUMBER(10,0)
		,ACTIVITY_FLAG VARCHAR(1)
		,PPO_AMTALLOWED NUMBER(15,2)
		,PREPPO_AMTALLOWED NUMBER(15,2)
		,PREPPO_ALLOWED_FS VARCHAR(1)
		,PRF_COMPANY_COMPANYNAME VARCHAR(50)
		,PRF_OFFICE_OFCNAME VARCHAR(50)
		,PRF_OFFICE_OFCNO VARCHAR(25)
		,PROVIDER_PVDFIRSTNAME VARCHAR(60)
		,PROVIDER_PVDGROUP VARCHAR(60)
		,PROVIDER_PVDLASTNAME VARCHAR(60)
		,PROVIDER_PVDTIN VARCHAR(15)
		,PROVIDER_STATE VARCHAR(5)
		,UDFCLAIM_UDFVALUETEXT VARCHAR(255)
		,ENTRY_DATE DATETIME
		,UDFCLAIMANT_UDFVALUETEXT VARCHAR(255)
		,SOURCE_DB VARCHAR(20)
		,CLAIMS_CV_CODE VARCHAR(5)
		,VPN_TRANSACTIONID NUMBER(19,0)
		,VPN_TRANSACTIONTYPEID NUMBER(10,0)
		,VPN_BILLIDNO NUMBER(10,0)
		,VPN_LINE_NO NUMBER(5,0)
		,VPN_CHARGED NUMBER(19,4)
		,VPN_DPALLOWED NUMBER(19,4)
		,VPN_VPNALLOWED NUMBER(19,4)
		,VPN_SAVINGS NUMBER(19,4)
		,VPN_CREDITS NUMBER(19,4)
		,VPN_HASOVERRIDE BOOLEAN
		,VPN_ENDNOTES VARCHAR(200)
		,VPN_NETWORKIDNO NUMBER(10,0)
		,VPN_PROCESSFLAG NUMBER(5,0)
		,VPN_LINETYPE NUMBER(10,0)
		,VPN_DATETIMESTAMP DATETIME
		,VPN_SEQNO NUMBER(10,0)
		,VPN_VPN_REF_LINE_NO NUMBER(5,0)
		,VPN_NETWORKNAME VARCHAR(50)
		,VPN_SOJ VARCHAR(2)
		,VPN_CAT3 NUMBER(10,0)
		,VPN_PPODATESTAMP DATETIME
		,VPN_NINTEYDAYS NUMBER(10,0)
		,VPN_BILL_TYPE VARCHAR(1)
		,VPN_NET_SAVINGS NUMBER(19,4)
		,CREDIT BOOLEAN
		,RECON BOOLEAN
		,DELETED BOOLEAN
		,STATUS_FLAG VARCHAR(2)
		,DATE_SAVED DATETIME
		,SUB_NETWORK VARCHAR(50)
		,INVALID_CREDIT BOOLEAN
		,PROVIDER_SPECIALTY VARCHAR(50)
		,ADJUSTOR_IDNUMBER VARCHAR(25)
		,ACP_FLAG VARCHAR(1)
		,OVERRIDE_ENDNOTES VARCHAR
		,OVERRIDE_ENDNOTES_DESC VARCHAR )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.COMPANYCODE
		,t.TRANSACTIONTYPE
		,t.BILL_HDR_AMTALLOWED
		,t.BILL_HDR_AMTCHARGED
		,t.BILL_HDR_BILLIDNO
		,t.BILL_HDR_CMT_HDR_IDNO
		,t.BILL_HDR_CREATEDATE
		,t.BILL_HDR_CV_TYPE
		,t.BILL_HDR_FORM_TYPE
		,t.BILL_HDR_NOLINES
		,t.BILLS_ALLOWED
		,t.BILLS_ANALYZED
		,t.BILLS_CHARGED
		,t.BILLS_DT_SVC
		,t.BILLS_LINE_NO
		,t.CLAIMANT_CLIENTREF_CMTSUFFIX
		,t.CLAIMANT_CMTFIRST_NAME
		,t.CLAIMANT_CMTIDNO
		,t.CLAIMANT_CMTLASTNAME
		,t.CMTSTATEOFJURISDICTION
		,t.CLAIMS_COMPANYID
		,t.CLAIMS_CLAIMNO
		,t.CLAIMS_DATELOSS
		,t.CLAIMS_OFFICEINDEX
		,t.CLAIMS_POLICYHOLDERSNAME
		,t.CLAIMS_POLICYNUMBER
		,t.PNETWKEVENTLOG_EVENTID
		,t.PNETWKEVENTLOG_LOGDATE
		,t.PNETWKEVENTLOG_NETWORKID
		,t.ACTIVITY_FLAG
		,t.PPO_AMTALLOWED
		,t.PREPPO_AMTALLOWED
		,t.PREPPO_ALLOWED_FS
		,t.PRF_COMPANY_COMPANYNAME
		,t.PRF_OFFICE_OFCNAME
		,t.PRF_OFFICE_OFCNO
		,t.PROVIDER_PVDFIRSTNAME
		,t.PROVIDER_PVDGROUP
		,t.PROVIDER_PVDLASTNAME
		,t.PROVIDER_PVDTIN
		,t.PROVIDER_STATE
		,t.UDFCLAIM_UDFVALUETEXT
		,t.ENTRY_DATE
		,t.UDFCLAIMANT_UDFVALUETEXT
		,t.SOURCE_DB
		,t.CLAIMS_CV_CODE
		,t.VPN_TRANSACTIONID
		,t.VPN_TRANSACTIONTYPEID
		,t.VPN_BILLIDNO
		,t.VPN_LINE_NO
		,t.VPN_CHARGED
		,t.VPN_DPALLOWED
		,t.VPN_VPNALLOWED
		,t.VPN_SAVINGS
		,t.VPN_CREDITS
		,t.VPN_HASOVERRIDE
		,t.VPN_ENDNOTES
		,t.VPN_NETWORKIDNO
		,t.VPN_PROCESSFLAG
		,t.VPN_LINETYPE
		,t.VPN_DATETIMESTAMP
		,t.VPN_SEQNO
		,t.VPN_VPN_REF_LINE_NO
		,t.VPN_NETWORKNAME
		,t.VPN_SOJ
		,t.VPN_CAT3
		,t.VPN_PPODATESTAMP
		,t.VPN_NINTEYDAYS
		,t.VPN_BILL_TYPE
		,t.VPN_NET_SAVINGS
		,t.CREDIT
		,t.RECON
		,t.DELETED
		,t.STATUS_FLAG
		,t.DATE_SAVED
		,t.SUB_NETWORK
		,t.INVALID_CREDIT
		,t.PROVIDER_SPECIALTY
		,t.ADJUSTOR_IDNUMBER
		,t.ACP_FLAG
		,t.OVERRIDE_ENDNOTES
		,t.OVERRIDE_ENDNOTES_DESC
FROM src.Esp_Ppo_Billing_Data_Self_Bill t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VPN_TRANSACTIONID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Esp_Ppo_Billing_Data_Self_Bill
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VPN_TRANSACTIONID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VPN_TRANSACTIONID = s.VPN_TRANSACTIONID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ExtractCat(
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
		,CatIdNo NUMBER(10,0)
		,Description VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CatIdNo
		,t.Description
FROM src.ExtractCat t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CatIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ExtractCat
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CatIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CatIdNo = s.CatIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_GeneralInterestRuleBaseType(
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
		,GeneralInterestRuleBaseTypeId NUMBER(3,0)
		,GeneralInterestRuleBaseTypeName VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.GeneralInterestRuleBaseTypeId
		,t.GeneralInterestRuleBaseTypeName
FROM src.GeneralInterestRuleBaseType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		GeneralInterestRuleBaseTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.GeneralInterestRuleBaseType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		GeneralInterestRuleBaseTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.GeneralInterestRuleBaseTypeId = s.GeneralInterestRuleBaseTypeId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_GeneralInterestRuleSetting(
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
		,GeneralInterestRuleBaseTypeId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.GeneralInterestRuleBaseTypeId
FROM src.GeneralInterestRuleSetting t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		GeneralInterestRuleBaseTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.GeneralInterestRuleSetting
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		GeneralInterestRuleBaseTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.GeneralInterestRuleBaseTypeId = s.GeneralInterestRuleBaseTypeId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Icd10DiagnosisVersion(
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
		,DiagnosisCode VARCHAR(8)
		,StartDate DATETIME
		,EndDate DATETIME
		,NonSpecific BOOLEAN
		,Traumatic BOOLEAN
		,Duration NUMBER(5,0)
		,Description VARCHAR
		,DiagnosisFamilyId NUMBER(3,0)
		,TotalCharactersRequired NUMBER(3,0)
		,PlaceholderRequired BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DiagnosisCode
		,t.StartDate
		,t.EndDate
		,t.NonSpecific
		,t.Traumatic
		,t.Duration
		,t.Description
		,t.DiagnosisFamilyId
		,t.TotalCharactersRequired
		,t.PlaceholderRequired
FROM src.Icd10DiagnosisVersion t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DiagnosisCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Icd10DiagnosisVersion
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DiagnosisCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DiagnosisCode = s.DiagnosisCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ICD10ProcedureCode(
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
		,ICDProcedureCode VARCHAR(7)
		,StartDate DATETIME
		,EndDate DATETIME
		,Description VARCHAR(300)
		,PASGrpNo NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ICDProcedureCode
		,t.StartDate
		,t.EndDate
		,t.Description
		,t.PASGrpNo
FROM src.ICD10ProcedureCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ICDProcedureCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ICD10ProcedureCode
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ICDProcedureCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ICDProcedureCode = s.ICDProcedureCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_IcdDiagnosisCodeDictionary(
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
		,DiagnosisCode VARCHAR(8)
		,IcdVersion NUMBER(3,0)
		,StartDate DATETIME
		,EndDate DATETIME
		,NonSpecific BOOLEAN
		,Traumatic BOOLEAN
		,Duration NUMBER(3,0)
		,Description VARCHAR
		,DiagnosisFamilyId NUMBER(3,0)
		,DiagnosisSeverityId NUMBER(3,0)
		,LateralityId NUMBER(3,0)
		,TotalCharactersRequired NUMBER(3,0)
		,PlaceholderRequired BOOLEAN
		,Flags NUMBER(5,0)
		,AdditionalDigits BOOLEAN
		,Colossus NUMBER(5,0)
		,InjuryNatureId NUMBER(3,0)
		,EncounterSubcategoryId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DiagnosisCode
		,t.IcdVersion
		,t.StartDate
		,t.EndDate
		,t.NonSpecific
		,t.Traumatic
		,t.Duration
		,t.Description
		,t.DiagnosisFamilyId
		,t.DiagnosisSeverityId
		,t.LateralityId
		,t.TotalCharactersRequired
		,t.PlaceholderRequired
		,t.Flags
		,t.AdditionalDigits
		,t.Colossus
		,t.InjuryNatureId
		,t.EncounterSubcategoryId
FROM src.IcdDiagnosisCodeDictionary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.IcdDiagnosisCodeDictionary
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DiagnosisCode = s.DiagnosisCode
	AND t.IcdVersion = s.IcdVersion
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_IcdDiagnosisCodeDictionaryBodyPart(
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
		,DiagnosisCode VARCHAR(8)
		,IcdVersion NUMBER(3,0)
		,StartDate DATETIME
		,NcciBodyPartId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DiagnosisCode
		,t.IcdVersion
		,t.StartDate
		,t.NcciBodyPartId
FROM src.IcdDiagnosisCodeDictionaryBodyPart t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate,
		NcciBodyPartId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.IcdDiagnosisCodeDictionaryBodyPart
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate,
		NcciBodyPartId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DiagnosisCode = s.DiagnosisCode
	AND t.IcdVersion = s.IcdVersion
	AND t.StartDate = s.StartDate
	AND t.NcciBodyPartId = s.NcciBodyPartId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_InjuryNature(
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
		,InjuryNatureId NUMBER(3,0)
		,InjuryNaturePriority NUMBER(3,0)
		,Description VARCHAR(100)
		,NarrativeInformation VARCHAR )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.InjuryNatureId
		,t.InjuryNaturePriority
		,t.Description
		,t.NarrativeInformation
FROM src.InjuryNature t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		InjuryNatureId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.InjuryNature
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		InjuryNatureId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.InjuryNatureId = s.InjuryNatureId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_lkp_SPC(
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
		,lkp_SpcId NUMBER(10,0)
		,LongName VARCHAR(50)
		,ShortName VARCHAR(4)
		,Mult NUMBER(19,4)
		,NCD92 NUMBER(5,0)
		,NCD93 NUMBER(5,0)
		,PlusFour NUMBER(5,0)
		,CbreSpecialtyCode VARCHAR(12) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.lkp_SpcId
		,t.LongName
		,t.ShortName
		,t.Mult
		,t.NCD92
		,t.NCD93
		,t.PlusFour
		,t.CbreSpecialtyCode
FROM src.lkp_SPC t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		lkp_SpcId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.lkp_SPC
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		lkp_SpcId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.lkp_SpcId = s.lkp_SpcId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_lkp_TS(
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
		,ShortName VARCHAR(2)
		,StartDate DATETIME
		,EndDate DATETIME
		,LongName VARCHAR(100)
		,Global NUMBER(5,0)
		,AnesMedDirect NUMBER(5,0)
		,AffectsPricing NUMBER(5,0)
		,IsAssistantSurgery BOOLEAN
		,IsCoSurgeon BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ShortName
		,t.StartDate
		,t.EndDate
		,t.LongName
		,t.Global
		,t.AnesMedDirect
		,t.AffectsPricing
		,t.IsAssistantSurgery
		,t.IsCoSurgeon
FROM src.lkp_TS t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ShortName,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.lkp_TS
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ShortName,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ShortName = s.ShortName
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_MedicalCodeCutOffs(
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
		,CodeTypeID NUMBER(10,0)
		,CodeType VARCHAR(50)
		,Code VARCHAR(50)
		,FormType VARCHAR(10)
		,MaxChargedPerUnit FLOAT(53)
		,MaxUnitsPerEncounter FLOAT(53) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CodeTypeID
		,t.CodeType
		,t.Code
		,t.FormType
		,t.MaxChargedPerUnit
		,t.MaxUnitsPerEncounter
FROM src.MedicalCodeCutOffs t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CodeTypeID,
		Code,
		FormType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicalCodeCutOffs
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CodeTypeID,
		Code,
		FormType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CodeTypeID = s.CodeTypeID
	AND t.Code = s.Code
	AND t.FormType = s.FormType
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_MedicareStatusIndicatorRule(
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
		,MedicareStatusIndicatorRuleId NUMBER(10,0)
		,MedicareStatusIndicatorRuleName VARCHAR(50)
		,StatusIndicator VARCHAR(500)
		,StartDate DATETIME
		,EndDate DATETIME
		,Endnote NUMBER(10,0)
		,EditActionId NUMBER(3,0)
		,Comments VARCHAR(1000) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.MedicareStatusIndicatorRuleId
		,t.MedicareStatusIndicatorRuleName
		,t.StatusIndicator
		,t.StartDate
		,t.EndDate
		,t.Endnote
		,t.EditActionId
		,t.Comments
FROM src.MedicareStatusIndicatorRule t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRule
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_MedicareStatusIndicatorRuleCoverageType(
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
		,MedicareStatusIndicatorRuleId NUMBER(10,0)
		,ShortName VARCHAR(2) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.MedicareStatusIndicatorRuleId
		,t.ShortName
FROM src.MedicareStatusIndicatorRuleCoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ShortName,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRuleCoverageType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ShortName) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
	AND t.ShortName = s.ShortName
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_MedicareStatusIndicatorRulePlaceOfService(
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
		,MedicareStatusIndicatorRuleId NUMBER(10,0)
		,PlaceOfService VARCHAR(4) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.MedicareStatusIndicatorRuleId
		,t.PlaceOfService
FROM src.MedicareStatusIndicatorRulePlaceOfService t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		PlaceOfService,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRulePlaceOfService
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		PlaceOfService) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
	AND t.PlaceOfService = s.PlaceOfService
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_MedicareStatusIndicatorRuleProcedureCode(
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
		,MedicareStatusIndicatorRuleId NUMBER(10,0)
		,ProcedureCode VARCHAR(7) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.MedicareStatusIndicatorRuleId
		,t.ProcedureCode
FROM src.MedicareStatusIndicatorRuleProcedureCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProcedureCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRuleProcedureCode
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProcedureCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
	AND t.ProcedureCode = s.ProcedureCode
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_MedicareStatusIndicatorRuleProviderSpecialty(
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
		,MedicareStatusIndicatorRuleId NUMBER(10,0)
		,ProviderSpecialty VARCHAR(6) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.MedicareStatusIndicatorRuleId
		,t.ProviderSpecialty
FROM src.MedicareStatusIndicatorRuleProviderSpecialty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProviderSpecialty,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRuleProviderSpecialty
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProviderSpecialty) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
	AND t.ProviderSpecialty = s.ProviderSpecialty
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ModifierByState(
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
		,State VARCHAR(2)
		,ProcedureServiceCategoryId NUMBER(3,0)
		,ModifierDictionaryId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.State
		,t.ProcedureServiceCategoryId
		,t.ModifierDictionaryId
FROM src.ModifierByState t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		State,
		ProcedureServiceCategoryId,
		ModifierDictionaryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ModifierByState
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		State,
		ProcedureServiceCategoryId,
		ModifierDictionaryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.State = s.State
	AND t.ProcedureServiceCategoryId = s.ProcedureServiceCategoryId
	AND t.ModifierDictionaryId = s.ModifierDictionaryId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ModifierDictionary(
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
		,ModifierDictionaryId NUMBER(10,0)
		,Modifier VARCHAR(2)
		,StartDate DATETIME
		,EndDate DATETIME
		,Description VARCHAR(100)
		,Global BOOLEAN
		,AnesMedDirect BOOLEAN
		,AffectsPricing BOOLEAN
		,IsCoSurgeon BOOLEAN
		,IsAssistantSurgery BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ModifierDictionaryId
		,t.Modifier
		,t.StartDate
		,t.EndDate
		,t.Description
		,t.Global
		,t.AnesMedDirect
		,t.AffectsPricing
		,t.IsCoSurgeon
		,t.IsAssistantSurgery
FROM src.ModifierDictionary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ModifierDictionaryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ModifierDictionary
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ModifierDictionaryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ModifierDictionaryId = s.ModifierDictionaryId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ModifierToProcedureCode(
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
		,ProcedureCode VARCHAR(5)
		,Modifier VARCHAR(2)
		,StartDate DATETIME
		,EndDate DATETIME
		,SojFlag NUMBER(5,0)
		,RequiresGuidelineReview BOOLEAN
		,Reference VARCHAR(255)
		,Comments VARCHAR(255) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProcedureCode
		,t.Modifier
		,t.StartDate
		,t.EndDate
		,t.SojFlag
		,t.RequiresGuidelineReview
		,t.Reference
		,t.Comments
FROM src.ModifierToProcedureCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProcedureCode,
		Modifier,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ModifierToProcedureCode
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProcedureCode,
		Modifier,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProcedureCode = s.ProcedureCode
	AND t.Modifier = s.Modifier
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_NcciBodyPart(
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
		,NcciBodyPartId NUMBER(3,0)
		,Description VARCHAR(100)
		,NarrativeInformation VARCHAR )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.NcciBodyPartId
		,t.Description
		,t.NarrativeInformation
FROM src.NcciBodyPart t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NcciBodyPartId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.NcciBodyPart
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NcciBodyPartId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NcciBodyPartId = s.NcciBodyPartId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_NcciBodyPartToHybridBodyPartTranslation(
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
		,NcciBodyPartId NUMBER(3,0)
		,HybridBodyPartId NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.NcciBodyPartId
		,t.HybridBodyPartId
FROM src.NcciBodyPartToHybridBodyPartTranslation t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NcciBodyPartId,
		HybridBodyPartId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.NcciBodyPartToHybridBodyPartTranslation
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NcciBodyPartId,
		HybridBodyPartId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NcciBodyPartId = s.NcciBodyPartId
	AND t.HybridBodyPartId = s.HybridBodyPartId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ny_pharmacy(
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
		,NDCCode VARCHAR(13)
		,StartDate DATETIME
		,EndDate DATETIME
		,Description VARCHAR(125)
		,Fee NUMBER(19,4)
		,TypeOfDrug NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.NDCCode
		,t.StartDate
		,t.EndDate
		,t.Description
		,t.Fee
		,t.TypeOfDrug
FROM src.ny_pharmacy t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NDCCode,
		StartDate,
		TypeOfDrug,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ny_pharmacy
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NDCCode,
		StartDate,
		TypeOfDrug) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NDCCode = s.NDCCode
	AND t.StartDate = s.StartDate
	AND t.TypeOfDrug = s.TypeOfDrug
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ny_specialty(
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
		,RatingCode VARCHAR(12)
		,Desc_ VARCHAR(70)
		,CbreSpecialtyCode VARCHAR(12) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RatingCode
		,t.Desc_
		,t.CbreSpecialtyCode
FROM src.ny_specialty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RatingCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ny_specialty
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RatingCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RatingCode = s.RatingCode
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_pa_PlaceOfService(
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
		,POS NUMBER(5,0)
		,Description VARCHAR(255)
		,Facility NUMBER(5,0)
		,MHL NUMBER(5,0)
		,PlusFour NUMBER(5,0)
		,Institution NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.POS
		,t.Description
		,t.Facility
		,t.MHL
		,t.PlusFour
		,t.Institution
FROM src.pa_PlaceOfService t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		POS,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.pa_PlaceOfService
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		POS) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.POS = s.POS
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_PlaceOfServiceDictionary(
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
		,PlaceOfServiceCode NUMBER(5,0)
		,Description VARCHAR(255)
		,Facility NUMBER(5,0)
		,MHL NUMBER(5,0)
		,PlusFour NUMBER(5,0)
		,Institution NUMBER(10,0)
		,StartDate DATETIME
		,EndDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PlaceOfServiceCode
		,t.Description
		,t.Facility
		,t.MHL
		,t.PlusFour
		,t.Institution
		,t.StartDate
		,t.EndDate
FROM src.PlaceOfServiceDictionary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PlaceOfServiceCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PlaceOfServiceDictionary
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PlaceOfServiceCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PlaceOfServiceCode = s.PlaceOfServiceCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_PrePpoBillInfo(
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
		,DateSentToPPO DATETIME
		,ClaimNo VARCHAR(50)
		,ClaimIDNo NUMBER(10,0)
		,CompanyID NUMBER(10,0)
		,OfficeIndex NUMBER(10,0)
		,CV_Code VARCHAR(2)
		,DateLoss DATETIME
		,Deductible NUMBER(19,4)
		,PaidCoPay NUMBER(19,4)
		,PaidDeductible NUMBER(19,4)
		,LossState VARCHAR(2)
		,CmtIDNo NUMBER(10,0)
		,CmtCoPaymentMax NUMBER(19,4)
		,CmtCoPaymentPercentage NUMBER(5,0)
		,CmtDedType NUMBER(5,0)
		,CmtDeductible NUMBER(19,4)
		,CmtFLCopay NUMBER(5,0)
		,CmtPolicyLimit NUMBER(19,4)
		,CmtStateOfJurisdiction VARCHAR(2)
		,PvdIDNo NUMBER(10,0)
		,PvdTIN VARCHAR(15)
		,PvdSPC_List VARCHAR(50)
		,PvdTitle VARCHAR(5)
		,PvdFlags NUMBER(10,0)
		,DateSaved DATETIME
		,DateRcv DATETIME
		,InvoiceDate DATETIME
		,NoLines NUMBER(5,0)
		,AmtCharged NUMBER(19,4)
		,AmtAllowed NUMBER(19,4)
		,Region VARCHAR(50)
		,FeatureID NUMBER(10,0)
		,Flags NUMBER(10,0)
		,WhoCreate VARCHAR(15)
		,WhoLast VARCHAR(15)
		,CmtPaidDeductible NUMBER(19,4)
		,InsPaidLimit NUMBER(19,4)
		,StatusFlag VARCHAR(2)
		,CmtPaidCoPay NUMBER(19,4)
		,Category NUMBER(10,0)
		,CatDesc VARCHAR(1000)
		,CreateDate DATETIME
		,PvdZOS VARCHAR(12)
		,AdmissionDate DATETIME
		,DischargeDate DATETIME
		,DischargeStatus NUMBER(5,0)
		,TypeOfBill VARCHAR(4)
		,PaymentDecision NUMBER(5,0)
		,PPONumberSent NUMBER(5,0)
		,BillIDNo NUMBER(10,0)
		,LINE_NO NUMBER(5,0)
		,LINE_NO_DISP NUMBER(5,0)
		,OVER_RIDE NUMBER(5,0)
		,DT_SVC DATETIME
		,PRC_CD VARCHAR(7)
		,UNITS FLOAT(24)
		,TS_CD VARCHAR(14)
		,CHARGED NUMBER(19,4)
		,ALLOWED NUMBER(19,4)
		,ANALYZED NUMBER(19,4)
		,REF_LINE_NO NUMBER(5,0)
		,SUBNET VARCHAR(9)
		,FEE_SCHEDULE NUMBER(19,4)
		,POS_RevCode VARCHAR(4)
		,CTGPenalty NUMBER(19,4)
		,PrePPOAllowed NUMBER(19,4)
		,PPODate DATETIME
		,PPOCTGPenalty NUMBER(19,4)
		,UCRPerUnit NUMBER(19,4)
		,FSPerUnit NUMBER(19,4)
		,HCRA_Surcharge NUMBER(19,4)
		,NDC VARCHAR(13)
		,PriceTypeCode VARCHAR(2)
		,PharmacyLine NUMBER(5,0)
		,Endnotes VARCHAR(50)
		,SentryEN VARCHAR(250)
		,CTGEN VARCHAR(250)
		,CTGRuleType VARCHAR(250)
		,CTGRuleID VARCHAR(250)
		,OverrideEN VARCHAR(50)
		,UserId NUMBER(10,0)
		,DateOverriden DATETIME
		,AmountBeforeOverride NUMBER(19,4)
		,AmountAfterOverride NUMBER(19,4)
		,CodesOverriden VARCHAR(50)
		,NetworkID NUMBER(10,0)
		,BillSnapshot VARCHAR(30)
		,PPOSavings NUMBER(19,4)
		,RevisedDate DATETIME
		,ReconsideredDate DATETIME
		,TierNumber NUMBER(5,0)
		,PPOBillInfoID NUMBER(10,0)
		,PrePPOBillInfoID NUMBER(10,0)
		,CtgCoPayPenalty NUMBER(19,4) 
	    ,PpoCtgCoPayPenaltyPercentage NUMBER(19,4) 
	    ,CtgVunPenalty NUMBER(19,4) 
	    ,PpoCtgVunPenaltyPercentage NUMBER(19,4) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DateSentToPPO
		,t.ClaimNo
		,t.ClaimIDNo
		,t.CompanyID
		,t.OfficeIndex
		,t.CV_Code
		,t.DateLoss
		,t.Deductible
		,t.PaidCoPay
		,t.PaidDeductible
		,t.LossState
		,t.CmtIDNo
		,t.CmtCoPaymentMax
		,t.CmtCoPaymentPercentage
		,t.CmtDedType
		,t.CmtDeductible
		,t.CmtFLCopay
		,t.CmtPolicyLimit
		,t.CmtStateOfJurisdiction
		,t.PvdIDNo
		,t.PvdTIN
		,t.PvdSPC_List
		,t.PvdTitle
		,t.PvdFlags
		,t.DateSaved
		,t.DateRcv
		,t.InvoiceDate
		,t.NoLines
		,t.AmtCharged
		,t.AmtAllowed
		,t.Region
		,t.FeatureID
		,t.Flags
		,t.WhoCreate
		,t.WhoLast
		,t.CmtPaidDeductible
		,t.InsPaidLimit
		,t.StatusFlag
		,t.CmtPaidCoPay
		,t.Category
		,t.CatDesc
		,t.CreateDate
		,t.PvdZOS
		,t.AdmissionDate
		,t.DischargeDate
		,t.DischargeStatus
		,t.TypeOfBill
		,t.PaymentDecision
		,t.PPONumberSent
		,t.BillIDNo
		,t.LINE_NO
		,t.LINE_NO_DISP
		,t.OVER_RIDE
		,t.DT_SVC
		,t.PRC_CD
		,t.UNITS
		,t.TS_CD
		,t.CHARGED
		,t.ALLOWED
		,t.ANALYZED
		,t.REF_LINE_NO
		,t.SUBNET
		,t.FEE_SCHEDULE
		,t.POS_RevCode
		,t.CTGPenalty
		,t.PrePPOAllowed
		,t.PPODate
		,t.PPOCTGPenalty
		,t.UCRPerUnit
		,t.FSPerUnit
		,t.HCRA_Surcharge
		,t.NDC
		,t.PriceTypeCode
		,t.PharmacyLine
		,t.Endnotes
		,t.SentryEN
		,t.CTGEN
		,t.CTGRuleType
		,t.CTGRuleID
		,t.OverrideEN
		,t.UserId
		,t.DateOverriden
		,t.AmountBeforeOverride
		,t.AmountAfterOverride
		,t.CodesOverriden
		,t.NetworkID
		,t.BillSnapshot
		,t.PPOSavings
		,t.RevisedDate
		,t.ReconsideredDate
		,t.TierNumber
		,t.PPOBillInfoID
		,t.PrePPOBillInfoID
		,t.CtgCoPayPenalty 
		,t.PpoCtgCoPayPenaltyPercentage 
		,t.CtgVunPenalty
		,t.PpoCtgVunPenaltyPercentage
FROM src.PrePpoBillInfo t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PrePPOBillInfoID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PrePpoBillInfo
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PrePPOBillInfoID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PrePPOBillInfoID = s.PrePPOBillInfoID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_prf_COMPANY(
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
		,CompanyId NUMBER(10,0)
		,CompanyName VARCHAR(50)
		,LastChangedOn DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CompanyId
		,t.CompanyName
		,t.LastChangedOn
FROM src.prf_COMPANY t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CompanyId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_COMPANY
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CompanyId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CompanyId = s.CompanyId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_prf_CTGMaxPenaltyLines(
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
		,CTGMaxPenLineID NUMBER(10,0)
		,ProfileId NUMBER(10,0)
		,DatesBasedOn NUMBER(5,0)
		,MaxPenaltyPercent NUMBER(5,0)
		,StartDate DATETIME
		,EndDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CTGMaxPenLineID
		,t.ProfileId
		,t.DatesBasedOn
		,t.MaxPenaltyPercent
		,t.StartDate
		,t.EndDate
FROM src.prf_CTGMaxPenaltyLines t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGMaxPenLineID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGMaxPenaltyLines
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGMaxPenLineID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGMaxPenLineID = s.CTGMaxPenLineID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_prf_CTGPenalty(
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
		,CTGPenID NUMBER(10,0)
		,ProfileId NUMBER(10,0)
		,ApplyPreCerts NUMBER(5,0)
		,NoPrecertLogged NUMBER(5,0)
		,MaxTotalPenalty NUMBER(5,0)
		,TurnTimeForAppeals NUMBER(5,0)
		,ApplyEndnoteForPercert NUMBER(5,0)
		,ApplyEndnoteForCarePath NUMBER(5,0)
		,ExemptPrecertPenalty NUMBER(5,0)
		,ApplyNetworkPenalty BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CTGPenID
		,t.ProfileId
		,t.ApplyPreCerts
		,t.NoPrecertLogged
		,t.MaxTotalPenalty
		,t.TurnTimeForAppeals
		,t.ApplyEndnoteForPercert
		,t.ApplyEndnoteForCarePath
		,t.ExemptPrecertPenalty
		,t.ApplyNetworkPenalty
FROM src.prf_CTGPenalty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGPenID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGPenalty
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGPenID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGPenID = s.CTGPenID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_prf_CTGPenaltyHdr(
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
		,CTGPenHdrID NUMBER(10,0)
		,ProfileId NUMBER(10,0)
		,PenaltyType NUMBER(5,0)
		,PayNegRate NUMBER(5,0)
		,PayPPORate NUMBER(5,0)
		,DatesBasedOn NUMBER(5,0)
		,ApplyPenaltyToPharmacy BOOLEAN
		,ApplyPenaltyCondition BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CTGPenHdrID
		,t.ProfileId
		,t.PenaltyType
		,t.PayNegRate
		,t.PayPPORate
		,t.DatesBasedOn
		,t.ApplyPenaltyToPharmacy
		,t.ApplyPenaltyCondition
FROM src.prf_CTGPenaltyHdr t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGPenHdrID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGPenaltyHdr
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGPenHdrID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGPenHdrID = s.CTGPenHdrID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_prf_CTGPenaltyLines(
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
		,CTGPenLineID NUMBER(10,0)
		,ProfileId NUMBER(10,0)
		,PenaltyType NUMBER(5,0)
		,FeeSchedulePercent NUMBER(5,0)
		,StartDate DATETIME
		,EndDate DATETIME
		,TurnAroundTime NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CTGPenLineID
		,t.ProfileId
		,t.PenaltyType
		,t.FeeSchedulePercent
		,t.StartDate
		,t.EndDate
		,t.TurnAroundTime
FROM src.prf_CTGPenaltyLines t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGPenLineID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGPenaltyLines
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGPenLineID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGPenLineID = s.CTGPenLineID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Prf_CustomIcdAction(
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
		,CustomIcdActionId NUMBER(10,0)
		,ProfileId NUMBER(10,0)
		,IcdVersionId NUMBER(3,0)
		,Action NUMBER(5,0)
		,StartDate DATETIME
		,EndDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CustomIcdActionId
		,t.ProfileId
		,t.IcdVersionId
		,t.Action
		,t.StartDate
		,t.EndDate
FROM src.Prf_CustomIcdAction t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CustomIcdActionId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Prf_CustomIcdAction
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CustomIcdActionId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CustomIcdActionId = s.CustomIcdActionId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_prf_Office(
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
		,CompanyId NUMBER(10,0)
		,OfficeId NUMBER(10,0)
		,OfcNo VARCHAR(4)
		,OfcName VARCHAR(40)
		,OfcAddr1 VARCHAR(30)
		,OfcAddr2 VARCHAR(30)
		,OfcCity VARCHAR(30)
		,OfcState VARCHAR(2)
		,OfcZip VARCHAR(12)
		,OfcPhone VARCHAR(20)
		,OfcDefault NUMBER(5,0)
		,OfcClaimMask VARCHAR(50)
		,OfcTinMask VARCHAR(50)
		,Version NUMBER(5,0)
		,OfcEdits NUMBER(10,0)
		,OfcCOAEnabled NUMBER(5,0)
		,CTGEnabled NUMBER(5,0)
		,LastChangedOn DATETIME
		,AllowMultiCoverage BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CompanyId
		,t.OfficeId
		,t.OfcNo
		,t.OfcName
		,t.OfcAddr1
		,t.OfcAddr2
		,t.OfcCity
		,t.OfcState
		,t.OfcZip
		,t.OfcPhone
		,t.OfcDefault
		,t.OfcClaimMask
		,t.OfcTinMask
		,t.Version
		,t.OfcEdits
		,t.OfcCOAEnabled
		,t.CTGEnabled
		,t.LastChangedOn
		,t.AllowMultiCoverage
FROM src.prf_Office t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OfficeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_Office
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OfficeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OfficeId = s.OfficeId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Prf_OfficeUDF(
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
		,OfficeId NUMBER(10,0)
		,UDFIdNo NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.OfficeId
		,t.UDFIdNo
FROM src.Prf_OfficeUDF t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OfficeId,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Prf_OfficeUDF
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OfficeId,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OfficeId = s.OfficeId
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_prf_PPO(
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
		,PPOSysId NUMBER(10,0)
		,ProfileId NUMBER(10,0)
		,PPOId NUMBER(10,0)
		,bStatus NUMBER(5,0)
		,StartDate DATETIME
		,EndDate DATETIME
		,AutoSend NUMBER(5,0)
		,AutoResend NUMBER(5,0)
		,BypassMatching NUMBER(5,0)
		,UseProviderNetworkEnrollment NUMBER(5,0)
		,TieredTypeId NUMBER(5,0)
		,Priority NUMBER(5,0)
		,PolicyEffectiveDate DATETIME
		,BillFormType NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PPOSysId
		,t.ProfileId
		,t.PPOId
		,t.bStatus
		,t.StartDate
		,t.EndDate
		,t.AutoSend
		,t.AutoResend
		,t.BypassMatching
		,t.UseProviderNetworkEnrollment
		,t.TieredTypeId
		,t.Priority
		,t.PolicyEffectiveDate
		,t.BillFormType
FROM src.prf_PPO t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPOSysId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_PPO
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPOSysId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPOSysId = s.PPOSysId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_prf_Profile(
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
		,ProfileId NUMBER(10,0)
		,OfficeId NUMBER(10,0)
		,CoverageId VARCHAR(2)
		,StateId VARCHAR(2)
		,AnHeader VARCHAR
		,AnFooter VARCHAR
		,ExHeader VARCHAR
		,ExFooter VARCHAR
		,AnalystEdits NUMBER(19,0)
		,DxEdits NUMBER(10,0)
		,DxNonTraumaDays NUMBER(10,0)
		,DxNonSpecDays NUMBER(10,0)
		,PrintCopies NUMBER(10,0)
		,NewPvdState VARCHAR(2)
		,bDuration NUMBER(5,0)
		,bLimits NUMBER(5,0)
		,iDurPct NUMBER(5,0)
		,iLimitPct NUMBER(5,0)
		,PolicyLimit NUMBER(19,4)
		,CoPayPercent NUMBER(10,0)
		,CoPayMax NUMBER(19,4)
		,Deductible NUMBER(19,4)
		,PolicyWarn NUMBER(5,0)
		,PolicyWarnPerc NUMBER(10,0)
		,FeeSchedules NUMBER(10,0)
		,DefaultProfile NUMBER(5,0)
		,FeeAncillaryPct NUMBER(5,0)
		,iGapdol NUMBER(5,0)
		,iGapTreatmnt NUMBER(5,0)
		,bGapTreatmnt NUMBER(5,0)
		,bGapdol NUMBER(5,0)
		,bPrintAdjustor NUMBER(5,0)
		,sPrinterName VARCHAR(50)
		,ErEdits NUMBER(10,0)
		,ErAllowedDays NUMBER(10,0)
		,UcrFsRules NUMBER(10,0)
		,LogoIdNo NUMBER(10,0)
		,LogoJustify NUMBER(5,0)
		,BillLine VARCHAR(50)
		,Version NUMBER(5,0)
		,ClaimDeductible NUMBER(5,0)
		,IncludeCommitted NUMBER(5,0)
		,FLMedicarePercent NUMBER(5,0)
		,UseLevelOfServiceUrl NUMBER(5,0)
		,LevelOfServiceURL VARCHAR(250)
		,CCIPrimary NUMBER(5,0)
		,CCISecondary NUMBER(5,0)
		,CCIMutuallyExclusive NUMBER(5,0)
		,CCIComprehensiveComponent NUMBER(5,0)
		,PayDRGAllowance NUMBER(5,0)
		,FLHospEmPriceOn NUMBER(5,0)
		,EnableBillRelease NUMBER(5,0)
		,DisableSubmitBill NUMBER(5,0)
		,MaxPaymentsPerBill NUMBER(5,0)
		,NoOfPmtPerBill NUMBER(10,0)
		,DefaultDueDate NUMBER(5,0)
		,CheckForNJCarePaths NUMBER(5,0)
		,NJCarePathPercentFS NUMBER(5,0)
		,ApplyEndnoteForNJCarePaths NUMBER(5,0)
		,FLMedicarePercent2008 NUMBER(5,0)
		,RequireEndnoteDuringOverride NUMBER(5,0)
		,StorePerUnitFSandUCR NUMBER(5,0)
		,UseProviderNetworkEnrollment NUMBER(5,0)
		,UseASCRule NUMBER(5,0)
		,AsstCoSurgeonEligible NUMBER(5,0)
		,LastChangedOn DATETIME
		,IsNJPhysMedCapAfterCTG NUMBER(5,0)
		,IsEligibleAmtFeeBased NUMBER(5,0)
		,HideClaimTreeTotalsGrid NUMBER(5,0)
		,SortBillsBy NUMBER(5,0)
		,SortBillsByOrder NUMBER(5,0)
		,ApplyNJEmergencyRoomBenchmarkFee NUMBER(5,0)
		,AllowIcd10ForNJCarePaths NUMBER(5,0)
		,EnableOverrideDeductible BOOLEAN
		,AnalyzeDiagnosisPointers BOOLEAN
		,MedicareFeePercent NUMBER(5,0)
		,EnableSupplementalNdcData BOOLEAN
		,ApplyOriginalNdcAwp BOOLEAN
		,NdcAwpNotAvailable NUMBER(3,0)
		,PayEapgAllowance NUMBER(5,0)
		,MedicareInpatientApcEnabled BOOLEAN
		,MedicareOutpatientAscEnabled BOOLEAN
		,MedicareAscEnabled BOOLEAN
		,UseMedicareInpatientApcFee BOOLEAN
		,MedicareInpatientDrgEnabled BOOLEAN
		,MedicareInpatientDrgPricingType NUMBER(5,0)
		,MedicarePhysicianEnabled BOOLEAN
		,MedicareAmbulanceEnabled BOOLEAN
		,MedicareDmeposEnabled BOOLEAN
		,MedicareAspDrugAndClinicalEnabled BOOLEAN
		,MedicareInpatientPricingType NUMBER(5,0)
		,MedicareOutpatientPricingRulesEnabled BOOLEAN
		,MedicareAscPricingRulesEnabled BOOLEAN
		,NjUseAdmitTypeEnabled BOOLEAN
		,MedicareClinicalLabEnabled BOOLEAN
		,MedicareInpatientEnabled BOOLEAN
		,MedicareOutpatientApcEnabled BOOLEAN
		,MedicareAspDrugEnabled BOOLEAN
		,ShowAllocationsOnEob BOOLEAN
		,EmergencyCarePricingRuleId NUMBER(3,0)
		,OutOfStatePricingEffectiveDateId NUMBER(3,0)
		,PreAllocation BOOLEAN
		,AssistantCoSurgeonModifiers NUMBER(5,0)
		,AssistantSurgeryModifierNotMedicallyNecessary NUMBER(5,0)
		,AssistantSurgeryModifierRequireAdditionalDocument NUMBER(5,0)
		,CoSurgeryModifierNotMedicallyNecessary NUMBER(5,0)
		,CoSurgeryModifierRequireAdditionalDocument NUMBER(5,0)
		,DxNoDiagnosisDays NUMBER(10,0)
		,ModifierExempted BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProfileId
		,t.OfficeId
		,t.CoverageId
		,t.StateId
		,t.AnHeader
		,t.AnFooter
		,t.ExHeader
		,t.ExFooter
		,t.AnalystEdits
		,t.DxEdits
		,t.DxNonTraumaDays
		,t.DxNonSpecDays
		,t.PrintCopies
		,t.NewPvdState
		,t.bDuration
		,t.bLimits
		,t.iDurPct
		,t.iLimitPct
		,t.PolicyLimit
		,t.CoPayPercent
		,t.CoPayMax
		,t.Deductible
		,t.PolicyWarn
		,t.PolicyWarnPerc
		,t.FeeSchedules
		,t.DefaultProfile
		,t.FeeAncillaryPct
		,t.iGapdol
		,t.iGapTreatmnt
		,t.bGapTreatmnt
		,t.bGapdol
		,t.bPrintAdjustor
		,t.sPrinterName
		,t.ErEdits
		,t.ErAllowedDays
		,t.UcrFsRules
		,t.LogoIdNo
		,t.LogoJustify
		,t.BillLine
		,t.Version
		,t.ClaimDeductible
		,t.IncludeCommitted
		,t.FLMedicarePercent
		,t.UseLevelOfServiceUrl
		,t.LevelOfServiceURL
		,t.CCIPrimary
		,t.CCISecondary
		,t.CCIMutuallyExclusive
		,t.CCIComprehensiveComponent
		,t.PayDRGAllowance
		,t.FLHospEmPriceOn
		,t.EnableBillRelease
		,t.DisableSubmitBill
		,t.MaxPaymentsPerBill
		,t.NoOfPmtPerBill
		,t.DefaultDueDate
		,t.CheckForNJCarePaths
		,t.NJCarePathPercentFS
		,t.ApplyEndnoteForNJCarePaths
		,t.FLMedicarePercent2008
		,t.RequireEndnoteDuringOverride
		,t.StorePerUnitFSandUCR
		,t.UseProviderNetworkEnrollment
		,t.UseASCRule
		,t.AsstCoSurgeonEligible
		,t.LastChangedOn
		,t.IsNJPhysMedCapAfterCTG
		,t.IsEligibleAmtFeeBased
		,t.HideClaimTreeTotalsGrid
		,t.SortBillsBy
		,t.SortBillsByOrder
		,t.ApplyNJEmergencyRoomBenchmarkFee
		,t.AllowIcd10ForNJCarePaths
		,t.EnableOverrideDeductible
		,t.AnalyzeDiagnosisPointers
		,t.MedicareFeePercent
		,t.EnableSupplementalNdcData
		,t.ApplyOriginalNdcAwp
		,t.NdcAwpNotAvailable
		,t.PayEapgAllowance
		,t.MedicareInpatientApcEnabled
		,t.MedicareOutpatientAscEnabled
		,t.MedicareAscEnabled
		,t.UseMedicareInpatientApcFee
		,t.MedicareInpatientDrgEnabled
		,t.MedicareInpatientDrgPricingType
		,t.MedicarePhysicianEnabled
		,t.MedicareAmbulanceEnabled
		,t.MedicareDmeposEnabled
		,t.MedicareAspDrugAndClinicalEnabled
		,t.MedicareInpatientPricingType
		,t.MedicareOutpatientPricingRulesEnabled
		,t.MedicareAscPricingRulesEnabled
		,t.NjUseAdmitTypeEnabled
		,t.MedicareClinicalLabEnabled
		,t.MedicareInpatientEnabled
		,t.MedicareOutpatientApcEnabled
		,t.MedicareAspDrugEnabled
		,t.ShowAllocationsOnEob
		,t.EmergencyCarePricingRuleId
		,t.OutOfStatePricingEffectiveDateId
		,t.PreAllocation
		,t.AssistantCoSurgeonModifiers
		,t.AssistantSurgeryModifierNotMedicallyNecessary
		,t.AssistantSurgeryModifierRequireAdditionalDocument
		,t.CoSurgeryModifierNotMedicallyNecessary
		,t.CoSurgeryModifierRequireAdditionalDocument
		,t.DxNoDiagnosisDays
		,t.ModifierExempted
FROM src.prf_Profile t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProfileId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_Profile
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProfileId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProfileId = s.ProfileId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ProcedureCodeGroup(
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
		,ProcedureCode VARCHAR(7)
		,MajorCategory VARCHAR(500)
		,MinorCategory VARCHAR(500) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProcedureCode
		,t.MajorCategory
		,t.MinorCategory
FROM src.ProcedureCodeGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProcedureCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProcedureCodeGroup
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProcedureCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProcedureCode = s.ProcedureCode
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ProcedureServiceCategory(
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
		,ProcedureServiceCategoryId NUMBER(3,0)
		,ProcedureServiceCategoryName VARCHAR(50)
		,ProcedureServiceCategoryDescription VARCHAR(100)
		,LegacyTableName VARCHAR(100)
		,LegacyBitValue NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProcedureServiceCategoryId
		,t.ProcedureServiceCategoryName
		,t.ProcedureServiceCategoryDescription
		,t.LegacyTableName
		,t.LegacyBitValue
FROM src.ProcedureServiceCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProcedureServiceCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProcedureServiceCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProcedureServiceCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProcedureServiceCategoryId = s.ProcedureServiceCategoryId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_PROVIDER(
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
		,PvdIDNo NUMBER(10,0)
		,PvdMID NUMBER(10,0)
		,PvdSource NUMBER(5,0)
		,PvdTIN VARCHAR(15)
		,PvdLicNo VARCHAR(30)
		,PvdCertNo VARCHAR(30)
		,PvdLastName VARCHAR(60)
		,PvdFirstName VARCHAR(35)
		,PvdMI VARCHAR(1)
		,PvdTitle VARCHAR(5)
		,PvdGroup VARCHAR(60)
		,PvdAddr1 VARCHAR(55)
		,PvdAddr2 VARCHAR(55)
		,PvdCity VARCHAR(30)
		,PvdState VARCHAR(2)
		,PvdZip VARCHAR(12)
		,PvdZipPerf VARCHAR(12)
		,PvdPhone VARCHAR(25)
		,PvdFAX VARCHAR(13)
		,PvdSPC_List VARCHAR
		,PvdAuthNo VARCHAR(30)
		,PvdSPC_ACD VARCHAR(2)
		,PvdUpdateCounter NUMBER(5,0)
		,PvdPPO_Provider NUMBER(5,0)
		,PvdFlags NUMBER(10,0)
		,PvdERRate NUMBER(19,4)
		,PvdSubNet VARCHAR(4)
		,InUse VARCHAR(100)
		,PvdStatus NUMBER(10,0)
		,PvdElectroStartDate DATETIME
		,PvdElectroEndDate DATETIME
		,PvdAccredStartDate DATETIME
		,PvdAccredEndDate DATETIME
		,PvdRehabStartDate DATETIME
		,PvdRehabEndDate DATETIME
		,PvdTraumaStartDate DATETIME
		,PvdTraumaEndDate DATETIME
		,OPCERT VARCHAR(7)
		,PvdDentalStartDate DATETIME
		,PvdDentalEndDate DATETIME
		,PvdNPINo VARCHAR(10)
		,PvdCMSId VARCHAR(6)
		,CreateDate DATETIME
		,LastChangedOn DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PvdIDNo
		,t.PvdMID
		,t.PvdSource
		,t.PvdTIN
		,t.PvdLicNo
		,t.PvdCertNo
		,t.PvdLastName
		,t.PvdFirstName
		,t.PvdMI
		,t.PvdTitle
		,t.PvdGroup
		,t.PvdAddr1
		,t.PvdAddr2
		,t.PvdCity
		,t.PvdState
		,t.PvdZip
		,t.PvdZipPerf
		,t.PvdPhone
		,t.PvdFAX
		,t.PvdSPC_List
		,t.PvdAuthNo
		,t.PvdSPC_ACD
		,t.PvdUpdateCounter
		,t.PvdPPO_Provider
		,t.PvdFlags
		,t.PvdERRate
		,t.PvdSubNet
		,t.InUse
		,t.PvdStatus
		,t.PvdElectroStartDate
		,t.PvdElectroEndDate
		,t.PvdAccredStartDate
		,t.PvdAccredEndDate
		,t.PvdRehabStartDate
		,t.PvdRehabEndDate
		,t.PvdTraumaStartDate
		,t.PvdTraumaEndDate
		,t.OPCERT
		,t.PvdDentalStartDate
		,t.PvdDentalEndDate
		,t.PvdNPINo
		,t.PvdCMSId
		,t.CreateDate
		,t.LastChangedOn
FROM src.PROVIDER t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PROVIDER
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIDNo = s.PvdIDNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ProviderCluster(
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
		,PvdIDNo NUMBER(10,0)
		,OrgOdsCustomerId NUMBER(10,0)
		,MitchellProviderKey VARCHAR(200)
		,ProviderClusterKey VARCHAR(200)
		,ProviderType VARCHAR(30) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PvdIDNo
		,t.OrgOdsCustomerId
		,t.MitchellProviderKey
		,t.ProviderClusterKey
		,t.ProviderType
FROM src.ProviderCluster t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIDNo,
		OrgOdsCustomerId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderCluster
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIDNo,
		OrgOdsCustomerId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIDNo = s.PvdIDNo
	AND t.OrgOdsCustomerId = s.OrgOdsCustomerId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ProviderNetworkEventLog(
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
		,IDField NUMBER(10,0)
		,LogDate DATETIME
		,EventId NUMBER(10,0)
		,ClaimIdNo NUMBER(10,0)
		,BillIdNo NUMBER(10,0)
		,UserId NUMBER(10,0)
		,NetworkId NUMBER(10,0)
		,FileName VARCHAR(255)
		,ExtraText VARCHAR(1000)
		,ProcessInfo NUMBER(5,0)
		,TieredTypeID NUMBER(5,0)
		,TierNumber NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.IDField
		,t.LogDate
		,t.EventId
		,t.ClaimIdNo
		,t.BillIdNo
		,t.UserId
		,t.NetworkId
		,t.FileName
		,t.ExtraText
		,t.ProcessInfo
		,t.TieredTypeID
		,t.TierNumber
FROM src.ProviderNetworkEventLog t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		IDField,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderNetworkEventLog
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		IDField) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.IDField = s.IDField
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ProviderNumberCriteria(
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
		,ProviderNumberCriteriaId NUMBER(5,0)
		,ProviderNumber NUMBER(10,0)
		,Priority NUMBER(3,0)
		,FeeScheduleTable VARCHAR(1)
		,StartDate DATETIME
		,EndDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProviderNumberCriteriaId
		,t.ProviderNumber
		,t.Priority
		,t.FeeScheduleTable
		,t.StartDate
		,t.EndDate
FROM src.ProviderNumberCriteria t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderNumberCriteriaId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderNumberCriteria
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderNumberCriteriaId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderNumberCriteriaId = s.ProviderNumberCriteriaId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ProviderNumberCriteriaRevenueCode(
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
		,ProviderNumberCriteriaId NUMBER(5,0)
		,RevenueCode VARCHAR(4)
		,MatchingProfileNumber NUMBER(3,0)
		,AttributeMatchTypeId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProviderNumberCriteriaId
		,t.RevenueCode
		,t.MatchingProfileNumber
		,t.AttributeMatchTypeId
FROM src.ProviderNumberCriteriaRevenueCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderNumberCriteriaId,
		RevenueCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderNumberCriteriaRevenueCode
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderNumberCriteriaId,
		RevenueCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderNumberCriteriaId = s.ProviderNumberCriteriaId
	AND t.RevenueCode = s.RevenueCode
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ProviderNumberCriteriaTypeOfBill(
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
		,ProviderNumberCriteriaId NUMBER(5,0)
		,TypeOfBill VARCHAR(4)
		,MatchingProfileNumber NUMBER(3,0)
		,AttributeMatchTypeId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProviderNumberCriteriaId
		,t.TypeOfBill
		,t.MatchingProfileNumber
		,t.AttributeMatchTypeId
FROM src.ProviderNumberCriteriaTypeOfBill t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderNumberCriteriaId,
		TypeOfBill,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderNumberCriteriaTypeOfBill
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderNumberCriteriaId,
		TypeOfBill) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderNumberCriteriaId = s.ProviderNumberCriteriaId
	AND t.TypeOfBill = s.TypeOfBill
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ProviderSpecialty(
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
		,ProviderId NUMBER(10,0)
		,SpecialtyCode VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProviderId
		,t.SpecialtyCode
FROM src.ProviderSpecialty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderId,
		SpecialtyCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderSpecialty
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderId,
		SpecialtyCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderId = s.ProviderId
	AND t.SpecialtyCode = s.SpecialtyCode
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ProviderSpecialtyToProvType(
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
		,ProviderType VARCHAR(20)
		,ProviderType_Desc VARCHAR(80)
		,Specialty VARCHAR(20)
		,Specialty_Desc VARCHAR(80)
		,CreateDate DATETIME
		,ModifyDate DATETIME
		,LogicalDelete VARCHAR(1) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProviderType
		,t.ProviderType_Desc
		,t.Specialty
		,t.Specialty_Desc
		,t.CreateDate
		,t.ModifyDate
		,t.LogicalDelete
FROM src.ProviderSpecialtyToProvType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderType,
		Specialty,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderSpecialtyToProvType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderType,
		Specialty) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderType = s.ProviderType
	AND t.Specialty = s.Specialty
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Provider_ClientRef(
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
		,PvdIdNo NUMBER(10,0)
		,ClientRefId VARCHAR(50)
		,ClientRefId2 VARCHAR(100) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PvdIdNo
		,t.ClientRefId
		,t.ClientRefId2
FROM src.Provider_ClientRef t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Provider_ClientRef
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIdNo = s.PvdIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Provider_Rendering(
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
		,PvdIDNo NUMBER(10,0)
		,RenderingAddr1 VARCHAR(55)
		,RenderingAddr2 VARCHAR(55)
		,RenderingCity VARCHAR(30)
		,RenderingState VARCHAR(2)
		,RenderingZip VARCHAR(12) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PvdIDNo
		,t.RenderingAddr1
		,t.RenderingAddr2
		,t.RenderingCity
		,t.RenderingState
		,t.RenderingZip
FROM src.Provider_Rendering t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Provider_Rendering
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIDNo = s.PvdIDNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ReferenceBillApcLines(
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
		,BillIdNo NUMBER(10,0)
		,Line_No NUMBER(5,0)
		,PaymentAPC VARCHAR(5)
		,ServiceIndicator VARCHAR(2)
		,PaymentIndicator VARCHAR(1)
		,OutlierAmount NUMBER(19,4)
		,PricerAllowed NUMBER(19,4)
		,MedicareAmount NUMBER(19,4) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIdNo
		,t.Line_No
		,t.PaymentAPC
		,t.ServiceIndicator
		,t.PaymentIndicator
		,t.OutlierAmount
		,t.PricerAllowed
		,t.MedicareAmount
FROM src.ReferenceBillApcLines t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Line_No,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ReferenceBillApcLines
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		Line_No) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.Line_No = s.Line_No
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ReferenceSupplementBillApcLines(
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
		,BillIdNo NUMBER(10,0)
		,SeqNo NUMBER(5,0)
		,Line_No NUMBER(5,0)
		,PaymentAPC VARCHAR(5)
		,ServiceIndicator VARCHAR(2)
		,PaymentIndicator VARCHAR(1)
		,OutlierAmount NUMBER(19,4)
		,PricerAllowed NUMBER(19,4)
		,MedicareAmount NUMBER(19,4) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIdNo
		,t.SeqNo
		,t.Line_No
		,t.PaymentAPC
		,t.ServiceIndicator
		,t.PaymentIndicator
		,t.OutlierAmount
		,t.PricerAllowed
		,t.MedicareAmount
FROM src.ReferenceSupplementBillApcLines t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		SeqNo,
		Line_No,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ReferenceSupplementBillApcLines
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		SeqNo,
		Line_No) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.SeqNo = s.SeqNo
	AND t.Line_No = s.Line_No
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_RENDERINGNPISTATES(
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
		,APPLICATIONSETTINGSID NUMBER(10,0)
		,STATE VARCHAR(2) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.APPLICATIONSETTINGSID
		,t.STATE

FROM src.RENDERINGNPISTATES t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		APPLICATIONSETTINGSID,STATE,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RENDERINGNPISTATES
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		APPLICATIONSETTINGSID,STATE) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.APPLICATIONSETTINGSID = s.APPLICATIONSETTINGSID
	AND t.STATE = s.STATE
WHERE t.DmlOperation <> 'D'

$$;CREATE OR REPLACE FUNCTION dbo.if_RevenueCode(
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
		,RevenueCode VARCHAR(4)
		,RevenueCodeSubCategoryId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RevenueCode
		,t.RevenueCodeSubCategoryId
FROM src.RevenueCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RevenueCode
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCode = s.RevenueCode
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_RevenueCodeCategory(
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
		,RevenueCodeCategoryId NUMBER(3,0)
		,Description VARCHAR(100)
		,NarrativeInformation VARCHAR(1000) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RevenueCodeCategoryId
		,t.Description
		,t.NarrativeInformation
FROM src.RevenueCodeCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCodeCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RevenueCodeCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCodeCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCodeCategoryId = s.RevenueCodeCategoryId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_RevenueCodeSubCategory(
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
		,RevenueCodeSubcategoryId NUMBER(3,0)
		,RevenueCodeCategoryId NUMBER(3,0)
		,Description VARCHAR(100)
		,NarrativeInformation VARCHAR(1000) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RevenueCodeSubcategoryId
		,t.RevenueCodeCategoryId
		,t.Description
		,t.NarrativeInformation
FROM src.RevenueCodeSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCodeSubcategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RevenueCodeSubCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCodeSubcategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCodeSubcategoryId = s.RevenueCodeSubcategoryId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_RPT_RsnCategories(
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
		,CategoryIdNo NUMBER(5,0)
		,CatDesc VARCHAR(50)
		,Priority NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CategoryIdNo
		,t.CatDesc
		,t.Priority
FROM src.RPT_RsnCategories t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CategoryIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RPT_RsnCategories
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CategoryIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CategoryIdNo = s.CategoryIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Rsn_Override(
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
		,ReasonNumber NUMBER(10,0)
		,ShortDesc VARCHAR(50)
		,LongDesc VARCHAR
		,CategoryIdNo NUMBER(5,0)
		,ClientSpec NUMBER(5,0)
		,COAIndex NUMBER(5,0)
		,NJPenaltyPct NUMBER(9,6)
		,NetworkID NUMBER(10,0)
		,SpecialProcessing BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ReasonNumber
		,t.ShortDesc
		,t.LongDesc
		,t.CategoryIdNo
		,t.ClientSpec
		,t.COAIndex
		,t.NJPenaltyPct
		,t.NetworkID
		,t.SpecialProcessing
FROM src.Rsn_Override t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Rsn_Override
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_rsn_REASONS(
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
		,ReasonNumber NUMBER(10,0)
		,CV_Type VARCHAR(2)
		,ShortDesc VARCHAR(50)
		,LongDesc VARCHAR
		,CategoryIdNo NUMBER(10,0)
		,COAIndex NUMBER(5,0)
		,OverrideEndnote NUMBER(10,0)
		,HardEdit NUMBER(5,0)
		,SpecialProcessing BOOLEAN
		,EndnoteActionId NUMBER(3,0)
		,RetainForEapg BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ReasonNumber
		,t.CV_Type
		,t.ShortDesc
		,t.LongDesc
		,t.CategoryIdNo
		,t.COAIndex
		,t.OverrideEndnote
		,t.HardEdit
		,t.SpecialProcessing
		,t.EndnoteActionId
		,t.RetainForEapg
FROM src.rsn_REASONS t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.rsn_REASONS
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Rsn_Reasons_3rdParty(
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
		,ReasonNumber NUMBER(10,0)
		,ShortDesc VARCHAR(50)
		,LongDesc VARCHAR )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ReasonNumber
		,t.ShortDesc
		,t.LongDesc
FROM src.Rsn_Reasons_3rdParty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Rsn_Reasons_3rdParty
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_RuleType(
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
		,RuleTypeID NUMBER(10,0)
		,Name VARCHAR(50)
		,Description VARCHAR(150) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RuleTypeID
		,t.Name
		,t.Description
FROM src.RuleType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleTypeID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RuleType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleTypeID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleTypeID = s.RuleTypeID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ScriptAdvisorBillSource(
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
		,BillSourceId NUMBER(3,0)
		,BillSource VARCHAR(15) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillSourceId
		,t.BillSource
FROM src.ScriptAdvisorBillSource t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillSourceId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ScriptAdvisorBillSource
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillSourceId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillSourceId = s.BillSourceId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ScriptAdvisorSettings(
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
		,ScriptAdvisorSettingsId NUMBER(3,0)
		,IsPharmacyEligible BOOLEAN
		,EnableSendCardToClaimant BOOLEAN
		,EnableBillSource BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ScriptAdvisorSettingsId
		,t.IsPharmacyEligible
		,t.EnableSendCardToClaimant
		,t.EnableBillSource
FROM src.ScriptAdvisorSettings t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ScriptAdvisorSettingsId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ScriptAdvisorSettings
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ScriptAdvisorSettingsId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ScriptAdvisorSettingsId = s.ScriptAdvisorSettingsId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ScriptAdvisorSettingsCoverageType(
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
		,ScriptAdvisorSettingsId NUMBER(3,0)
		,CoverageType VARCHAR(2) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ScriptAdvisorSettingsId
		,t.CoverageType
FROM src.ScriptAdvisorSettingsCoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ScriptAdvisorSettingsId,
		CoverageType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ScriptAdvisorSettingsCoverageType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ScriptAdvisorSettingsId,
		CoverageType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ScriptAdvisorSettingsId = s.ScriptAdvisorSettingsId
	AND t.CoverageType = s.CoverageType
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SEC_RightGroups(
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
		,RightGroupId NUMBER(10,0)
		,RightGroupName VARCHAR(50)
		,RightGroupDescription VARCHAR(150)
		,CreatedDate DATETIME
		,CreatedBy VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RightGroupId
		,t.RightGroupName
		,t.RightGroupDescription
		,t.CreatedDate
		,t.CreatedBy
FROM src.SEC_RightGroups t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RightGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SEC_RightGroups
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RightGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RightGroupId = s.RightGroupId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SEC_Users(
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
		,UserId NUMBER(10,0)
		,LoginName VARCHAR(15)
		,Password VARCHAR(30)
		,CreatedBy VARCHAR(50)
		,CreatedDate DATETIME
		,UserStatus NUMBER(10,0)
		,FirstName VARCHAR(20)
		,LastName VARCHAR(20)
		,AccountLocked NUMBER(5,0)
		,LockedCounter NUMBER(5,0)
		,PasswordCreateDate DATETIME
		,PasswordCaseFlag NUMBER(5,0)
		,ePassword VARCHAR(30)
		,CurrentSettings VARCHAR )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.UserId
		,t.LoginName
		,t.Password
		,t.CreatedBy
		,t.CreatedDate
		,t.UserStatus
		,t.FirstName
		,t.LastName
		,t.AccountLocked
		,t.LockedCounter
		,t.PasswordCreateDate
		,t.PasswordCaseFlag
		,t.ePassword
		,t.CurrentSettings
FROM src.SEC_Users t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		UserId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SEC_Users
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		UserId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.UserId = s.UserId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SEC_User_OfficeGroups(
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
		,SECUserOfficeGroupId NUMBER(10,0)
		,UserId NUMBER(10,0)
		,OffcGroupId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.SECUserOfficeGroupId
		,t.UserId
		,t.OffcGroupId
FROM src.SEC_User_OfficeGroups t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SECUserOfficeGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SEC_User_OfficeGroups
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SECUserOfficeGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SECUserOfficeGroupId = s.SECUserOfficeGroupId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SEC_User_RightGroups(
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
		,SECUserRightGroupId NUMBER(10,0)
		,UserId NUMBER(10,0)
		,RightGroupId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.SECUserRightGroupId
		,t.UserId
		,t.RightGroupId
FROM src.SEC_User_RightGroups t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SECUserRightGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SEC_User_RightGroups
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SECUserRightGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SECUserRightGroupId = s.SECUserRightGroupId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SentryRuleTypeCriteria(
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
		,RuleTypeId NUMBER(10,0)
		,CriteriaId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RuleTypeId
		,t.CriteriaId
FROM src.SentryRuleTypeCriteria t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleTypeId,
		CriteriaId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SentryRuleTypeCriteria
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleTypeId,
		CriteriaId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleTypeId = s.RuleTypeId
	AND t.CriteriaId = s.CriteriaId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SENTRY_ACTION(
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
		,ActionID NUMBER(10,0)
		,Name VARCHAR(50)
		,Description VARCHAR(100)
		,CompatibilityKey VARCHAR(50)
		,PredefinedValues VARCHAR
		,ValueDataType VARCHAR(50)
		,ValueFormat VARCHAR(250)
		,BillLineAction NUMBER(10,0)
		,AnalyzeFlag NUMBER(5,0)
		,ActionCategoryIDNo NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ActionID
		,t.Name
		,t.Description
		,t.CompatibilityKey
		,t.PredefinedValues
		,t.ValueDataType
		,t.ValueFormat
		,t.BillLineAction
		,t.AnalyzeFlag
		,t.ActionCategoryIDNo
FROM src.SENTRY_ACTION t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ActionID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_ACTION
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ActionID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ActionID = s.ActionID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SENTRY_ACTION_CATEGORY(
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
		,ActionCategoryIDNo NUMBER(10,0)
		,Description VARCHAR(60) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ActionCategoryIDNo
		,t.Description
FROM src.SENTRY_ACTION_CATEGORY t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ActionCategoryIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_ACTION_CATEGORY
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ActionCategoryIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ActionCategoryIDNo = s.ActionCategoryIDNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SENTRY_CRITERIA(
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
		,CriteriaID NUMBER(10,0)
		,ParentName VARCHAR(50)
		,Name VARCHAR(50)
		,Description VARCHAR(150)
		,Operators VARCHAR(50)
		,PredefinedValues VARCHAR
		,ValueDataType VARCHAR(50)
		,ValueFormat VARCHAR(250)
		,NullAllowed NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CriteriaID
		,t.ParentName
		,t.Name
		,t.Description
		,t.Operators
		,t.PredefinedValues
		,t.ValueDataType
		,t.ValueFormat
		,t.NullAllowed
FROM src.SENTRY_CRITERIA t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CriteriaID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_CRITERIA
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CriteriaID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CriteriaID = s.CriteriaID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SENTRY_PROFILE_RULE(
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
		,ProfileID NUMBER(10,0)
		,RuleID NUMBER(10,0)
		,Priority NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProfileID
		,t.RuleID
		,t.Priority
FROM src.SENTRY_PROFILE_RULE t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProfileID,
		RuleID,
		Priority,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_PROFILE_RULE
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProfileID,
		RuleID,
		Priority) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProfileID = s.ProfileID
	AND t.RuleID = s.RuleID
	AND t.Priority = s.Priority
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SENTRY_RULE(
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
		,RuleID NUMBER(10,0)
		,Name VARCHAR(50)
		,Description VARCHAR
		,CreatedBy VARCHAR(50)
		,CreationDate DATETIME
		,PostFixNotation VARCHAR
		,Priority NUMBER(10,0)
		,RuleTypeID NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RuleID
		,t.Name
		,t.Description
		,t.CreatedBy
		,t.CreationDate
		,t.PostFixNotation
		,t.Priority
		,t.RuleTypeID
FROM src.SENTRY_RULE t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_RULE
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleID = s.RuleID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SENTRY_RULE_ACTION_DETAIL(
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
		,RuleID NUMBER(10,0)
		,LineNumber NUMBER(10,0)
		,ActionID NUMBER(10,0)
		,ActionValue VARCHAR(1000) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RuleID
		,t.LineNumber
		,t.ActionID
		,t.ActionValue
FROM src.SENTRY_RULE_ACTION_DETAIL t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleID,
		LineNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_RULE_ACTION_DETAIL
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleID,
		LineNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleID = s.RuleID
	AND t.LineNumber = s.LineNumber
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SENTRY_RULE_ACTION_HEADER(
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
		,RuleID NUMBER(10,0)
		,EndnoteShort VARCHAR(50)
		,EndnoteLong VARCHAR )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RuleID
		,t.EndnoteShort
		,t.EndnoteLong
FROM src.SENTRY_RULE_ACTION_HEADER t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_RULE_ACTION_HEADER
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleID = s.RuleID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SENTRY_RULE_CONDITION(
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
		,RuleID NUMBER(10,0)
		,LineNumber NUMBER(10,0)
		,GroupFlag VARCHAR(50)
		,CriteriaID NUMBER(10,0)
		,Operator VARCHAR(50)
		,ConditionValue VARCHAR(60)
		,AndOr VARCHAR(50)
		,UdfConditionId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RuleID
		,t.LineNumber
		,t.GroupFlag
		,t.CriteriaID
		,t.Operator
		,t.ConditionValue
		,t.AndOr
		,t.UdfConditionId
FROM src.SENTRY_RULE_CONDITION t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleID,
		LineNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_RULE_CONDITION
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleID,
		LineNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleID = s.RuleID
	AND t.LineNumber = s.LineNumber
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SPECIALTY(
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
		,SpcIdNo NUMBER(10,0)
		,Code VARCHAR(50)
		,Description VARCHAR(70)
		,PayeeSubTypeID NUMBER(10,0)
		,TieredTypeID NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.SpcIdNo
		,t.Code
		,t.Description
		,t.PayeeSubTypeID
		,t.TieredTypeID
FROM src.SPECIALTY t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Code,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SPECIALTY
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Code) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Code = s.Code
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_StateSettingMedicare(
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
		,StateSettingMedicareId NUMBER(10,0)
		,PayPercentOfMedicareFee BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StateSettingMedicareId
		,t.PayPercentOfMedicareFee
FROM src.StateSettingMedicare t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingMedicareId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingMedicare
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingMedicareId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingMedicareId = s.StateSettingMedicareId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_StateSettingsFlorida(
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
		,StateSettingsFloridaId NUMBER(10,0)
		,ClaimantInitialServiceOption NUMBER(5,0)
		,ClaimantInitialServiceDays NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StateSettingsFloridaId
		,t.ClaimantInitialServiceOption
		,t.ClaimantInitialServiceDays
FROM src.StateSettingsFlorida t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsFloridaId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsFlorida
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsFloridaId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsFloridaId = s.StateSettingsFloridaId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_StateSettingsHawaii(
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
		,StateSettingsHawaiiId NUMBER(10,0)
		,PhysicalMedicineLimitOption NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StateSettingsHawaiiId
		,t.PhysicalMedicineLimitOption
FROM src.StateSettingsHawaii t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsHawaiiId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsHawaii
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsHawaiiId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsHawaiiId = s.StateSettingsHawaiiId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_StateSettingsNewJersey(
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
		,StateSettingsNewJerseyId NUMBER(10,0)
		,ByPassEmergencyServices BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StateSettingsNewJerseyId
		,t.ByPassEmergencyServices
FROM src.StateSettingsNewJersey t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsNewJerseyId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNewJersey
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsNewJerseyId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsNewJerseyId = s.StateSettingsNewJerseyId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_StateSettingsNewJerseyPolicyPreference(
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
		,PolicyPreferenceId NUMBER(10,0)
		,ShareCoPayMaximum BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PolicyPreferenceId
		,t.ShareCoPayMaximum
FROM src.StateSettingsNewJerseyPolicyPreference t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PolicyPreferenceId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNewJerseyPolicyPreference
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PolicyPreferenceId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PolicyPreferenceId = s.PolicyPreferenceId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_StateSettingsNewYorkPolicyPreference(
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
		,PolicyPreferenceId NUMBER(10,0)
		,ShareCoPayMaximum BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PolicyPreferenceId
		,t.ShareCoPayMaximum
FROM src.StateSettingsNewYorkPolicyPreference t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PolicyPreferenceId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNewYorkPolicyPreference
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PolicyPreferenceId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PolicyPreferenceId = s.PolicyPreferenceId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_StateSettingsNY(
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
		,StateSettingsNYID NUMBER(10,0)
		,NF10PrintDate BOOLEAN
		,NF10CheckBox1 BOOLEAN
		,NF10CheckBox18 BOOLEAN
		,NF10UseUnderwritingCompany BOOLEAN
		,UnderwritingCompanyUdfId NUMBER(10,0)
		,NaicUdfId NUMBER(10,0)
		,DisplayNYPrintOptionsWhenZosOrSojIsNY BOOLEAN
		,NF10DuplicatePrint BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StateSettingsNYID
		,t.NF10PrintDate
		,t.NF10CheckBox1
		,t.NF10CheckBox18
		,t.NF10UseUnderwritingCompany
		,t.UnderwritingCompanyUdfId
		,t.NaicUdfId
		,t.DisplayNYPrintOptionsWhenZosOrSojIsNY
		,t.NF10DuplicatePrint
FROM src.StateSettingsNY t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsNYID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNY
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsNYID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsNYID = s.StateSettingsNYID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_StateSettingsNyRoomRate(
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
		,StateSettingsNyRoomRateId NUMBER(10,0)
		,StartDate DATETIME
		,EndDate DATETIME
		,RoomRate NUMBER(19,4) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StateSettingsNyRoomRateId
		,t.StartDate
		,t.EndDate
		,t.RoomRate
FROM src.StateSettingsNyRoomRate t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsNyRoomRateId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNyRoomRate
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsNyRoomRateId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsNyRoomRateId = s.StateSettingsNyRoomRateId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_StateSettingsOregon(
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
		,StateSettingsOregonId NUMBER(3,0)
		,ApplyOregonFeeSchedule BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StateSettingsOregonId
		,t.ApplyOregonFeeSchedule
FROM src.StateSettingsOregon t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsOregonId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsOregon
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsOregonId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsOregonId = s.StateSettingsOregonId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_StateSettingsOregonCoverageType(
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
		,StateSettingsOregonId NUMBER(3,0)
		,CoverageType VARCHAR(2) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StateSettingsOregonId
		,t.CoverageType
FROM src.StateSettingsOregonCoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsOregonId,
		CoverageType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsOregonCoverageType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsOregonId,
		CoverageType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsOregonId = s.StateSettingsOregonId
	AND t.CoverageType = s.CoverageType
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SupplementBillApportionmentEndnote(
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
		,BillId NUMBER(10,0)
		,SequenceNumber NUMBER(5,0)
		,LineNumber NUMBER(5,0)
		,Endnote NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillId
		,t.SequenceNumber
		,t.LineNumber
		,t.Endnote
FROM src.SupplementBillApportionmentEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillId,
		SequenceNumber,
		LineNumber,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SupplementBillApportionmentEndnote
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillId,
		SequenceNumber,
		LineNumber,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillId = s.BillId
	AND t.SequenceNumber = s.SequenceNumber
	AND t.LineNumber = s.LineNumber
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SupplementBillCustomEndnote(
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
		,BillId NUMBER(10,0)
		,SequenceNumber NUMBER(5,0)
		,LineNumber NUMBER(5,0)
		,Endnote NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillId
		,t.SequenceNumber
		,t.LineNumber
		,t.Endnote
FROM src.SupplementBillCustomEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillId,
		SequenceNumber,
		LineNumber,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SupplementBillCustomEndnote
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillId,
		SequenceNumber,
		LineNumber,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillId = s.BillId
	AND t.SequenceNumber = s.SequenceNumber
	AND t.LineNumber = s.LineNumber
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SupplementBill_Pharm_ApportionmentEndnote(
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
		,BillId NUMBER(10,0)
		,SequenceNumber NUMBER(5,0)
		,LineNumber NUMBER(5,0)
		,Endnote NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillId
		,t.SequenceNumber
		,t.LineNumber
		,t.Endnote
FROM src.SupplementBill_Pharm_ApportionmentEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillId,
		SequenceNumber,
		LineNumber,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SupplementBill_Pharm_ApportionmentEndnote
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillId,
		SequenceNumber,
		LineNumber,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillId = s.BillId
	AND t.SequenceNumber = s.SequenceNumber
	AND t.LineNumber = s.LineNumber
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SUPPLEMENTPRECTGDENIEDLINESELIGIBLETOPENALTY(
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
		,BILLIDNO NUMBER(10,0)
		,LINENUMBER NUMBER(5,0)
		,CTGPENALTYTYPEID NUMBER(3,0)
		,SEQNO NUMBER(5,0) )

AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BILLIDNO
		,t.LINENUMBER
		,t.CTGPENALTYTYPEID
		,t.SEQNO

FROM src.SUPPLEMENTPRECTGDENIEDLINESELIGIBLETOPENALTY t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BILLIDNO,LINENUMBER,CTGPENALTYTYPEID,SEQNO,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SUPPLEMENTPRECTGDENIEDLINESELIGIBLETOPENALTY
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BILLIDNO,LINENUMBER,CTGPENALTYTYPEID,SEQNO) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BILLIDNO = s.BILLIDNO
	AND t.LINENUMBER = s.LINENUMBER
	AND t.CTGPENALTYTYPEID = s.CTGPENALTYTYPEID
	AND t.SEQNO = s.SEQNO
	
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_SurgicalModifierException(
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
		,Modifier VARCHAR(2)
		,State VARCHAR(2)
		,CoverageType VARCHAR(2)
		,StartDate DATETIME
		,EndDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.Modifier
		,t.State
		,t.CoverageType
		,t.StartDate
		,t.EndDate
FROM src.SurgicalModifierException t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Modifier,
		State,
		CoverageType,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SurgicalModifierException
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Modifier,
		State,
		CoverageType,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Modifier = s.Modifier
	AND t.State = s.State
	AND t.CoverageType = s.CoverageType
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_UB_APC_DICT(
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
		,StartDate DATETIME
		,EndDate DATETIME
		,APC VARCHAR(5)
		,Description VARCHAR(255) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StartDate
		,t.EndDate
		,t.APC
		,t.Description
FROM src.UB_APC_DICT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		APC,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UB_APC_DICT
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		APC,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.APC = s.APC
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_UB_BillType(
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
		,TOB VARCHAR(4)
		,Description VARCHAR
		,Flag NUMBER(10,0)
		,UB_BillTypeID NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.TOB
		,t.Description
		,t.Flag
		,t.UB_BillTypeID
FROM src.UB_BillType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TOB,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UB_BillType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TOB) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TOB = s.TOB
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_UB_RevenueCodes(
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
		,RevenueCode VARCHAR(4)
		,StartDate DATETIME
		,EndDate DATETIME
		,PRC_DESC VARCHAR
		,Flags NUMBER(10,0)
		,Vague VARCHAR(1)
		,PerVisit NUMBER(5,0)
		,PerClaimant NUMBER(5,0)
		,PerProvider NUMBER(5,0)
		,BodyFlags NUMBER(10,0)
		,DrugFlag NUMBER(5,0)
		,CurativeFlag NUMBER(5,0)
		,RevenueCodeSubCategoryId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RevenueCode
		,t.StartDate
		,t.EndDate
		,t.PRC_DESC
		,t.Flags
		,t.Vague
		,t.PerVisit
		,t.PerClaimant
		,t.PerProvider
		,t.BodyFlags
		,t.DrugFlag
		,t.CurativeFlag
		,t.RevenueCodeSubCategoryId
FROM src.UB_RevenueCodes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UB_RevenueCodes
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCode = s.RevenueCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_UDFBill(
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
		,BillIdNo NUMBER(10,0)
		,UDFIdNo NUMBER(10,0)
		,UDFValueText VARCHAR(255)
		,UDFValueDecimal NUMBER(19,4)
		,UDFValueDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIdNo
		,t.UDFIdNo
		,t.UDFValueText
		,t.UDFValueDecimal
		,t.UDFValueDate
FROM src.UDFBill t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFBill
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_UDFClaim(
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
		,ClaimIdNo NUMBER(10,0)
		,UDFIdNo NUMBER(10,0)
		,UDFValueText VARCHAR(255)
		,UDFValueDecimal NUMBER(19,4)
		,UDFValueDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ClaimIdNo
		,t.UDFIdNo
		,t.UDFValueText
		,t.UDFValueDecimal
		,t.UDFValueDate
FROM src.UDFClaim t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimIdNo,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFClaim
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimIdNo,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimIdNo = s.ClaimIdNo
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_UDFClaimant(
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
		,CmtIdNo NUMBER(10,0)
		,UDFIdNo NUMBER(10,0)
		,UDFValueText VARCHAR(255)
		,UDFValueDecimal NUMBER(19,4)
		,UDFValueDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CmtIdNo
		,t.UDFIdNo
		,t.UDFValueText
		,t.UDFValueDecimal
		,t.UDFValueDate
FROM src.UDFClaimant t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CmtIdNo,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFClaimant
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CmtIdNo,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CmtIdNo = s.CmtIdNo
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_UdfDataFormat(
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
		,UdfDataFormatId NUMBER(5,0)
		,DataFormatName VARCHAR(30) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.UdfDataFormatId
		,t.DataFormatName
FROM src.UdfDataFormat t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		UdfDataFormatId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UdfDataFormat
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		UdfDataFormatId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.UdfDataFormatId = s.UdfDataFormatId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_UDFLevelChangeTracking(
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
		,UDFLevelChangeTrackingId NUMBER(10,0)
		,EntityType NUMBER(10,0)
		,EntityId NUMBER(10,0)
		,CorrelationId VARCHAR(50)
		,UDFId NUMBER(10,0)
		,PreviousValue VARCHAR
		,UpdatedValue VARCHAR
		,UserId NUMBER(10,0)
		,ChangeDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.UDFLevelChangeTrackingId
		,t.EntityType
		,t.EntityId
		,t.CorrelationId
		,t.UDFId
		,t.PreviousValue
		,t.UpdatedValue
		,t.UserId
		,t.ChangeDate
FROM src.UDFLevelChangeTracking t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		UDFLevelChangeTrackingId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFLevelChangeTracking
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		UDFLevelChangeTrackingId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.UDFLevelChangeTrackingId = s.UDFLevelChangeTrackingId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_UDFLibrary(
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
		,UDFIdNo NUMBER(10,0)
		,UDFName VARCHAR(50)
		,ScreenType NUMBER(5,0)
		,UDFDescription VARCHAR(1000)
		,DataFormat NUMBER(5,0)
		,RequiredField NUMBER(5,0)
		,ReadOnly NUMBER(5,0)
		,Invisible NUMBER(5,0)
		,TextMaxLength NUMBER(5,0)
		,TextMask VARCHAR(50)
		,TextEnforceLength NUMBER(5,0)
		,RestrictRange NUMBER(5,0)
		,MinValDecimal FLOAT(24)
		,MaxValDecimal FLOAT(24)
		,MinValDate DATETIME
		,MaxValDate DATETIME
		,ListAllowMultiple NUMBER(5,0)
		,DefaultValueText VARCHAR(100)
		,DefaultValueDecimal FLOAT(24)
		,DefaultValueDate DATETIME
		,UseDefault NUMBER(5,0)
		,ReqOnSubmit NUMBER(5,0)
		,IncludeDateButton BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.UDFIdNo
		,t.UDFName
		,t.ScreenType
		,t.UDFDescription
		,t.DataFormat
		,t.RequiredField
		,t.ReadOnly
		,t.Invisible
		,t.TextMaxLength
		,t.TextMask
		,t.TextEnforceLength
		,t.RestrictRange
		,t.MinValDecimal
		,t.MaxValDecimal
		,t.MinValDate
		,t.MaxValDate
		,t.ListAllowMultiple
		,t.DefaultValueText
		,t.DefaultValueDecimal
		,t.DefaultValueDate
		,t.UseDefault
		,t.ReqOnSubmit
		,t.IncludeDateButton
FROM src.UDFLibrary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFLibrary
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_UDFListValues(
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
		,ListValueIdNo NUMBER(10,0)
		,UDFIdNo NUMBER(10,0)
		,SeqNo NUMBER(5,0)
		,ListValue VARCHAR(50)
		,DefaultValue NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ListValueIdNo
		,t.UDFIdNo
		,t.SeqNo
		,t.ListValue
		,t.DefaultValue
FROM src.UDFListValues t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ListValueIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFListValues
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ListValueIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ListValueIdNo = s.ListValueIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_UDFProvider(
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
		,PvdIdNo NUMBER(10,0)
		,UDFIdNo NUMBER(10,0)
		,UDFValueText VARCHAR(255)
		,UDFValueDecimal NUMBER(19,4)
		,UDFValueDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PvdIdNo
		,t.UDFIdNo
		,t.UDFValueText
		,t.UDFValueDecimal
		,t.UDFValueDate
FROM src.UDFProvider t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIdNo,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFProvider
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIdNo,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIdNo = s.PvdIdNo
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_UDFViewOrder(
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
		,OfficeId NUMBER(10,0)
		,UDFIdNo NUMBER(10,0)
		,ViewOrder NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.OfficeId
		,t.UDFIdNo
		,t.ViewOrder
FROM src.UDFViewOrder t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OfficeId,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFViewOrder
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OfficeId,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OfficeId = s.OfficeId
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_UDF_Sentry_Criteria(
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
		,UdfIdNo NUMBER(10,0)
		,CriteriaID NUMBER(10,0)
		,ParentName VARCHAR(50)
		,Name VARCHAR(50)
		,Description VARCHAR(1000)
		,Operators VARCHAR(50)
		,PredefinedValues VARCHAR
		,ValueDataType VARCHAR(50)
		,ValueFormat VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.UdfIdNo
		,t.CriteriaID
		,t.ParentName
		,t.Name
		,t.Description
		,t.Operators
		,t.PredefinedValues
		,t.ValueDataType
		,t.ValueFormat
FROM src.UDF_Sentry_Criteria t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CriteriaID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDF_Sentry_Criteria
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CriteriaID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CriteriaID = s.CriteriaID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Vpn(
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
		,VpnId NUMBER(5,0)
		,NetworkName VARCHAR(50)
		,PendAndSend BOOLEAN
		,BypassMatching BOOLEAN
		,AllowsResends BOOLEAN
		,OdsEligible BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.VpnId
		,t.NetworkName
		,t.PendAndSend
		,t.BypassMatching
		,t.AllowsResends
		,t.OdsEligible
FROM src.Vpn t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Vpn
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnId = s.VpnId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_VPNActivityFlag(
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
		,Activity_Flag VARCHAR(1)
		,AF_Description VARCHAR(50)
		,AF_ShortDesc VARCHAR(50)
		,Data_Source VARCHAR(5)
		,Default_Billable BOOLEAN
		,Credit BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.Activity_Flag
		,t.AF_Description
		,t.AF_ShortDesc
		,t.Data_Source
		,t.Default_Billable
		,t.Credit
FROM src.VPNActivityFlag t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Activity_Flag,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VPNActivityFlag
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Activity_Flag) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Activity_Flag = s.Activity_Flag
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_VpnBillableFlags(
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
		,SOJ VARCHAR(2)
		,NetworkID NUMBER(10,0)
		,ActivityFlag VARCHAR(2)
		,Billable VARCHAR(1)
		,CompanyCode VARCHAR(10)
		,CompanyName VARCHAR(100) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.SOJ
		,t.NetworkID
		,t.ActivityFlag
		,t.Billable
		,t.CompanyCode
		,t.CompanyName
FROM src.VpnBillableFlags t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CompanyCode,
		SOJ,
		NetworkID,
		ActivityFlag,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnBillableFlags
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CompanyCode,
		SOJ,
		NetworkID,
		ActivityFlag) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CompanyCode = s.CompanyCode
	AND t.SOJ = s.SOJ
	AND t.NetworkID = s.NetworkID
	AND t.ActivityFlag = s.ActivityFlag
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_VpnBillingCategory(
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
		,VpnBillingCategoryCode VARCHAR(1)
		,VpnBillingCategoryDescription VARCHAR(30) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.VpnBillingCategoryCode
		,t.VpnBillingCategoryDescription
FROM src.VpnBillingCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnBillingCategoryCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnBillingCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnBillingCategoryCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnBillingCategoryCode = s.VpnBillingCategoryCode
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_VpnLedger(
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
		,TransactionID NUMBER(19,0)
		,TransactionTypeID NUMBER(10,0)
		,BillIdNo NUMBER(10,0)
		,Line_No NUMBER(5,0)
		,Charged NUMBER(19,4)
		,DPAllowed NUMBER(19,4)
		,VPNAllowed NUMBER(19,4)
		,Savings NUMBER(19,4)
		,Credits NUMBER(19,4)
		,HasOverride BOOLEAN
		,EndNotes VARCHAR(200)
		,NetworkIdNo NUMBER(10,0)
		,ProcessFlag NUMBER(5,0)
		,LineType NUMBER(10,0)
		,DateTimeStamp DATETIME
		,SeqNo NUMBER(10,0)
		,VPN_Ref_Line_No NUMBER(5,0)
		,SpecialProcessing BOOLEAN
		,CreateDate DATETIME
		,LastChangedOn DATETIME
		,AdjustedCharged NUMBER(19,4) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.TransactionID
		,t.TransactionTypeID
		,t.BillIdNo
		,t.Line_No
		,t.Charged
		,t.DPAllowed
		,t.VPNAllowed
		,t.Savings
		,t.Credits
		,t.HasOverride
		,t.EndNotes
		,t.NetworkIdNo
		,t.ProcessFlag
		,t.LineType
		,t.DateTimeStamp
		,t.SeqNo
		,t.VPN_Ref_Line_No
		,t.SpecialProcessing
		,t.CreateDate
		,t.LastChangedOn
		,t.AdjustedCharged
FROM src.VpnLedger t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TransactionID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnLedger
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TransactionID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TransactionID = s.TransactionID
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_VpnProcessFlagType(
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
		,VpnProcessFlagTypeId NUMBER(5,0)
		,VpnProcessFlagType VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.VpnProcessFlagTypeId
		,t.VpnProcessFlagType
FROM src.VpnProcessFlagType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnProcessFlagTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnProcessFlagType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnProcessFlagTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnProcessFlagTypeId = s.VpnProcessFlagTypeId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_VpnSavingTransactionType(
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
		,VpnSavingTransactionTypeId NUMBER(10,0)
		,VpnSavingTransactionType VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.VpnSavingTransactionTypeId
		,t.VpnSavingTransactionType
FROM src.VpnSavingTransactionType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnSavingTransactionTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnSavingTransactionType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnSavingTransactionTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnSavingTransactionTypeId = s.VpnSavingTransactionTypeId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Vpn_Billing_History(
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
		,Customer VARCHAR(50)
		,TransactionID NUMBER(19,0)
		,Period DATETIME
		,ActivityFlag VARCHAR(1)
		,BillableFlag VARCHAR(1)
		,Void VARCHAR(4)
		,CreditType VARCHAR(10)
		,Network VARCHAR(50)
		,BillIdNo NUMBER(10,0)
		,Line_No NUMBER(5,0)
		,TransactionDate DATETIME
		,RepriceDate DATETIME
		,ClaimNo VARCHAR(50)
		,ProviderCharges NUMBER(19,4)
		,DPAllowed NUMBER(19,4)
		,VPNAllowed NUMBER(19,4)
		,Savings NUMBER(19,4)
		,Credits NUMBER(19,4)
		,NetSavings NUMBER(19,4)
		,SOJ VARCHAR(2)
		,seqno NUMBER(10,0)
		,CompanyCode VARCHAR(10)
		,VpnId NUMBER(5,0)
		,ProcessFlag NUMBER(5,0)
		,SK NUMBER(10,0)
		,DATABASE_NAME VARCHAR(100)
		,SubmittedToFinance BOOLEAN
		,IsInitialLoad BOOLEAN
		,VpnBillingCategoryCode VARCHAR(1) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.Customer
		,t.TransactionID
		,t.Period
		,t.ActivityFlag
		,t.BillableFlag
		,t.Void
		,t.CreditType
		,t.Network
		,t.BillIdNo
		,t.Line_No
		,t.TransactionDate
		,t.RepriceDate
		,t.ClaimNo
		,t.ProviderCharges
		,t.DPAllowed
		,t.VPNAllowed
		,t.Savings
		,t.Credits
		,t.NetSavings
		,t.SOJ
		,t.seqno
		,t.CompanyCode
		,t.VpnId
		,t.ProcessFlag
		,t.SK
		,t.DATABASE_NAME
		,t.SubmittedToFinance
		,t.IsInitialLoad
		,t.VpnBillingCategoryCode
FROM src.Vpn_Billing_History t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TransactionID,
		Period,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Vpn_Billing_History
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TransactionID,
		Period) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TransactionID = s.TransactionID
	AND t.Period = s.Period
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_WeekEndsAndHolidays(
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
		,DayOfWeekDate DATETIME
		,DayName VARCHAR(3)
		,WeekEndsAndHolidayId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DayOfWeekDate
		,t.DayName
		,t.WeekEndsAndHolidayId
FROM src.WeekEndsAndHolidays t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		WeekEndsAndHolidayId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.WeekEndsAndHolidays
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		WeekEndsAndHolidayId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.WeekEndsAndHolidayId = s.WeekEndsAndHolidayId
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_Zip2County(
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
		,Zip VARCHAR(5)
		,County VARCHAR(50)
		,State VARCHAR(2) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.Zip
		,t.County
		,t.State
FROM src.Zip2County t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Zip,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Zip2County
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Zip) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Zip = s.Zip
WHERE t.DmlOperation <> 'D'

$$;


CREATE OR REPLACE FUNCTION dbo.if_ZipCode(
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
		,ZipCode VARCHAR(5)
		,PrimaryRecord BOOLEAN
		,STATE VARCHAR(2)
		,City VARCHAR(30)
		,CityAlias VARCHAR(30)
		,County VARCHAR(30)
		,Cbsa VARCHAR(5)
		,CbsaType VARCHAR(5)
		,ZipCodeRegionId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ZipCode
		,t.PrimaryRecord
		,t.STATE
		,t.City
		,t.CityAlias
		,t.County
		,t.Cbsa
		,t.CbsaType
		,t.ZipCodeRegionId
FROM src.ZipCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ZipCode,
		CityAlias,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ZipCode
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ZipCode,
		CityAlias) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ZipCode = s.ZipCode
	AND t.CityAlias = s.CityAlias
WHERE t.DmlOperation <> 'D'

$$;


