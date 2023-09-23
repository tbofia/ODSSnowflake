IF NOT EXISTS ( SELECT  system_type_id
                FROM    sys.types
                WHERE   name = 'IntegerTable'
                        AND is_user_defined = 1 )
    CREATE TYPE dbo.IntegerTable AS TABLE ( 
    Id INT NOT NULL
    )
GO

GRANT EXECUTE ON TYPE::dbo.IntegerTable TO MedicalUserRole
GO
IF NOT EXISTS ( SELECT  system_type_id
                FROM    sys.types
                WHERE   name = 'KeyValuePairTable'
                        AND is_user_defined = 1 )
    CREATE TYPE dbo.KeyValuePairTable AS TABLE ( 
    [Key] INT NOT NULL, 
    [Value] VARCHAR(255) NOT NULL
    )
GO
IF NOT EXISTS ( SELECT  system_type_id
            FROM    sys.types
            WHERE   name = 'VarcharTable'
                    AND is_user_defined = 1 )
    CREATE TYPE dbo.VarcharTable AS TABLE ( 
    Code VARCHAR(255) NOT NULL
    )
GO

GRANT EXECUTE ON TYPE::dbo.VarcharTable TO MedicalUserRole
GO
