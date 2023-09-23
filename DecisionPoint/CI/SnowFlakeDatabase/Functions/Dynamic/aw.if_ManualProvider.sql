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


