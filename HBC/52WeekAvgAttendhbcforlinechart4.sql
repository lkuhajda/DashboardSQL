
DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 2


SELECT  
 td.[CalendarYear] 

, SUM([AttendanceCount]) / 52 as Average52Week

FROM [Analytics].[DW].[FactAttendance] tf
INNER JOIN [Analytics].[DW].[DimMinistry] tm
	ON tf.[MinistryID] = tm.[MinistryID]
INNER JOIN [Analytics].DW.DimDate td
	ON tf.[InstanceDateID] = td.DateID 
INNER JOIN [Analytics]. DW.DimActivity tv
        ON tf.ActivityID = tv.ActivityID
        AND tf.TenantID = tv.TenantID
INNER JOIN [Analytics].DW.DimAttendanceType at
	ON tf.AttendanceTypeID = at.AttendanceTypeID
	AND tf.TenantID = at.TenantID
WHERE

(
(td.[CalendarYear] = @ReportYear and td.[CalendarMonth] <= @ReportMonth)
OR
(td.[CalendarYear] = @ReportYear -1 and td.[CalendarMonth] > @ReportMonth)
 )

AND 
	(
    tm.Name LIKE '%Chuchwide Service%'
    OR tm.Name LIKE '%Churchwide Service%'
    OR tm.Name LIKE '%Harvest Kid%'
	)
	
AND at.Category = 'Attendee'
group by td.[CalendarYear]


