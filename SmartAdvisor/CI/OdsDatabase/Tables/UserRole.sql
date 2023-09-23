IF NOT EXISTS (
		SELECT uid
		FROM dbo.sysusers
		WHERE name = 'MedicalUserRole'
			AND issqlrole = 1
		)
	EXEC sp_addrole 'MedicalUserRole'
GO

GRANT SELECT, EXECUTE ON SCHEMA :: dbo TO MedicalUserRole;
GO
