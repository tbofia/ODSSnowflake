
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'adm.Rep_GenerateControlFile') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE adm.Rep_GenerateControlFile
GO 


CREATE PROCEDURE adm.Rep_GenerateControlFile
(
@ReplicationAuditId INT,
@OutputPath VARCHAR(255),
@FileExtension VARCHAR(5),
@SourceDatabase VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON
DECLARE @FileName VARCHAR(100)  
	,@CFileExtension VARCHAR(4) = 'ctl' 
	,@FileColumnDelimiter VARCHAR(2) = ',' 
	,@AcsOdsVersion VARCHAR(10) 
	,@DatabaseName VARCHAR(100) = DB_NAME()
	,@SnapshotServer VARCHAR(100) = @@SERVERNAME
	,@BcpCommand VARCHAR(8000)
	,@SourceQuery VARCHAR(MAX)
	,@PreviousReplicationAuditId INT		
		
	IF OBJECT_ID('tempdb..#CPromptOutput') IS NOT NULL DROP TABLE #CPromptOutput
	CREATE TABLE #CPromptOutput
		(
        CommandPromptOutputId INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED ,
        ResultText VARCHAR(MAX)
		);
	 -- Creating control file name
	SELECT @FileName = SnapshotName + '_' 
					+ RIGHT('0000000000' + CAST(OdsCutoffPostingGroupAuditId AS VARCHAR(10)), 10) + '_' 
					+  CASE WHEN DataExtractTypeId = 0 THEN 'FULL' 
							WHEN DataExtractTypeId = 1 THEN 'INCR' 
						END		
    FROM    adm.PostingGroupReplicationAudit 
	WHERE   ReplicationAuditId = @ReplicationAuditId;
	
	SELECT @PreviousReplicationAuditId = ISNULL(MAX(ReplicationAuditId),-1) 
	FROM adm.PostingGroupReplicationAudit 
	WHERE Status = 'FI' 
		AND ReplicationAuditId < @ReplicationAuditId

		-- Let's get all details that need in control file
	SET @SourceQuery = 
	'SELECT  ''' +@FileName+'.ctl'+ ''' 
			, pr.ProductName
			,CASE WHEN pr.DataExtractTypeId = 0 THEN ''FULL'' 
				  WHEN pr.DataExtractTypeId = 1 THEN ''INCR'' 
				END
	,pr.OdsCutoffPostingGroupAuditId
	, pr.SnapshotDate
	, pa.SourceTableName
	, pa.TotalNumberOfFiles
	,pf.FileNumber
	, '''+@FileName+'_'+'''+pa.SourceTableName+'''+'_''
		+CAST(pf.FileNumber AS VARCHAR(10))+'+'''.'+@FileExtension+'''
	, pf.TotalRecordsInFile
	, pa.TotalRecordsInSource
	, pr.ReplicationAuditId
	, CASE WHEN pr.DataExtractTypeId = 0 THEN -1 ELSE '+CAST(@PreviousReplicationAuditId AS VARCHAR(15))+' END
	,pr.OdsVersion
	,FileSize 	
	FROM '+@DatabaseName+'.adm.PostingGroupReplicationAudit pr 
	INNER JOIN '+@DatabaseName+'.adm.ProcessReplicationAudit pa
								ON pr.ReplicationAuditId = pa.ReplicationAuditId
	INNER JOIN '+@SourceDatabase+'.adm.Process p ON p.ProcessId = pa.ProcessId AND p.IsActive = 1
	INNER JOIN '+@DatabaseName+'.adm.ProcessFileReplicationAudit pf 
								ON pa.ProcessReplicationAuditId = pf.ProcessReplicationAuditId
	WHERE pr.ReplicationAuditId = '+CAST(@ReplicationAuditId AS VARCHAR(10))+' 
		AND pa.Status <> ''S'' 
		AND pf.Status <> ''S'''
			
	-- BCP command to export control file data
	SET @BcpCommand = 'bcp "' +REPLACE(REPLACE(@SourceQuery, CHAR(13), ' '), CHAR(10), ' ') + -- newlines are causing issues for bcp
			'" queryout ' + @OutputPath + @FileName+ '.' + @CFileExtension + ' -c -t "' + @FileColumnDelimiter + '" -S ' + @SnapshotServer + ' -T';


	INSERT  INTO #CPromptOutput
	EXEC master.sys.xp_cmdshell @BcpCommand;
END


GO


