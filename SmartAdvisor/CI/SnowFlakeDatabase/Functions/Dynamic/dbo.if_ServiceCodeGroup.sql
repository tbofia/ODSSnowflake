CREATE OR REPLACE FUNCTION dbo.if_ServiceCodeGroup(
		IF_ODSPOSTINGGROUPAUDITID INT
)
RETURNS TABLE  (
	   OdsPostingGroupAuditId NUMBER(10,0)
	 , OdsCustomerId NUMBER(10,0)
	 , OdsCreateDate DATETIME
	 , OdsSnapshotDate DATETIME 
	 , OdsRowIsCurrent INT
	 , OdsHashbytesValue BINARY(8000) 
	 , DmlOperation VARCHAR(1)
	 , SiteCode VARCHAR (3)
	 , GroupType VARCHAR (8) 
	 , Family VARCHAR (8)
	 , Revision VARCHAR (4)
	 , GroupCode VARCHAR (8)
	 , CodeOrder NUMBER (10,0) 
	 , ServiceCode VARCHAR (12)
	 , ServiceCodeType VARCHAR (8) 
	 , LinkGroupType VARCHAR (8) 
	 , LinkGroupFamily VARCHAR (8) 
	 , CodeLevel NUMBER (5,0) 
	 , GlobalPriority NUMBER (10,0) 
	 , Active VARCHAR (1) 
	 , Comment VARCHAR (2000) 
	 , CustomParameters VARCHAR (4000) 
	 , CreateDate DATETIME 
	 , CreateUserID VARCHAR (2) 
	 , ModDate DATETIME 
	 , ModUserID VARCHAR (2) )
AS
$$
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.SiteCode,
	t.GroupType,
	t.Family,
	t.Revision,
	t.GroupCode,
	t.CodeOrder,
	t.ServiceCode,
	t.ServiceCodeType,
	t.LinkGroupType,
	t.LinkGroupFamily,
	t.CodeLevel,
	t.GlobalPriority,
	t.Active,
	t.Comment,
	t.CustomParameters,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.ServiceCodeGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SiteCode,
		GroupType,
		Family,
		Revision,
		GroupCode,
		CodeOrder,
		ServiceCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ServiceCodeGroup
	WHERE ODSPOSTINGGROUPAUDITID <= IF_ODSPOSTINGGROUPAUDITID
	GROUP BY OdsCustomerId,
		SiteCode,
		GroupType,
		Family,
		Revision,
		GroupCode,
		CodeOrder,
		ServiceCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SiteCode = s.SiteCode
	AND t.GroupType = s.GroupType
	AND t.Family = s.Family
	AND t.Revision = s.Revision
	AND t.GroupCode = s.GroupCode
	AND t.CodeOrder = s.CodeOrder
	AND t.ServiceCode = s.ServiceCode
WHERE t.DmlOperation <> 'D'

$$;


