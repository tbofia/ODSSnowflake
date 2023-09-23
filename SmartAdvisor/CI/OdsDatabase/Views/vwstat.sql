IF OBJECT_ID('adm.ProcessReconciliation', 'V') IS NOT NULL
DROP VIEW adm.ProcessReconciliation
GO

CREATE ViEW adm.ProcessReconciliation 
AS
SELECT DISTINCT PGA.CustomerId
	,PGA.CustomerName
	,P.ProcessId
FROM adm.ProcessAudit PA
INNER JOIN (
	SELECT MAX(PGA.PostingGroupAuditId) MaxPostingGroupAuditId
			,PGA.CustomerId
			,C.CustomerName
	FROM adm.PostingGroupAudit PGA
	INNER JOIN adm.Customer C
	ON PGA.CustomerId = C.CustomerId
	WHERE PGA.Status = 'FI'
		AND C.IsActive = 1
	GROUP BY PGA.CustomerId,C.CustomerName) PGA
ON PA.PostingGroupAuditId = PGA.MaxPostingGroupAuditId
INNER JOIN adm.Process P
ON P.ProcessId = PA.ProcessId
AND P.IsSnapshot <> 1
WHERE PA.TotalRecordsInSource <> PA.TotalRecordsInTarget

GO


IF OBJECT_ID('dbo.ETL_completionstatusbaseline', 'V') IS NOT NULL
DROP VIEW dbo.ETL_completionstatusbaseline
GO

CREATE VIEW dbo.ETL_completionstatusbaseline
AS
-- Distinct dates on which ODS has bee loaded
WITH cte_dates AS(
SELECT DISTINCT CONVERT(VARCHAR(10),SnapshotCreateDate,101) SnapshotDate 
FROM adm.PostingGroupAudit)

-- Distinct Customers with dates on which Completed FullLoads
,cte_customers AS(
SELECT  DISTINCT CONVERT(VARCHAR(10),PGA.SnapshotCreateDate,101) SnapshotCreateDate
	,PGA.CustomerId
	,ROW_NUMBER() OVER(PARTITION BY PGA.CustomerId ORDER BY PGA.SnapshotCreateDate) R_Date -- We want to identify the first full load
FROM adm.PostingGroupAudit PGA
INNER JOIN adm.Customer C
ON PGA.CustomerId = C.CustomerId

WHERE PGA.DataExtractTypeId = 0
	AND C.IsActive = 1)
,cte_customerfullloadstatus AS(
SELECT 
	 D.SnapshotDate
	,C.CustomerId
	,CASE WHEN CAST(CD.SnapshotCreateDate AS DATE) <= CAST(D.SnapshotDate AS DATE) THEN 1 ELSE 0 END AS IsFullLoadCompleted
FROM cte_dates D 
CROSS APPLY (SELECT DISTINCT CustomerId FROM cte_customers) C
LEFT OUTER JOIN cte_customers CD ON C.CustomerId = CD.CustomerId
	AND CD.R_Date = 1)
SELECT DISTINCT C.SnapshotDate
	,C.CustomerId
	,C.IsFullLoadCompleted
	,PGA.OltpPostingGroupAuditId CmpltOltpPostingGroupAuditId
	,PGA2.OltpPostingGroupAuditId InCmpltOltpPostingGroupAuditId
FROM cte_customerfullloadstatus C
-- Completed Posting groups 
LEFT OUTER JOIN adm.PostingGroupAudit PGA
	ON C.CustomerId = PGA.CustomerId
	AND C.SnapshotDate = CONVERT(VARCHAR(10),PGA.SnapshotCreateDate,101)
	AND PGA.Status = 'FI'
-- Posting groups with failures
LEFT OUTER JOIN adm.PostingGroupAudit PGA2
	ON C.CustomerId = PGA2.CustomerId
	AND C.SnapshotDate = CONVERT(VARCHAR(10),PGA2.SnapshotCreateDate,101)
	AND PGA2.Status <> 'FI';



GO


IF OBJECT_ID('dbo.ETL_completionstatusdetail', 'V') IS NOT NULL
DROP VIEW dbo.ETL_completionstatusdetail
GO

CREATE VIEW dbo.ETL_completionstatusdetail
AS
-- Get Last complete Load Date for each customer
WITH cte_lastcompleteload AS(
SELECT   B.CustomerId
		,MAX(CAST(B.SnapshotDate AS DATETIME)) LastestCmpltLoadDate

FROM dbo.ETL_completionstatusbaseline B
INNER JOIN adm.Customer C
	ON B.CustomerId = C.CustomerId

WHERE IsFullLoadCompleted = 1
	AND CmpltOltpPostingGroupAuditId IS NOT NULL 
GROUP BY B.CustomerId),
-- Get The last snapshotdate audited
cte_lastsnapshotaudit AS(
SELECT   B.CustomerId
		,MAX(CAST(B.SnapshotDate AS DATETIME)) LastSnapshotAuditDate

FROM dbo.ETL_completionstatusbaseline B
INNER JOIN adm.Customer C
	ON B.CustomerId = C.CustomerId

WHERE IsFullLoadCompleted = 1
GROUP BY B.CustomerId
),
cte_failurereason AS(
SELECT B.SnapshotDate 
	  ,B.CustomerId
	  ,C.CustomerName
	  ,CASE WHEN ((InCmpltOltpPostingGroupAuditId IS NULL AND CAST(B.SnapshotDate AS DATETIME) < L.LastestCmpltLoadDate) OR (InCmpltOltpPostingGroupAuditId IS NULL AND CAST(B.SnapshotDate AS DATETIME) > L.LastestCmpltLoadDate AND ISNULL(S.Status,'') <> 'S')) AND C.IsLoadedDaily = 1 THEN 1 ELSE 0 END AS OLTPFilesNotCreated
	  ,CASE WHEN ((InCmpltOltpPostingGroupAuditId IS NOT NULL AND CAST(B.SnapshotDate AS DATETIME) < L.LastestCmpltLoadDate) OR (InCmpltOltpPostingGroupAuditId IS NOT NULL AND CAST(B.SnapshotDate AS DATETIME) > L.LastestCmpltLoadDate AND ISNULL(S.Status,'') <> 'S')) AND C.IsLoadedDaily = 1 THEN 1 ELSE 0 END AS ODSLoadFailure
	  ,CASE WHEN InCmpltOltpPostingGroupAuditId IS NULL AND CAST(B.SnapshotDate AS DATETIME) > L.LastestCmpltLoadDate AND ISNULL(S.Status,'') = 'S' AND CAST(B.SnapshotDate AS DATETIME) >= A.LastSnapshotAuditDate  THEN 1 ELSE 0 END AS OLTPFilesqueued
	  ,CASE WHEN InCmpltOltpPostingGroupAuditId IS NOT NULL AND CAST(B.SnapshotDate AS DATETIME) > L.LastestCmpltLoadDate AND ISNULL(S.Status,'') = 'S' AND CAST(B.SnapshotDate AS DATETIME) >= A.LastSnapshotAuditDate THEN 1 ELSE 0 END AS ODSLoadInProgress
FROM dbo.ETL_completionstatusbaseline B
INNER JOIN adm.Customer C
	ON B.CustomerId = C.CustomerId
LEFT OUTER JOIN cte_lastcompleteload L
	ON B.CustomerId = L.CustomerId
LEFT OUTER JOIN cte_lastsnapshotaudit A
	ON B.CustomerId = A.CustomerId
CROSS APPLY (SELECT TOP 1 Status FROM adm.LoadStatus ORDER BY JobRunId DESC) S
	
WHERE IsFullLoadCompleted = 1
	AND CmpltOltpPostingGroupAuditId IS NULL 
)
SELECT 
	 F1.SnapshotDate
	,LTRIM(STUFF((SELECT ', ' + RTRIM(CONVERT(VARCHAR(100),CustomerName))
        FROM   cte_failurereason F2
        WHERE  F1.SnapshotDate = F2.SnapshotDate
        AND F2.OLTPFilesNotCreated = 1
        FOR XML PATH('')),1,1,'')) OLTPFilesNotCreated
    ,LTRIM(STUFF((SELECT ', ' + RTRIM(CONVERT(VARCHAR(100),CustomerName))
        FROM   cte_failurereason F2
        WHERE  F1.SnapshotDate = F2.SnapshotDate
        AND F2.ODSLoadFailure = 1
        FOR XML PATH('')),1,1,'')) ODSLoadFailure
	,LTRIM(STUFF((SELECT ', ' + RTRIM(CONVERT(VARCHAR(100),CustomerName))
        FROM   cte_failurereason F2
        WHERE  F1.SnapshotDate = F2.SnapshotDate
        AND F2.OLTPFilesqueued = 1
        FOR XML PATH('')),1,1,'')) OLTPFilesqueued
    ,LTRIM(STUFF((SELECT ', ' + RTRIM(CONVERT(VARCHAR(100),CustomerName))
        FROM   cte_failurereason F2
        WHERE  F1.SnapshotDate = F2.SnapshotDate
        AND F2.ODSLoadInProgress = 1
        FOR XML PATH('')),1,1,'')) ODSLoadInProgress
FROM cte_failurereason F1
GROUP BY F1.SnapshotDate


GO
IF OBJECT_ID('dbo.ETL_customerdetail', 'V') IS NOT NULL
DROP VIEW dbo.ETL_customerdetail
GO

CREATE VIEW dbo.ETL_customerdetail
AS
WITH cte_NoRecordsLoaded AS(
SELECT PGA.CustomerId
	,PA.ProcessId
	,CONVERT(VARCHAR(10),LoadDate,101) AS LoadDate
	,SUM(CAST(PA.LoadRowCount AS BIGINT)-(CAST(PA.UpdateRowCount AS BIGINT)-CAST(PA.LoadRowCount As BIGINT))) AS NoOfLoadedRecords
FROM adm.ProcessAudit PA 
INNER JOIN adm.PostingGroupAudit PGA
ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId
WHERE PA.Status = 'FI'
	AND PGA.Status = 'FI'
	AND PGA.DataExtractTypeId = 1
GROUP BY PGA.CustomerId
	,PA.ProcessId
	,CONVERT(VARCHAR(10),LoadDate,101))

SELECT PGA.CustomerId
  ,C.CustomerName
  ,MAX(CAST(I.LoadDate AS DATE)) LastIncrementalLoadDate
  ,MAX(CONVERT(VARCHAR(10),PA.LoadDate,101)) LastFullLoadDate
  ,P.TargetTableName
  ,PA.LoadRowCount AS TotalFullLoadRecords
  ,SUM(I.NoOfLoadedRecords) AS TotalNoOfLoadedRecords
      
FROM adm.ProcessAudit PA 
INNER JOIN adm.PostingGroupAudit PGA
ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId
INNER JOIN cte_NoRecordsLoaded I
	ON PGA.CustomerId = I.CustomerId
	AND PA.ProcessId = I.ProcessId
	INNER JOIN adm.Process P
	ON P.ProcessId = PA.ProcessId
INNER JOIN adm.Customer C
ON C.CustomerId = PGA.CustomerId	
WHERE PA.Status = 'FI'
      AND PGA.Status = 'FI'
      AND PGA.DataExtractTypeId = 0
GROUP BY PGA.CustomerId
  ,C.CustomerName
  ,P.TargetTableName
  ,PA.LoadRowCount

GO


IF OBJECT_ID('dbo.ETL_loaddurations', 'V') IS NOT NULL
DROP VIEW dbo.ETL_loaddurations
GO

CREATE VIEW dbo.ETL_loaddurations
AS
SELECT C.CustomerId
	  ,C.CustomerName
	  ,PGA.OltpPostingGroupAuditId
      ,CONVERT(VARCHAR(10),PGA.CreateDate,101) ETLLoadDate
      ,CASE WHEN COUNT(PGA.OltpPostingGroupAuditId) <> SUM(CASE WHEN PGA.Status = 'FI' THEN 1 ELSE 0 END) THEN 0 ELSE 1 END ETLCompletionStatus
      ,DATEDIFF(SS,PGA.CreateDate,PGA.LastChangeDate) AS LoadTime
		
FROM adm.PostingGroupAudit PGA
INNER JOIN adm.Customer C
ON PGA.CustomerId = C.CustomerId
LEFT OUTER JOIN adm.PostingGroupAudit PGA2
	ON PGA.CustomerId = PGA2.CustomerId
	AND PGA.OltpPostingGroupAuditId = PGA2.OltpPostingGroupAuditId
	AND PGA2.Status = 'FI'
WHERE (PGA.Status = 'FI' AND PGA2.Status = 'FI')
OR (PGA2.Status IS NULL)
GROUP By C.CustomerId
	,C.CustomerName
	,PGA.OltpPostingGroupAuditId
	,CONVERT(VARCHAR(10),PGA.CreateDate,101)
	,DATEDIFF(SS,PGA.CreateDate,PGA.LastChangeDate)


GO


IF OBJECT_ID('dbo.ETL_loaddurationsrecordcount', 'V') IS NOT NULL
DROP VIEW dbo.ETL_loaddurationsrecordcount
GO

CREATE VIEW dbo.ETL_loaddurationsrecordcount
AS
SELECT C.CustomerId
	  ,C.CustomerName
	  ,PGA.OltpPostingGroupAuditId
      ,CONVERT(VARCHAR(10),PGA.CreateDate,101) ETLLoadDate
      ,PGA.DataExtractTypeId AS IsIncremental
      ,CASE WHEN PGA.Status = 'FI' AND PA.Status  = 'FI' THEN 1 ELSE 0 END ETLCompletionStatus
      ,PA.ProcessId
      ,P.TargetTableName
      ,DATEDIFF(SS,PA.CreateDate,PA.LoadDate)	LoadTime
	  ,CAST(PA.LoadRowCount AS BIGINT)-(ISNULL(PA.UpdateRowCount,PA.LoadRowCount)-PA.LoadRowCount)	NoRecordsLoaded
	  
FROM adm.PostingGroupAudit PGA
INNER JOIN adm.Customer C
ON PGA.CustomerId = C.CustomerId
LEFT OUTER JOIN adm.PostingGroupAudit PGA2
	ON PGA.CustomerId = PGA2.CustomerId
	AND PGA.SnapshotCreateDate = PGA2.SnapshotCreateDate
	AND PGA2.Status = 'FI'
LEFT OUTER JOIN adm.ProcessAudit PA
	ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId
	AND PA.Status = 'FI'
INNER JOIN adm.Process P
ON PA.ProcessId = P.ProcessId
WHERE (PGA.Status = 'FI' AND PGA2.Status = 'FI')
OR (PGA2.Status IS NULL)


GO



IF OBJECT_ID('dbo.ETL_completionstatus', 'V') IS NOT NULL
DROP VIEW dbo.ETL_completionstatus
GO

CREATE VIEW dbo.ETL_completionstatus
AS
SELECT SnapshotDate AS ETLLoadDate
      ,COUNT(DiSTINCT CASE WHEN IsFullLoadCompleted = 1 THEN Customerid END) NoOfCustomersWithCompletedFullLoads
      ,COUNT(DISTINCT CASE WHEN CmpltOltpPostingGroupAuditId IS NOT NULL OR CmpltOltpPostingGroupAuditId IS NOT NULL THEN Customerid END) NoOfCustomersWithFiles
      ,SUM (CASE WHEN CmpltOltpPostingGroupAuditId IS NOT NULL OR CmpltOltpPostingGroupAuditId IS NOT NULL THEN 1 ELSE 0 END) NoOfPostingGroups
      ,SUM (CASE WHEN CmpltOltpPostingGroupAuditId IS NOT NULL THEN 1 ELSE 0 END) NoOfCompletePostingGroups
      -- When number of files available is not same as number of completed files.
	  ,CASE WHEN SUM (CASE WHEN CmpltOltpPostingGroupAuditId IS NOT NULL OR CmpltOltpPostingGroupAuditId IS NOT NULL THEN 1 ELSE 0 END) <> SUM (CASE WHEN CmpltOltpPostingGroupAuditId IS NOT NULL THEN 1 ELSE 0 END) THEN 0 
	  -- When number of customers with completed fullloads is not same as number of customers with files
			WHEN COUNT (DiSTINCT CASE WHEN IsFullLoadCompleted = 1 THEN Customerid END) > COUNT (DISTINCT CASE WHEN CmpltOltpPostingGroupAuditId IS NOT NULL OR CmpltOltpPostingGroupAuditId IS NOT NULL THEN Customerid END) THEN 2 
			ELSE 1 END ETLCompletionStatus
FROM ETL_completionstatusbaseline
GROUP BY SnapshotDate

GO

