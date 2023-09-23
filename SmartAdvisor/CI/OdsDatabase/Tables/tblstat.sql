IF OBJECT_ID('adm.Customer', 'U') IS NULL
BEGIN
    CREATE TABLE adm.Customer
        (
            CustomerId INT NOT NULL,
			CustomerName VARCHAR(100) NOT NULL,
			SiteCode VARCHAR(25) NOT NULL,
			CustomerDatabase VARCHAR(255) NULL,
			ServerName VARCHAR(255) NULL,
			IsActive BIT NOT NULL,
			IsSelfHosted INT NOT NULL,
			IsFromSmartAdvisor INT NOT NULL,
			IsLoadedDaily INT NOT NULL,
			UseForReporting INT NOT NULL,
			IncludeInIndustry INT NOT NULL
        );

     ALTER TABLE adm.Customer ADD 
	 CONSTRAINT PK_Customer PRIMARY KEY CLUSTERED (CustomerId ASC) ;
    
END
GO

IF OBJECT_ID('adm.DataExtractType', 'U') IS NULL
BEGIN
    CREATE TABLE adm.DataExtractType
        (
            DataExtractTypeId TINYINT NOT NULL ,
            DataExtractTypeName VARCHAR(50) NOT NULL,
			DataExtractTypeCode VARCHAR(4) NOT NULL,
			IsFullExtract	BIT NOT NULL
        );

    ALTER TABLE adm.DataExtractType ADD 
    CONSTRAINT PK_DataExtractType PRIMARY KEY CLUSTERED (DataExtractTypeId);
END
GO
IF OBJECT_ID('adm.PostingGroup', 'U') IS NULL
BEGIN
    CREATE TABLE adm.PostingGroup
        (
            PostingGroupId TINYINT NOT NULL ,
            PostingGroupName VARCHAR(50) NOT NULL
        );

    ALTER TABLE adm.PostingGroup ADD 
    CONSTRAINT PK_PostingGroup PRIMARY KEY CLUSTERED (PostingGroupId);
END
GO
IF OBJECT_ID('adm.Process', 'U') IS NULL
BEGIN
    CREATE TABLE adm.Process
        (
            ProcessId SMALLINT NOT NULL ,
            ProcessDescription VARCHAR(100) NOT NULL ,
            TargetSchemaName VARCHAR(10) NOT NULL ,
            TargetTableName VARCHAR(100) NOT NULL ,
            ProductKey VARCHAR(100) NOT NULL,
            FileColumnDelimiter VARCHAR(2) NOT NULL,
            PostingGroupId INT NOT NULL ,
            LoadGroup INT NOT NULL ,
            HashFunctionType INT NOT NULL ,
            IsActive BIT NOT NULL ,
            IsSnapshot BIT NOT NULL
        );

    ALTER TABLE adm.Process ADD 
    CONSTRAINT PK_EtlProcess PRIMARY KEY CLUSTERED (ProcessId);
END
GO
IF OBJECT_ID('adm.Product', 'U') IS NULL
BEGIN
    CREATE TABLE adm.Product
        (
            ProductKey VARCHAR(100) NOT NULL ,
            Name VARCHAR(100) NOT NULL ,
            SchemaName VARCHAR(10) NOT NULL
        );

    ALTER TABLE adm.Product ADD 
    CONSTRAINT PK_EtlProduct PRIMARY KEY CLUSTERED (ProductKey);
END
GO

IF OBJECT_ID('adm.StatusCode', 'U') IS NULL
BEGIN
    CREATE TABLE adm.StatusCode
        (
            Status VARCHAR(2) NOT NULL ,
            ShortDescription VARCHAR(100) NOT NULL ,
            LongDescription VARCHAR(MAX) NOT NULL 
			        );

    ALTER TABLE adm.StatusCode ADD 
    CONSTRAINT PK_StatusCode PRIMARY KEY CLUSTERED (Status);
END
GO

-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'adm.Customer')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'AcsOds customers',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Customer')
		AND ep.name = N'MS_Description'
		AND c.name = N'CustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Customer')
		AND ep.name = N'MS_Description'
		AND c.name = N'CustomerName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Name of customer',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerName' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Customer')
		AND ep.name = N'MS_Description'
		AND c.name = N'CustomerDatabase' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerDatabase' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Name of customers production database',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerDatabase' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Customer')
		AND ep.name = N'MS_Description'
		AND c.name = N'IsActive' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsActive' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit signals whether customer is currently active',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsActive' --Column Name

GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'adm.DataExtractType')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Types of data extracts supported by the ODS',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.DataExtractType')
		AND ep.name = N'MS_Description'
		AND c.name = N'DataExtractTypeId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.DataExtractType')
		AND ep.name = N'MS_Description'
		AND c.name = N'DataExtractTypeName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Data extract description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeName' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.DataExtractType')
		AND ep.name = N'MS_Description'
		AND c.name = N'DataExtractTypeCode' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeCode' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Alternate key.  This code is included in the control file name.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeCode' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.DataExtractType')
		AND ep.name = N'MS_Description'
		AND c.name = N'IsFullExtract' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsFullExtract' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'When true, files will include all records.  When false, files will only include records that may have changed since the last incremental run.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsFullExtract' --Column Name

GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroup')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroup' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'A logical grouping of tables that have to be loaded together.  They represent the same point in time.',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroup' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.PostingGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Name of posting group.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupName' --Column Name

GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Stores information on each file to be loaded',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessDescription' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessDescription' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Description of process',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessDescription' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'TargetSchemaName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'TargetSchemaName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Schema of the table that stores this data',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'TargetSchemaName' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'TargetTableName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'TargetTableName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Name of the table that stores this data',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'TargetTableName' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroup',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'LoadGroup' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadGroup' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Within a posting group, processes are broken into load groups that run concurrently.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadGroup' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'HashFunctionType' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'HashFunctionType' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'SHA1 (1) or MD5 (2)',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'HashFunctionType' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'IsActive' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsActive' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this process is active',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsActive' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'IsSnapshot' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsSnapshot' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'If true, incremental files include the entire table; that is, we have to derive the changes by comparing to the last state of this table.  We have to do this for tables that cant use change tracking (dev and HIM static tables).',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsSnapshot' --Column Name

GO

