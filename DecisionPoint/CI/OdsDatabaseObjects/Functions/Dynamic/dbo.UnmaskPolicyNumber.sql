
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.UnmaskPolicyNumber') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.UnmaskPolicyNumber
GO
CREATE FUNCTION dbo.UnmaskPolicyNumber(@PolicyNumber VARCHAR(500))
RETURNS VARCHAR(500)
AS 
BEGIN
	DECLARE @FilteredValue VARCHAR(500)
	-- Unmask Policy Numbers matching CPC team's query filter.
	SELECT @FilteredValue =  CASE WHEN @PolicyNumber LIKE  '%do not use%'  
										OR @PolicyNumber LIKE  '%DO NOT ENTER%'
									THEN 'Do Not Use'
						-- Null for PII Policy Numbers
							ELSE NULL
							END
	RETURN @FilteredValue
END
GO


