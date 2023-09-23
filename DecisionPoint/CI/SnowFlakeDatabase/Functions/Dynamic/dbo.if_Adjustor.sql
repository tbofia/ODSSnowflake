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


