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


