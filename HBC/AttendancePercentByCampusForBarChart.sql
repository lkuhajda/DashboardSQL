DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 2

; WITH LastTwoSundays AS (
	SELECT  ActualDate, DateID
	 
	FROM DW.DimDate
	WHERE
		ActualDate<= CONVERT(DATE, '02/29/2016')
		AND CalendarDayOfWeekLabel = 'Sunday'
	
	--ORDER BY ActualDate DESC
	)
, LastTwoWeekends AS (
	SELECT 'Current Week' AS SectionName, LastTwoSundays.ActualDate, DateID FROM LastTwoSundays
	UNION
	SELECT 'Previous Week' AS SectionName, LastTwoSundays.ActualDate, DateID -1  FROM LastTwoSundays
)

--select * from LastTwoWeekends order by dateid


, FullAttendance AS (
	SELECT 
		  LastTwoWeekends.SectionName
		, LastTwoWeekends.ActualDate AS WeekendDate
		--, DimCampus.Code
		, CASE WHEN DimCampus.Code = '--' AND DimMinistry.Name IN ('Camp','Other') THEN 'Camp / Other' ELSE 
			CASE WHEN DimCampus.Code  = '--' THEN Campus2.Code ELSE DimCampus.Code END END AS Campus
		, DimMinistry.Name AS MinistryName
		, CASE WHEN DimMinistry.Name IN (
			  'AU - Churchwide Services'
			, 'CC - Churchwide Services'
			, 'CL - Churchwide Services'
			, 'DR - Chuchwide Services'
			, 'EL - Churchwide Services'
			, 'NI - Churchwide Services'
			, 'RM - Churchwide Services'
			, 'Camp'
			, 'Other') THEN 'ADULTS' ELSE
			'KIDS' END AS AttendanceCategory
		, FactAttendance.AttendanceCount
	FROM DW.FactAttendance
	INNER JOIN LastTwoWeekends 
		ON FactAttendance.InstanceDateID = LastTwoWeekends.DateID
	INNER JOIN DW.DimMinistry
		ON FactAttendance.MinistryID = DimMinistry.MinistryID
	LEFT JOIN DW.DimCampus
		ON FactAttendance.CampusID = DimCampus.CampusID
	LEFT JOIN DW.DimCampus campus2
		ON DimMinistry.CampusID = campus2.CampusID
	WHERE
		DimMinistry.Name IN (
			  'AU - Churchwide Services'
			, 'CC - Churchwide Services'
			, 'CL - Churchwide Services'
			, 'DR - Chuchwide Services'
			, 'EL - Churchwide Services'
			, 'NI - Churchwide Services'
			, 'RM - Churchwide Services'
			, 'Camp'
			, 'Other')
		OR DimMinistry.Name LIKE '%Harvest Kids'
	UNION
	SELECT 
		  LastTwoWeekends.SectionName
		, LastTwoWeekends.ActualDate AS WeekendDate
		, DimCampus.Code
		, ''
		, AttendanceCategory.Name
		, 0 AS AttendanceCount
	FROM LastTwoWeekends, DW.DimCampus
		, (SELECT 'ADULTS'AS Name UNION SELECT 'KIDS' AS Name) AttendanceCategory
	WHERE
		DimCampus.Code IN ('RM','EL','CL','NI','CC','AU','DR')
	UNION
	SELECT 
		  LastTwoWeekends.SectionName
		, LastTwoWeekends.ActualDate AS WeekendDate
		, 'Camp / Other' AS CampusCode
		, ''
		, 'ADULTS' 
		, 0 AS AttendanceCount
	FROM LastTwoWeekends
), FullAttendance2 as (

SELECT
	SectionName, WeekendDate
	, CASE Campus
		WHEN 'RM' THEN 2
		WHEN 'EL' THEN 3
		WHEN 'CL' THEN 4
		WHEN 'NI' THEN 5
		WHEN 'CC' THEN 6
		WHEN 'AU' THEN 7
		WHEN 'DR' THEN 8
		WHEN 'Camp / Other' THEN 9 END AS RowNumber
	, Campus, MinistryName, AttendanceCategory, SUM(AttendanceCount) AS AttendanceCount
FROM FullAttendance
where campus <> 'Camp / Other'
GROUP BY 
	SectionName, WeekendDate
	, CASE Campus
		WHEN 'RM' THEN 2
		WHEN 'EL' THEN 3
		WHEN 'CL' THEN 4
		WHEN 'NI' THEN 5
		WHEN 'CC' THEN 6
		WHEN 'AU' THEN 7
		WHEN 'DR' THEN 8
		WHEN 'Camp / Other' THEN 9 END
	, Campus, MinistryName, AttendanceCategory
)

-- select *  FROM #FullAttendance2


	SELECT  fullattendance2.campus as code, t.Name,
-- sum(attendancecount) as sum_attendancecount, 
	(1.0*sum(attendancecount)) / 
		(
		SELECT sum(attendancecount) FROM  FullAttendance2  WHERE AttendanceCategory = 'ADULTS' and campus <> 'Camp / Other'
		) as rowPercent, 'Attendance' as type

FROM  FullAttendance2 JOIN DW.DimCampus t on FullAttendance2.campus = t.code
WHERE AttendanceCategory = 'ADULTS'
and campus <> 'Camp / Other'
group by  fullattendance2.campus, t.Name

UNION
	SELECT 
		   t4.code,t4.name as Campus,
	--  SUM(t1.amount) as RevenueAmount,
		  (1.0*SUM(t1.amount)) / 
					(select SUM(t1.amount)
					  FROM [Analytics].[DW].[FactRevenue] t1
						LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
						ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
						JOIN [Analytics].DW.DimDate T3
						ON t1.DateID = t3.DateID
						LEFT JOIN [Analytics].[DW].[DimCampus] t4
						ON t1.[CampusID] = t4.[CampusID]
						WHERE
						t3.[CalendarYear] = @ReportYear --year(getdate())

						AND t3.[CalendarMonth] <=  @ReportMonth --month(getdate())  

						AND t2.[GLCode] = '30010'
						AND t2.[DepartmentCode] = '3015'
						AND t2.fundcode = '025'  --I added, this was not in the spec
						AND t2.TenantID = 3) as rowPercent, 'Contribution' as type
		  
		   
	FROM [Analytics].[DW].[FactRevenue] t1
	LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	LEFT JOIN [Analytics].[DW].[DimCampus] t4
	ON t1.[CampusID] = t4.[CampusID]
	WHERE
	t3.[CalendarYear] = year(getdate())

	AND t3.[CalendarMonth] <= 2  --month(getdate()

	AND t2.[GLCode] = '30010'
	AND t2.[DepartmentCode] = '3015'
	AND t2.fundcode = '025'  --I added, this was not in the spec
	AND t2.TenantID = 3
	GROUP BY  t4.name, code
  order by rowPercent desc