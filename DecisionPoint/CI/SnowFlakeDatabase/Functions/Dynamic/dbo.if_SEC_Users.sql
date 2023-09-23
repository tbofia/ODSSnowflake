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


