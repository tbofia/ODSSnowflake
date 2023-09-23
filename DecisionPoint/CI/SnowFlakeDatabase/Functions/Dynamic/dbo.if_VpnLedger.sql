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


