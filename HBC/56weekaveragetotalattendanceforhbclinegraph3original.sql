

DECLARE @StartDate datetime 
set @StartDate   = '2-29-2016';
WITH ReportPeriod AS (
                SELECT 
                                  DimDate.DateID
                                , MinistryWeekStartLabel
                FROM DW.DimDate
                WHERE
                               -- ActualDate BETWEEN DATEADD(WEEK, -112, GETDATE()) AND GETDATE()
								ActualDate BETWEEN DATEADD(WEEK, -112, @StartDate) AND @StartDate

)
select * from ReportPeriod
--select distinct month(DateID), 

select distinct  left(DateID,4), substring(convert(varchar(10),DateID),5, 2) from ReportPeriod

, RawAttendance AS (
                SELECT DISTINCT              
                                  ROW_NUMBER() OVER (ORDER BY MinistryYear, MinistryMonth, ReportPeriod.MinistryWeekStartLabel) AS RowNum
                                , DimDate.MinistryYear
                                , DimDate.MinistryMonth
                                , DimDate.MinistryMonthAbbreviation + '-' + RIGHT(CONVERT(VARCHAR(4), DimDate.MinistryYear), 2) AS MonthLabel
                                , ReportPeriod.MinistryWeekStartLabel
                                --, DimMinistry.Name
                                --, DimActivity.Name
                                --, DimAttendanceType.Category
                                , SUM(AttendanceCount) AS AttendanceSum
                FROM DW.FactAttendance
                INNER JOIN ReportPeriod
                                ON FactAttendance.InstanceDateID = ReportPeriod.DateID
                INNER JOIN DW.DimDate
                                ON ReportPeriod.DateID = DimDate.DateID
                INNER JOIN DW.DimMinistry
                                ON FactAttendance.MinistryID = DimMinistry.MinistryID
                INNER JOIN DW.DimCampus
                                ON FactAttendance.CampusID = DimCampus.CampusID
                INNER JOIN DW.DimActivity
                                ON FactAttendance.ActivityID = DimActivity.ActivityID
                INNER JOIN DW.DimAttendanceType
                                ON FactAttendance.AttendanceTypeID = DimAttendanceType.AttendanceTypeID
                WHERE
                                ISNULL(NULLIF(DimAttendanceType.Category,''), 'Attendee') = 'Attendee'
                                AND ( 
                                                DimMinistry.Name LIKE '%Chuchwide Service%'
                                                OR DimMinistry.Name LIKE '%Churchwide Service%'
                                                OR DimMinistry.Name LIKE '%Harvest Kid%')

                GROUP BY
                                  DimDate.MinistryMonth
                                , DimDate.MinistryYear
                                , DimDate.MinistryMonthAbbreviation + '-' + RIGHT(CONVERT(VARCHAR(4), DimDate.MinistryYear), 2)
                                , ReportPeriod.MinistryWeekStartLabel
                                --, DimMinistry.Name
                                --, DimActivity.Name
                                --, DimAttendanceType.Category
)
SELECT 
      ra1.RowNum               
                , ra1.MonthLabel
                , ra1.MinistryWeekStartLabel
                , ra1.AttendanceSum
                , (SELECT SUM(AttendanceSum) / COUNT(DISTINCT MinistryWeekStartLabel) FROM RawAttendance ra2 WHERE ra2.RowNum BETWEEN ra1.RowNum - 52 and ra1.RowNum) AS Rolling52WeekAverage
FROM RawAttendance ra1
WHERE
                ra1.RowNum IN (SELECT TOP 56 RowNum FROM RawAttendance  ORDER BY 1 DESC) -- last 56 rows
ORDER BY 1,2