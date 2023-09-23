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


