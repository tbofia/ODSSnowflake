
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'adm.Rep_RemovePIIData') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE adm.Rep_RemovePIIData
GO 


CREATE PROCEDURE adm.Rep_RemovePIIData(
@OdsCustomerId INT = 0,
@IsIncremental INT,
@ProcessId INT,
@DBSnapshotName VARCHAR(255) = NULL,
@OdsCutoffPostingGroupAuditId INT,
@OdsMaxPostingGroupAuditId INT,
@FileSize INT,
@SQLSelect VARCHAR(MAX) OUTPUT,
@NumberOfBatches INT OUTPUT)
AS
BEGIN
DECLARE  @srcColumnList VARCHAR(MAX)
		,@TargetTableName VARCHAR(255)
		,@TargetSchemaName VARCHAR(50)
		,@BatchColumnName VARCHAR(128)
		,@BatchColumnType VARCHAR(50)
		,@ColQuery VARCHAR(MAX)
		,@BatchQuery NVARCHAR(MAX)
		,@BatchColumnQuery NVARCHAR(2000)
		,@TableSQL NVARCHAR(1000)
		,@SchemaSQL NVARCHAR(1000)
		,@DBName VARCHAR(255) = DB_NAME()
		,@FileSizeQuery NVARCHAR(MAX)

	--Variable to hold data types used for replacing CRLF
DECLARE @Char VARCHAR(10) = 'CHAR'
		,@NChar VARCHAR(10) = 'NCHAR'
		,@VarChar VARCHAR(10) = 'VARCHAR'
		,@NVarChar VARCHAR(10) = 'NVARCHAR'
		,@Text VARCHAR(10) = 'TEXT'
		,@NText VARCHAR(10) = 'NTEXT'

	IF OBJECT_ID('tempdb..#ColumnLists') IS NOT NULL DROP TABLE #ColumnLists
		CREATE TABLE #ColumnLists(
		TABLE_NAME VARCHAR(50),
		COLUMN_NAME VARCHAR(150),
		ORDINAL_POSITION INT,
		TABLE_SCHEMA VARCHAR(10)
		); 		

	IF OBJECT_ID('tempdb..#FileSize') IS NOT NULL DROP TABLE #FileSize
		CREATE TABLE #FileSize(
		TableName VARCHAR(25),
		TotalRows INT,
		TotalSpaceAllocated VARCHAR(500),
		TotalSpaceUsed VARCHAR(500),
		TotalSpaceforIndex VARCHAR(500),
		TotalUnusedSpace VARCHAR(500)
		)


	SET @TableSQL  = 'SELECT @TargetTableName =  TargetTableName 
					  FROM '+@DBSnapshotName+'.adm.Process
					  WHERE ProcessId = '+CAST(@ProcessId AS VARCHAR(10))

	EXEC sys.sp_executesql @TableSQL, N'@TargetTableName VARCHAR(1000) OUTPUT, @DBSnapshotName VARCHAR(255), @ProcessId INT'
						, @DBSnapshotName = @DBSnapshotName
						, @ProcessId = @ProcessId
						, @TargetTableName = @TargetTableName OUTPUT

	SET @SchemaSQL = 'SELECT @TargetSchemaName =  TargetSchemaName 
					  FROM '+@DBSnapshotName+'.adm.Process 
					  WHERE ProcessId = '+CAST(@ProcessId AS VARCHAR(10))

	EXEC sys.sp_executesql @SchemaSQL, N'@TargetSchemaName VARCHAR(1000) OUTPUT, @DBSnapshotName VARCHAR(255), @ProcessId INT' 
						, @DBSnapshotName = @DBSnapshotName
						, @ProcessId = @ProcessId
						, @TargetSchemaName = @TargetSchemaName OUTPUT

	SET @TargetSchemaName = CASE WHEN @TargetSchemaName = 'rpt' THEN 'adm' ELSE @TargetSchemaName END



	SET @ColQuery = 'SELECT DISTINCT C.TABLE_NAME, 
								CASE WHEN PC.HoldsPII = 1 THEN 
												CASE WHEN C.DATA_TYPE IN ('''+@Char+''','''+@NChar+'''
																		 ,'''+@VarChar+''' ,'''+@NVarChar+'''
																		 ,'''+@Text+''','''+@NText+''') 
															THEN ISNULL(REPLACE(REPLACE(PC.ObfuscateWithValue, CHAR(13), ''''), CHAR(10), '''') + '' AS '' + C.COLUMN_NAME,''NULL AS '' + C.COLUMN_NAME) 
													ELSE ISNULL(PC.ObfuscateWithValue+ '' AS '' + C.COLUMN_NAME,''NULL  AS '' + C.COLUMN_NAME) 
												END
									ELSE 
												CASE WHEN C.DATA_TYPE IN ('''+@Char+''','''+@NChar+'''
																		 ,'''+@VarChar+''' ,'''+@NVarChar+'''
																		 ,'''+@Text+''','''+@NText+''')
															THEN ''REPLACE(REPLACE(''+C.COLUMN_NAME+'', CHAR(13), ''''''''), CHAR(10), '''''''')  AS '' + C.COLUMN_NAME 
													ELSE C.COLUMN_NAME 
												END 
								END ,
								C.ORDINAL_POSITION, C.TABLE_SCHEMA
					FROM '+@DBSnapshotName+'.INFORMATION_SCHEMA.COLUMNS C 
					LEFT OUTER JOIN '+@DBSnapshotName+'.adm.Process P ON C.TABLE_NAME = P.TargetTableName
					LEFT OUTER JOIN '+@DBName+'.adm.ProcessColumn PC ON P.ProcessId = PC.ProcessId AND C.COLUMN_NAME = PC.ColumnName 
					WHERE TABLE_SCHEMA = '''+@TargetSchemaName+ ''' 
							AND TABLE_NAME = '''+@TargetTableName+ ''' 
							AND (ORDINAL_POSITION <= 7 OR PC.ColumnName IS NOT NULL)
							AND P.ProcessId = '+CAST(@ProcessId AS VARCHAR(10))+ ' 
					ORDER BY ORDINAL_POSITION'; 
	
	
	INSERT INTO #ColumnLists
	EXEC (@ColQuery)
	
	-- We are filtering PII for some columns based on functions, eg. CmtLastName & PolicyNumber
	-- For those, BCP require database name appended to function call in Queryout
	-- So updating column name to append database name where ObfuscateWithValue column is function call under adm.ProcessColumn table.
	
	UPDATE #ColumnLists
	SET COLUMN_NAME = @DBName+'.'+COLUMN_NAME
	WHERE COLUMN_NAME LIKE 'dbo.%'

	SELECT @srcColumnList =  COALESCE(@srcColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',','')+ COLUMN_NAME
	FROM #ColumnLists C 
	ORDER BY ORDINAL_POSITION;	

	IF @IsIncremental = 0
		BEGIN
			--dividing file size by 3 because that will expand 3 times after extracted to flat file
			SET @BatchQuery = 'SELECT @NumberOfBatches = CASE WHEN (((SUM(a.used_pages) * 8) / 1024))>'+CAST(@FileSize/3 AS VARCHAR(5))+' 
																	THEN ((((SUM(a.used_pages) * 8) / 1024))/'+CAST(@FileSize/3 AS VARCHAR(5))+'+1)
															  ELSE 1 
														 END
								FROM '+@DBSnapshotName+'.adm.process pr	
								INNER JOIN  '+@DBSnapshotName+'.sys.tables t ON t.Name = pr.TargetTableName	
								INNER JOIN  '+@DBSnapshotName+'.sys.indexes i ON t.OBJECT_ID = i.object_id
								INNER JOIN  '+@DBSnapshotName+'.sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id 
								INNER JOIN  '+@DBSnapshotName+'.sys.allocation_units a ON p.partition_id = a.container_id
								LEFT OUTER JOIN  '+@DBSnapshotName+'.sys.schemas s ON t.schema_id = s.schema_id	
								WHERE s.Name = '''+@TargetSchemaName+''' AND pr.ProcessId = '+CAST(@ProcessId AS VARCHAR(10))+'
								AND p.partition_id = CASE WHEN '+CAST(@OdsCustomerId AS VARCHAR(2))+'= 0 THEN p.partition_id 
														  ELSE '+CAST(@OdsCustomerId AS VARCHAR(2))+' 
													 END'
			EXEC sys.sp_executesql @BatchQuery, N'@FileSize INT,@OdsCustomerId INT, @TargetSchemaName VARCHAR(15), @NumberOfBatches INT OUTPUT', 
									@FileSize = @FileSize,
									@OdsCustomerId = @OdsCustomerId, 
									@TargetSchemaName = @TargetSchemaName,
									@NumberOfBatches = @NumberOfBatches OUTPUT
		END
	ELSE
		BEGIN
			SET @FileSizeQuery = 
						CASE WHEN @TargetSchemaName = 'adm' 
									THEN 'USE tempdb
										  SELECT * INTO #TableTemp 
										  FROM '+@DBSnapshotName+'.'+@TargetSchemaName+'.'+@TargetTableName+' 
										  WHERE PostingGroupAuditId > '+CAST(@OdsCutoffPostingGroupAuditId AS VARCHAR(15))+'; 

										  INSERT INTO #FileSize 
										  EXEC sp_spaceused ''#TableTemp'';'
							 ELSE
										'USE tempdb
										 SELECT * INTO #TableTemp 
										 FROM '+@DBSnapshotName+'.'+@TargetSchemaName+'.'+@TargetTableName+' 
										 WHERE OdsPostingGroupAuditId > '+CAST(@OdsCutoffPostingGroupAuditId AS VARCHAR(15))+'; 

										 INSERT INTO #FileSize 
										 EXEC sp_spaceused ''#TableTemp'';' 
						END

		EXEC sp_executesql @FileSizeQuery

		SELECT @NumberOfBatches = CASE WHEN ((LEFT(TotalSpaceUsed,LEN(TotalspaceUsed)-3))/1024) > @FileSize 
											THEN (((LEFT(TotalSpaceUsed,LEN(TotalspaceUsed)-3))/1024)/@FileSize) + 1
									ELSE 1 
									END 
		FROM #FileSize

	END

	SET @BatchColumnQuery = 'SELECT @BatchColumnName  = C.ColumnName , @BatchColumnType = I.DATA_TYPE
							FROM '+@DBName+'.adm.ProcessColumn C
							INNER JOIN '+@DBSnapshotName+'.adm.Process P 
							ON C.ProcessId = P.ProcessId
							INNER JOIN '+@DBSnapshotName+'.INFORMATION_SCHEMA.COLUMNS I
							ON I.TABLE_NAME = P.TargetTableName
							AND I.COLUMN_NAME = C.ColumnName
							AND I.TABLE_SCHEMA = '''+@TargetSchemaName+ '''
							WHERE C.ProcessId = '+CAST(@ProcessId AS VARCHAR(10))+' 
								  AND C.UseForBatchProcessing = 1'

	EXEC sys.sp_executesql @BatchColumnQuery, N'@BatchColumnName VARCHAR(100) OUTPUT, @BatchColumnType VARCHAR(50) OUTPUT'
						, @BatchColumnName = @BatchColumnName OUTPUT
						, @BatchColumnType = @BatchColumnType OUTPUT;

	SET @NumberOfBatches = CASE WHEN ISNULL(@NumberOfBatches,0) < 2 THEN 0
								--When We don't have column for splitting, we'll create single big extract file.
								WHEN @BatchColumnName IS NULL THEN 0
								ELSE @NumberOfBatches 
						   END

	SET @SQLSelect = CASE WHEN @TargetSchemaName = 'adm' 
								THEN 'SELECT '+@srcColumnList+CHAR(13)+CHAR(10)+'
									  FROM '+@DBSnapshotName+'.'+@TargetSchemaName+'.'+@TargetTableName +
									CASE WHEN @NumberOfBatches > 0 
											THEN CHAR(13)+CHAR(10)+'
											WHERE ABS(CAST('+@BatchColumnName+' AS INT)  % '+CAST(@NumberOfBatches AS VARCHAR(5))+' = <BatchId> 
											AND PostingGroupAuditId > '+CAST(@OdsCutoffPostingGroupAuditId AS VARCHAR(10))+' AND PostingGroupAuditId <= '+CAST(@OdsMaxPostingGroupAuditId AS VARCHAR(10))
										WHEN @NumberOfBatches = 0 THEN ' WHERE PostingGroupAuditId > '+CAST(@OdsCutoffPostingGroupAuditId AS VARCHAR(10)) +' AND PostingGroupAuditId <= '+CAST(@OdsMaxPostingGroupAuditId AS VARCHAR(10))
									END
						 ELSE
							'SELECT '+@srcColumnList+CHAR(13)+CHAR(10)+'
								FROM '+@DBSnapshotName+'.'+@TargetSchemaName+'.'+@TargetTableName +
							CASE WHEN @NumberOfBatches > 0 
									THEN 
									CHAR(13)+CHAR(10)+'WHERE ' + 'ABS('+CASE WHEN @BatchColumnType IN ('INT','TINYINT','SMALLINT','BIGINT') THEN @BatchColumnName ELSE 'ABS(CAST(HASHBYTES(''MD5'', '+@BatchColumnName+') AS INT))' END +')  % '+CAST(@NumberOfBatches AS VARCHAR(5))+' = <BatchId> 
									 AND OdsPostingGroupAuditId > '+CAST(@OdsCutoffPostingGroupAuditId AS VARCHAR(10)) +' AND OdsPostingGroupAuditId <= '+CAST(@OdsMaxPostingGroupAuditId AS VARCHAR(10)) 
								WHEN @NumberOfBatches = 0 
									THEN 
									CHAR(13)+CHAR(10)+'WHERE OdsPostingGroupAuditId > '+CAST(@OdsCutoffPostingGroupAuditId AS VARCHAR(10)) +' AND OdsPostingGroupAuditId <= '+CAST(@OdsMaxPostingGroupAuditId AS VARCHAR(10)) 
							END
					END

	END



GO


