
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.UnmaskCmtLastName') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.UnmaskCmtLastName
GO

CREATE FUNCTION dbo.UnmaskCmtLastName(@CmtLastName VARCHAR(500))
RETURNS VARCHAR(500)
AS 
BEGIN
	DECLARE @FilteredName VARCHAR(500)
	-- Unmask CmtLastName matching CPC team's query filter.
	SELECT @FilteredName =  CASE WHEN @CmtLastName LIKE  'test'  
										OR @CmtLastName LIKE  'test %' 
										OR @CmtLastName LIKE  '% test'  
										OR @CmtLastName LIKE  '% test %'
									THEN 'Testing Data'
								WHEN @CmtLastName LIKE  'train' 
										OR @CmtLastName LIKE  'train %' 
										OR @CmtLastName LIKE  '% train' 
										OR @CmtLastName LIKE  '% train %'
									THEN 'Training Data'
								WHEN @CmtLastName LIKE  '%third party%' 
										OR @CmtLastName LIKE  '%3rd P%'
									THEN 'Third Party Data'
							-- Null for PII CmtLastName
							ELSE NULL
							END
	RETURN @FilteredName
END
GO



