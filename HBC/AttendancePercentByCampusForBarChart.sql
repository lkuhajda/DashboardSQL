
DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 2


; WITH LastTwoSundays AS (
	SELECT  ActualDate, DateID
	 
	FROM DW.DimDate
	WHERE
		ActualDate<= CONVERT(DATE, '02/29/2016')
		AND CalendarDayOfWeekLabel = 'Sunday'
	    and calendaryear = @ReportYear 
	--ORDER BY ActualDate DESC
	)
, LastTwoWeekends AS (
	SELECT 'Current Week' AS SectionName, LastTwoSundays.ActualDate, DateID FROM LastTwoSundays
	UNION
	SELECT 'Previous Week' AS SectionName, LastTwoSundays.ActualDate, DateID -1  FROM LastTwoSundays
)

--select * from LastTwoWeekends order by dateid


, FullAttendance AS (
	SELECT DISTINCT
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
	
)

--select *  FROM FullAttendance

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
	into #FullAttendance2
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
--

-- select *  FROM #FullAttendance2

	SELECT  campus, 
	sum(attendancecount), 
	round((sum(attendancecount) * 100.0) / 
		(
		SELECT sum(attendancecount) FROM  #FullAttendance2 WHERE AttendanceCategory = 'ADULTS' and campus <> 'Camp / Other'
		),0)as rowPercent

FROM  #FullAttendance2 
WHERE AttendanceCategory = 'ADULTS'
and campus <> 'Camp / Other'
group by  campus
ORDER by campus

--drop table #FullAttendance2