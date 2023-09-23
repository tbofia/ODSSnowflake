DECLARE @AppVer VARCHAR(10)
SET @AppVer = '1.2.0.0'

INSERT  INTO adm.AppVersion
        ( AppVersion, AppVersionDate )
VALUES  ( @AppVer, GETDATE() )

GO
