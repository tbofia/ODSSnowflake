CREATE OR REPLACE FUNCTION dbo.if_WeekEndsAndHolidays(
		if_OdsPostingGroupAuditId INT
)
RETURNS TABLE  (
		 OdsPostingGroupAuditId NUMBER(10,0)
		,OdsCustomerId NUMBER(10,0)
		,OdsCreateDate DATETIME
		,OdsSnapshotDate DATETIME
		,OdsRowIsCurrent INT
		,OdsHashbytesValue BINARY(8000)
		,DmlOperation VARCHAR(1)
		,DayOfWeekDate DATETIME
		,DayName VARCHAR(3)
		,WeekEndsAndHolidayId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DayOfWeekDate
		,t.DayName
		,t.WeekEndsAndHolidayId
FROM src.WeekEndsAndHolidays t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		WeekEndsAndHolidayId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.WeekEndsAndHolidays
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		WeekEndsAndHolidayId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.WeekEndsAndHolidayId = s.WeekEndsAndHolidayId
WHERE t.DmlOperation <> 'D'

$$;


