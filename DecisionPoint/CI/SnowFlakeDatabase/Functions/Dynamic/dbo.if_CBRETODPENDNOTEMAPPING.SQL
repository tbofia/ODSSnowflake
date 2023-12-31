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


