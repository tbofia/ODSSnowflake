CREATE OR REPLACE FUNCTION dbo.if_PROVIDER(
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
		,PvdIDNo NUMBER(10,0)
		,PvdMID NUMBER(10,0)
		,PvdSource NUMBER(5,0)
		,PvdTIN VARCHAR(15)
		,PvdLicNo VARCHAR(30)
		,PvdCertNo VARCHAR(30)
		,PvdLastName VARCHAR(60)
		,PvdFirstName VARCHAR(35)
		,PvdMI VARCHAR(1)
		,PvdTitle VARCHAR(5)
		,PvdGroup VARCHAR(60)
		,PvdAddr1 VARCHAR(55)
		,PvdAddr2 VARCHAR(55)
		,PvdCity VARCHAR(30)
		,PvdState VARCHAR(2)
		,PvdZip VARCHAR(12)
		,PvdZipPerf VARCHAR(12)
		,PvdPhone VARCHAR(25)
		,PvdFAX VARCHAR(13)
		,PvdSPC_List VARCHAR
		,PvdAuthNo VARCHAR(30)
		,PvdSPC_ACD VARCHAR(2)
		,PvdUpdateCounter NUMBER(5,0)
		,PvdPPO_Provider NUMBER(5,0)
		,PvdFlags NUMBER(10,0)
		,PvdERRate NUMBER(19,4)
		,PvdSubNet VARCHAR(4)
		,InUse VARCHAR(100)
		,PvdStatus NUMBER(10,0)
		,PvdElectroStartDate DATETIME
		,PvdElectroEndDate DATETIME
		,PvdAccredStartDate DATETIME
		,PvdAccredEndDate DATETIME
		,PvdRehabStartDate DATETIME
		,PvdRehabEndDate DATETIME
		,PvdTraumaStartDate DATETIME
		,PvdTraumaEndDate DATETIME
		,OPCERT VARCHAR(7)
		,PvdDentalStartDate DATETIME
		,PvdDentalEndDate DATETIME
		,PvdNPINo VARCHAR(10)
		,PvdCMSId VARCHAR(6)
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
		,t.PvdIDNo
		,t.PvdMID
		,t.PvdSource
		,t.PvdTIN
		,t.PvdLicNo
		,t.PvdCertNo
		,t.PvdLastName
		,t.PvdFirstName
		,t.PvdMI
		,t.PvdTitle
		,t.PvdGroup
		,t.PvdAddr1
		,t.PvdAddr2
		,t.PvdCity
		,t.PvdState
		,t.PvdZip
		,t.PvdZipPerf
		,t.PvdPhone
		,t.PvdFAX
		,t.PvdSPC_List
		,t.PvdAuthNo
		,t.PvdSPC_ACD
		,t.PvdUpdateCounter
		,t.PvdPPO_Provider
		,t.PvdFlags
		,t.PvdERRate
		,t.PvdSubNet
		,t.InUse
		,t.PvdStatus
		,t.PvdElectroStartDate
		,t.PvdElectroEndDate
		,t.PvdAccredStartDate
		,t.PvdAccredEndDate
		,t.PvdRehabStartDate
		,t.PvdRehabEndDate
		,t.PvdTraumaStartDate
		,t.PvdTraumaEndDate
		,t.OPCERT
		,t.PvdDentalStartDate
		,t.PvdDentalEndDate
		,t.PvdNPINo
		,t.PvdCMSId
		,t.CreateDate
		,t.LastChangedOn
FROM src.PROVIDER t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PROVIDER
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIDNo = s.PvdIDNo
WHERE t.DmlOperation <> 'D'

$$;


