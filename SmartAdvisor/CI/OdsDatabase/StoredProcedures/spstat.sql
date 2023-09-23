IF OBJECT_ID('adm.Mnt_SendNotification', 'P') IS NOT NULL
    DROP PROCEDURE adm.Mnt_SendNotification
GO
CREATE PROCEDURE adm.Mnt_SendNotification(
@Rundate DATETIME,
@ReportURL VARCHAR(MAX),
@recipients_param VARCHAR(100))
AS
BEGIN
-- DECLARE @ReportURL VARCHAR(MAX) = '',@recipients_param VARCHAR(100) = 'theodore.bofia@mitchell.com',@Rundate DATETIME = '02/11/2019';
DECLARE @SnapshotDate VARCHAR(12) = CONVERT(VARCHAR(10),@Rundate,101);
DECLARE  
		 @StatusList VARCHAR(MAX)
		,@ReconciliationCustomers VARCHAR(MAX)
		,@NoOfActiveCustomers INT
		,@NoCustomerLoadedDaily INT
		,@NoOfCompletedCustomers INT
		,@NoOfCompletePostingGroups INT
		,@NoOfCustomersWithNoFileDumps INT
		,@NoOfCustomersWithFailedLoads INT;

DECLARE @tableHTML  NVARCHAR(MAX);

DECLARE @EmailHeader VARCHAR(1000) = 
	N'	<B><H1><font FONT FACE="VERDANA" SIZE=4 color="#154360">Header1Text</font></H1></B>
		<H2><font face="VERDANA" size= 2 color = "000080">Header2Text</font></H2> '
DECLARE @EmailFooter VARCHAR(1000) =N'<br><br><FONT FACE="VERDANA" SIZE=1 COLOR="BLUE">***************** This is an auto generated mail. Please do not reply *****************</FONT>';
	    
DECLARE @EmailStyle VARCHAR(MAX) = '<style type="text/css">  #box-table  {  font-family:"Palatino Linotype", "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;  font-size: 12px; }  #box-table th  {  font-family:"VERDANA"  font-size: 13px;  font-weight: normal;  background: "#8E44AD";  color: #fff;    }  #box-table td  {  color: black;  }  tr:nth-child(odd) { background-color:#CCCCCC; }  tr:nth-child(even) { background-color:#FFFFFF; }   </style>';

BEGIN
	

SELECT  
	 @NoOfActiveCustomers = S.NoOfCustomersWithCompletedFullLoads
	,@NoCustomerLoadedDaily = COUNT(DISTINCT CASE WHEN C.IsLoadedDaily = 1 THEN B.CustomerId END)
	,@NoOfCompletedCustomers = COUNT(DISTINCT CASE WHEN B.CmpltOltpPostingGroupAuditId IS NOT NULL THEN B.CustomerId END)
	,@NoOfCompletePostingGroups = S.NoOfCompletePostingGroups
	,@NoOfCustomersWithNoFileDumps = COUNT(DISTINCT CASE WHEN IsFullLoadCompleted = 1 AND InCmpltOltpPostingGroupAuditId IS NULL AND CmpltOltpPostingGroupAuditId IS NULL THEN B.CustomerId END) - COUNT(DISTINCT CASE WHEN C.IsLoadedDaily = 0 THEN B.CustomerId END)
	,@NoOfCustomersWithFailedLoads = COUNT(DISTINCT CASE WHEN IsFullLoadCompleted = 1 AND InCmpltOltpPostingGroupAuditId IS NOT NULL AND CmpltOltpPostingGroupAuditId IS NULL THEN B.CustomerId END) 

FROM dbo.ETL_completionstatus S
INNER JOIN dbo.ETL_completionstatusbaseline B
	ON S.ETLLoadDate = B.SnapshotDate
INNER JOIN adm.Customer C
	ON C.CustomerId = B.CustomerId
WHERE S.ETLLoadDate = @SnapshotDate
GROUP BY S.NoOfCustomersWithCompletedFullLoads,S.NoOfCompletePostingGroups

-- Get Status For Customers Not Loaded Daily
SELECT 
	@StatusList = COALESCE(@StatusList+', ','')+CustomerName+' '+CONVERT(VARCHAR(10),MAX(P.SnapshotCreateDate),101)+' <b>('+CASE WHEN MAX(P.Status) = 'FI' THEN MAX(P.Status) ELSE '<font color="Red">'+MAX(P.Status)+'</font>' END+')</b>'

FROM adm.Customer C
INNER JOIN adm.PostingGroupAudit P
ON C.CustomerId = P.CustomerId
WHERE C.IsActive = 1
	AND C.IsLoadedDaily = 0
GROUP BY CustomerName
ORDER BY CustomerName;

-- Get List Of Customers that need reconciliation
SELECT @ReconciliationCustomers = COALESCE(@ReconciliationCustomers+', ','')+S.CustomerName
FROM(SELECT DISTINCT PGA.CustomerName
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
	WHERE PA.TotalRecordsInSource <> PA.TotalRecordsInTarget) AS S
ORDER BY S.CustomerName

SET @tableHTML = @EmailStyle +
@EmailHeader+
    N'<table>' +
    N'<tr>'+
		N'<th><b>Summary Description </b></th>' +
		N'<th><b>Summary Value </b></th>
    </tr>' +
    N'<tr>'+
		N'<td>Active Customers</td>' +
		N'<td>'+CAST(@NoOfActiveCustomers AS VARCHAR(3))+'</td>
    </tr>' +
	N'<tr>'+
		N'<td>Customers Scheduled Daily</td>' +
		N'<td>'+CAST(@NoCustomerLoadedDaily AS VARCHAR(3))+'</td>
    </tr>' +
	N'<tr>'+
		N'<td>Customers Loaded Successfully</td>' +
		N'<td>'+CAST(@NoOfCompletedCustomers AS VARCHAR(3))+'</td>
    </tr>' +
	N'<tr>'+
		N'<td>PostingGroups Loaded Successfully</td>' +
		N'<td>'+CAST(@NoOfCompletePostingGroups AS VARCHAR(3))+'</td>
    </tr>' +
	N'<tr>'+
		N'<td>Customers With No File Dumps</td>' +
		N'<td>'+CAST(@NoOfCustomersWithNoFileDumps AS VARCHAR(3))+'</td>
    </tr>' +
	N'<tr>'+
		N'<td>Customers With Failed Loads</td>' +
		N'<td>'+CAST(@NoOfCustomersWithFailedLoads AS VARCHAR(3))+'</td>
    </tr>' +

	N'</table>'+
	N'<br><font color="#154360">Status of customers <b>NOT</b> loaded Daily: <i>'+ISNULL(@StatusList,'')+'</font></i>'+
	N'<br><br><font color="#154360">Customer[s] needing data reconciliation:</font> <i><font color="Red">'+ISNULL(@ReconciliationCustomers,'')+'</font></i>'+
@EmailFooter;

SET @tableHTML = REPLACE(@tableHTML,'<table>','<table id="box-table">');
SET @tableHTML = REPLACE(@tableHTML,'<tr>','<tr BGCOLOR="#E8DAEF">');        
SET @tableHTML = REPLACE(@tableHTML,'Header1Text','WcsOds Job Status: Run Completed.'); 
SET @tableHTML = REPLACE(@tableHTML,'<font FONT FACE="VERDANA" SIZE=4 color="000080">','<font FONT FACE="VERDANA" SIZE=4 color="006400">')
SET @tableHTML = REPLACE(@tableHTML,'Header2Text','<a href='+@ReportURL+'> View Load Statistics Reports!</a>');	
	
EXEC msdb.dbo.sp_send_dbmail @recipients= @recipients_param,
@subject = 'WcsOds Load Status Update.',
@body = @tableHTML,
@body_format = 'HTML' ;
END

END

GO
IF OBJECT_ID('adm.Mnt_SwitchPartitionOut', 'P') IS NOT NULL
    DROP PROCEDURE adm.Mnt_SwitchPartitionOut
GO
CREATE PROCEDURE adm.Mnt_SwitchPartitionOut(
@ProcessId INT,
@CustomerId INT,
@returnstatus INT = 1 OUTPUT)
AS
BEGIN
-- DECLARE @ProcessId INT = 6, @CustomerId INT = 42, @returnstatus INT = 1

DECLARE  @SQLScript VARCHAR(MAX)
		,@TargetSchemaName CHAR(3) = N'src'
		,@StagingSchemaName CHAR(3) = N'stg'
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)	;

-- Create schema, note: Schema will be created only if it does not exist.
EXEC adm.Etl_CreateUnpartitionedTableSchema @CustomerId, @ProcessId,1,@returnstatus = @returnstatus OUTPUT

-- Creates Indexes on empty unpartitionned table, note: Indexes will be created only if they do no alreday exist
EXEC adm.Etl_CreateUnpartitionedTableIndexes @CustomerId,@ProcessId,@returnstatus = @returnstatus OUTPUT

-- Switch customer data into empty table,Note: Switch only happens if the table is empty
EXEC adm.Etl_SwitchUnpartitionedTable @CustomerId, @ProcessId,'',1,@returnstatus = @returnstatus OUTPUT

END

GO 
  
IF OBJECT_ID('adm.Mnt_UpdateStatistics', 'P') IS NOT NULL
    DROP PROCEDURE adm.Mnt_UpdateStatistics
GO
CREATE PROCEDURE adm.Mnt_UpdateStatistics(
@OdsCustomerId INT  = 0,
@ProcessId INT = 0)
AS
BEGIN
-- DECLARE @OdsCustomerId INT  = 0, @ProcessId INT = 5
-- Get Target table name for given process
DECLARE  @SQLQuery VARCHAR(MAX)
		,@Command VARCHAR(MAX)
		,@TargetTableName VARCHAR(100) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)
		,@TargetSchemaName VARCHAR(100) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)


IF (@OdsCustomerId = 0) 
BEGIN 
	IF(@TargetTableName IS NULL) -- -- All Customers, All Active Tables
	BEGIN TRY
		SET @Command = '
		IF EXISTS(SELECT 1 FROM adm.Process WHERE OBJECT_ID(TargetSchemaName+''.''+TargetTableName) = OBJECT_ID(''?'')  AND IsActive = 1) -- Test is Table is Active
		BEGIN
			UPDATE STATISTICS ? WITH FULLSCAN;
		END';
		EXEC sp_MSforeachtable @command1=@Command,@whereand='and Schema_id=Schema_id(''src'')';
	END TRY
	BEGIN CATCH
		PRINT 'Could Not Update Statistics for ALL...Make sure you have the right permissions.';
	END CATCH

	ELSE -- All Customers, Specified Table
	BEGIN TRY
		SET @SQLQuery = 'UPDATE STATISTICS src.'+@TargetTableName+' WITH FULLSCAN;'
		EXEC (@SQLQuery);
	END TRY
	BEGIN CATCH
		PRINT 'Could Not Update Statistics for scr.'+@TargetTableName+'...Make sure you have the right permissions.';
	END CATCH

END
ELSE
BEGIN 
	IF(@TargetTableName IS NULL) -- -- Specified Customer, All Active Tables
	BEGIN TRY
		SET @Command = '
		DECLARE  @IX_Name VARCHAR(255);
		IF EXISTS(SELECT 1 FROM adm.Process WHERE OBJECT_ID(TargetSchemaName+''.''+TargetTableName) = OBJECT_ID(''?'')  AND IsActive = 1)
		BEGIN
			SELECT @IX_Name = I.name -- Get Clustered Index Name
			FROM sys.indexes I
			WHERE I.object_id = OBJECT_ID(''?'')
			AND I.type = 1;
			EXEC (''UPDATE STATISTICS ?(''+@IX_Name+'') WITH RESAMPLE ON PARTITIONS('+CAST(@OdsCustomerId AS VARCHAR(100))+')'');
		END';
		EXEC sp_MSforeachtable @command1=@Command,@whereand='and Schema_id=Schema_id(''src'')';
	END TRY
	BEGIN CATCH
		PRINT 'Could Not Update Statistics for All Tables for customer '+CAST(@OdsCustomerId AS VARCHAR(100))+'...Make sure you have the right permissions.';
	END CATCH
	ELSE 
	BEGIN TRY -- SPecified Customer, Specified Table
		DECLARE  @IX_Name VARCHAR(255);
		SELECT @IX_Name = I.name 
		FROM sys.indexes I
		WHERE I.object_id = OBJECT_ID(@TargetSchemaName+'.'+@TargetTableName)
		AND I.type = 1;
		SET @SQLQuery ='UPDATE STATISTICS '+@TargetSchemaName+'.'+@TargetTableName+'('+@IX_Name+') WITH RESAMPLE ON PARTITIONS('+CAST(@OdsCustomerId AS VARCHAR(100))+')';
		EXEC(@SQLQuery);
	END TRY
	BEGIN CATCH
		PRINT 'Could Not Update Statistics for scr.'+@TargetTableName+' for customer '+CAST(@OdsCustomerId AS VARCHAR(100))+'...Make sure you have the right permissions.';
	END CATCH
END 

END

GO
