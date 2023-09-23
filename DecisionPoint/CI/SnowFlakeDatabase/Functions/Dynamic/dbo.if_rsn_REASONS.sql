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


