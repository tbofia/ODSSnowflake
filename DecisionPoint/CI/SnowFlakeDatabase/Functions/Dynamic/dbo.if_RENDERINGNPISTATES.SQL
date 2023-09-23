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

$$;