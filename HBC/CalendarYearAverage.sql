USE Analytics
/*
HBC dashboard Calendar Year Averages 
*/

DECLARE @YearForReport INT = 2016
DECLARE @ReportYear INT = @YearForReport
DECLARE @ReportMonth TINYINT = 2


---------------set up date ranges for the reporting years
; WITH LastNSundaysCurrentMo AS (
	SELECT ActualDate, DateID
	FROM DW.DimDate
	WHERE
	--DateID <= 20150228 and DateID >= 20150101 
		actualdate  <=    DATEADD(d,-1, (convert(date, convert(varchar(10), @ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))))
		AND actualdate >=   convert(date, convert(varchar(10), @ReportMonth  ) + '/01/'+  convert(varchar(10),@ReportYear))
		AND CalendarDayOfWeekLabel = 'Sunday'
)

	----------Attendance data  current Rolling 12 months
, LastTwoWeekendsRollCurrent AS (
	SELECT 'Current Week'  AS SectionName, t1.ActualDate, DateID FROM LastNSundaysCurrentMo t1
	UNION 
	SELECT   'Previous Week'  AS SectionName, t1.ActualDate, CONVERT(VARCHAR(8), dateadd(d,-1,convert(date,convert(varchar(8),DateID))), 112)  FROM LastNSundaysCurrentMo t1
	)

--select * from LastTwoWeekendsRollCurrent order by ActualDate

---------------end of setting up date ranges for the 3 reporting years

--Attendance Current Year


	SELECT DISTINCT
		  tr.SectionName
		, tr.ActualDate AS WeekendDate
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
		into #FullAttendanceCurrent
	FROM DW.FactAttendance
	INNER JOIN LastTwoWeekendsRollCurrent tr 
		ON FactAttendance.InstanceDateID = tr.DateID
	INNER JOIN DW.DimMinistry
		ON FactAttendance.MinistryID = DimMinistry.MinistryID
	INNER JOIN [Analytics].[DW].[DimActivity] t2
		on DimMinistry.[MinistryID] = t2.[MinistryID]
	LEFT JOIN DW.DimCampus
		ON FactAttendance.CampusID = DimCampus.CampusID
	LEFT JOIN DW.DimCampus campus2
		ON DimMinistry.CampusID = campus2.CampusID
	WHERE
		(DimMinistry.Name IN (
			  'AU - Churchwide Services'
			, 'CC - Churchwide Services'
			, 'CL - Churchwide Services'
			, 'DR - Chuchwide Services'
			, 'EL - Churchwide Services'
			, 'NI - Churchwide Services'
			, 'RM - Churchwide Services'
			, 'Camp'
			, 'Other'))
		OR 
		--(
		DimMinistry.Name LIKE '%Harvest Kids'
		-- and  t2.Name LIKE '%Kids Weekend')
 
 -----------------------------------
 --Current Year YTD

 ;WITH  LastNSundaysYTD AS (
	SELECT ActualDate, DateID
	FROM DW.DimDate
	WHERE
	--DateID <= 20150228 and DateID >= 20150101 
		actualdate  <=    DATEADD(d,-1, (convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))))
		AND actualdate >=  '01/01/'+  convert(varchar(10),@ReportYear) 
		AND CalendarDayOfWeekLabel = 'Sunday'
)


, LastTwoWeekendsYTDCurrent AS (
	SELECT 'Current Week'  AS SectionName, t1.ActualDate, DateID FROM LastNSundaysYTD t1
	UNION 
	SELECT   'Previous Week'  AS SectionName, t1.ActualDate, CONVERT(VARCHAR(8), dateadd(d,-1,convert(date,convert(varchar(8),DateID))), 112)  FROM LastNSundaysYTD t1
	)
	
	SELECT DISTINCT
		  tr.SectionName
		, tr.ActualDate AS WeekendDate
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
		into #FullAttendanceYTD
	FROM DW.FactAttendance
	INNER JOIN LastTwoWeekendsYTDCurrent tr 
		ON FactAttendance.InstanceDateID = tr.DateID
	INNER JOIN DW.DimMinistry
		ON FactAttendance.MinistryID = DimMinistry.MinistryID
	INNER JOIN [Analytics].[DW].[DimActivity] t2
		on DimMinistry.[MinistryID] = t2.[MinistryID]
	LEFT JOIN DW.DimCampus
		ON FactAttendance.CampusID = DimCampus.CampusID
	LEFT JOIN DW.DimCampus campus2
		ON DimMinistry.CampusID = campus2.CampusID
	WHERE
		(DimMinistry.Name IN (
			  'AU - Churchwide Services'
			, 'CC - Churchwide Services'
			, 'CL - Churchwide Services'
			, 'DR - Chuchwide Services'
			, 'EL - Churchwide Services'
			, 'NI - Churchwide Services'
			, 'RM - Churchwide Services'
			, 'Camp'
			, 'Other'))
		OR 
		--(
		DimMinistry.Name LIKE '%Harvest Kids'
		-- and  t2.Name LIKE '%Kids Weekend')

		--select * from #FullAttendanceYTD

	---------------------------------One Year Prior
	--One Year Prior Current Month

; WITH LastNSundaysCurrentMoOnePrior AS (
	SELECT ActualDate, DateID
	FROM DW.DimDate
	WHERE
	--DateID <= 20150228 and DateID >= 20150101 
		actualdate  <=    DATEADD(d,-1, (convert(date, convert(varchar(10), @ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear -1))))
		AND actualdate >=   convert(date, convert(varchar(10), @ReportMonth  ) + '/01/'+  convert(varchar(10),@ReportYear -1))
		AND CalendarDayOfWeekLabel = 'Sunday'
)
, LastTwoWeekendsCurentMoOnePrior AS (
	SELECT 'Current Week'  AS SectionName, t1.ActualDate, DateID FROM LastNSundaysCurrentMoOnePrior t1
	UNION 
	SELECT   'Previous Week'  AS SectionName, t1.ActualDate, CONVERT(VARCHAR(8), dateadd(d,-1,convert(date,convert(varchar(8),DateID))), 112)  FROM LastNSundaysCurrentMoOnePrior t1
	)

	SELECT DISTINCT
		  tr.SectionName
		, tr.ActualDate AS WeekendDate
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
		into #FullAttendanceCurrentMoOnePrior
	FROM DW.FactAttendance
	INNER JOIN LastTwoWeekendsCurentMoOnePrior tr 
		ON FactAttendance.InstanceDateID = tr.DateID
	INNER JOIN DW.DimMinistry
		ON FactAttendance.MinistryID = DimMinistry.MinistryID
	INNER JOIN [Analytics].[DW].[DimActivity] t2
		on DimMinistry.[MinistryID] = t2.[MinistryID]
	LEFT JOIN DW.DimCampus
		ON FactAttendance.CampusID = DimCampus.CampusID
	LEFT JOIN DW.DimCampus campus2
		ON DimMinistry.CampusID = campus2.CampusID
	WHERE
		(DimMinistry.Name IN (
			  'AU - Churchwide Services'
			, 'CC - Churchwide Services'
			, 'CL - Churchwide Services'
			, 'DR - Chuchwide Services'
			, 'EL - Churchwide Services'
			, 'NI - Churchwide Services'
			, 'RM - Churchwide Services'
			, 'Camp'
			, 'Other'))
		OR 
		--(
		DimMinistry.Name LIKE '%Harvest Kids'
		-- and  t2.Name LIKE '%Kids Weekend')

--One Year Prior YTD
		
;with  LastNSundaysYTDOnePrior AS (
	SELECT ActualDate, DateID
	FROM DW.DimDate
	WHERE
	--DateID <= 20150228 and DateID >= 20150101 
		actualdate  <=    DATEADD(d,-1, (convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear -1))))
		AND actualdate >=  '01/01/'+  convert(varchar(10),@ReportYear -1) 
		AND CalendarDayOfWeekLabel = 'Sunday'
)
 , LastTwoWeekendsYTDOnePrior AS (
	SELECT 'Current Week'  AS SectionName, t1.ActualDate, DateID FROM LastNSundaysYTDOnePrior t1
	UNION 
	SELECT   'Previous Week'  AS SectionName, t1.ActualDate, CONVERT(VARCHAR(8), dateadd(d,-1,convert(date,convert(varchar(8),DateID))), 112)  FROM LastNSundaysYTDOnePrior t1
	)

	SELECT DISTINCT
		  tr.SectionName
		, tr.ActualDate AS WeekendDate
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
		into #FullAttendanceYTDOnePrior
	FROM DW.FactAttendance
	INNER JOIN LastTwoWeekendsYTDOnePrior tr 
		ON FactAttendance.InstanceDateID = tr.DateID
	INNER JOIN DW.DimMinistry
		ON FactAttendance.MinistryID = DimMinistry.MinistryID
	INNER JOIN [Analytics].[DW].[DimActivity] t2
		on DimMinistry.[MinistryID] = t2.[MinistryID]
	LEFT JOIN DW.DimCampus
		ON FactAttendance.CampusID = DimCampus.CampusID
	LEFT JOIN DW.DimCampus campus2
		ON DimMinistry.CampusID = campus2.CampusID
	WHERE
		(DimMinistry.Name IN (
			  'AU - Churchwide Services'
			, 'CC - Churchwide Services'
			, 'CL - Churchwide Services'
			, 'DR - Chuchwide Services'
			, 'EL - Churchwide Services'
			, 'NI - Churchwide Services'
			, 'RM - Churchwide Services'
			, 'Camp'
			, 'Other'))
		OR 
		--(
		DimMinistry.Name LIKE '%Harvest Kids'
		-- and  t2.Name LIKE '%Kids Weekend')

			---------------------------------Two Years Prior
	--Two Years Prior Current Month

; WITH LastNSundaysCurrentMoTwoPrior AS (
	SELECT ActualDate, DateID
	FROM DW.DimDate
	WHERE
	--DateID <= 20150228 and DateID >= 20150101 
		actualdate  <=    DATEADD(d,-1, (convert(date, convert(varchar(10), @ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear -2))))
		AND actualdate >=   convert(date, convert(varchar(10), @ReportMonth  ) + '/01/'+  convert(varchar(10),@ReportYear -2))
		AND CalendarDayOfWeekLabel = 'Sunday'
)

, LastTwoWeekendsCurentMoTwoPrior AS (
	SELECT 'Current Week'  AS SectionName, t1.ActualDate, DateID FROM LastNSundaysCurrentMoTwoPrior t1
	UNION 
	SELECT   'Previous Week'  AS SectionName, t1.ActualDate, CONVERT(VARCHAR(8), dateadd(d,-1,convert(date,convert(varchar(8),DateID))), 112)  FROM LastNSundaysCurrentMoTwoPrior t1
	)

	
	SELECT DISTINCT
		  tr.SectionName
		, tr.ActualDate AS WeekendDate
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
		into #FullAttendanceCurrentMoTwoPrior
	FROM DW.FactAttendance
	INNER JOIN LastTwoWeekendsCurentMoTwoPrior tr 
		ON FactAttendance.InstanceDateID = tr.DateID
	INNER JOIN DW.DimMinistry
		ON FactAttendance.MinistryID = DimMinistry.MinistryID
	INNER JOIN [Analytics].[DW].[DimActivity] t2
		on DimMinistry.[MinistryID] = t2.[MinistryID]
	LEFT JOIN DW.DimCampus
		ON FactAttendance.CampusID = DimCampus.CampusID
	LEFT JOIN DW.DimCampus campus2
		ON DimMinistry.CampusID = campus2.CampusID
	WHERE
		(DimMinistry.Name IN (
			  'AU - Churchwide Services'
			, 'CC - Churchwide Services'
			, 'CL - Churchwide Services'
			, 'DR - Chuchwide Services'
			, 'EL - Churchwide Services'
			, 'NI - Churchwide Services'
			, 'RM - Churchwide Services'
			, 'Camp'
			, 'Other'))
		OR 
		--(
		DimMinistry.Name LIKE '%Harvest Kids'
		-- and  t2.Name LIKE '%Kids Weekend')

--Two Years Prior YTD
		

;with  LastNSundaysYTDTwoPrior AS (
	SELECT ActualDate, DateID
	FROM DW.DimDate
	WHERE
	--DateID <= 20150228 and DateID >= 20150101 
		actualdate  <=    DATEADD(d,-1, (convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear -2))))
		AND actualdate >=  '01/01/'+  convert(varchar(10),@ReportYear -2) 
		AND CalendarDayOfWeekLabel = 'Sunday'
)

 , LastTwoWeekendsYTDTwoPrior AS (
	SELECT 'Current Week'  AS SectionName, t1.ActualDate, DateID FROM LastNSundaysYTDTwoPrior t1
	UNION 
	SELECT   'Previous Week'  AS SectionName, t1.ActualDate, CONVERT(VARCHAR(8), dateadd(d,-1,convert(date,convert(varchar(8),DateID))), 112)  FROM LastNSundaysYTDTwoPrior t1
	)

	SELECT DISTINCT
		  tr.SectionName
		, tr.ActualDate AS WeekendDate
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
		into #FullAttendanceYTDTwoPrior
	FROM DW.FactAttendance
	INNER JOIN LastTwoWeekendsYTDTwoPrior tr 
		ON FactAttendance.InstanceDateID = tr.DateID
	INNER JOIN DW.DimMinistry
		ON FactAttendance.MinistryID = DimMinistry.MinistryID
	INNER JOIN [Analytics].[DW].[DimActivity] t2
		on DimMinistry.[MinistryID] = t2.[MinistryID]
	LEFT JOIN DW.DimCampus
		ON FactAttendance.CampusID = DimCampus.CampusID
	LEFT JOIN DW.DimCampus campus2
		ON DimMinistry.CampusID = campus2.CampusID
	WHERE
		(DimMinistry.Name IN (
			  'AU - Churchwide Services'
			, 'CC - Churchwide Services'
			, 'CL - Churchwide Services'
			, 'DR - Chuchwide Services'
			, 'EL - Churchwide Services'
			, 'NI - Churchwide Services'
			, 'RM - Churchwide Services'
			, 'Camp'
			, 'Other'))
		OR 
		--(
		DimMinistry.Name LIKE '%Harvest Kids'
		-- and  t2.Name LIKE '%Kids Weekend')

	-----------------------Select all totals
	------------------------------
	SELECT YEAR(fa.WeekendDate) as Year  
	, (SUM(fa.AttendanceCount) / COUNT(DISTINCT(fa.WeekendDate))) as CurrentMonth
	, (
		SELECT (SUM(fa.AttendanceCount) / COUNT(DISTINCT(fa.WeekendDate))) as CurrentMonth
		FROM #FullAttendanceYTD fa
		GROUP BY YEAR(fa.WeekendDate)
	) AS YTD
	FROM #FullAttendanceCurrent fa
	group by YEAR(fa.WeekendDate) --, month(fa.WeekendDate)

	UNION  --One Year Prior

	SELECT YEAR(fa.WeekendDate) as Year  
	, (SUM(fa.AttendanceCount) / COUNT(distinct(fa.WeekendDate))) as CurrentMonth
	, (
		SELECT (SUM(fa.AttendanceCount) / COUNT(DISTINCT(fa.WeekendDate))) as CurrentMonth
		FROM #FullAttendanceYTDOnePrior fa
		GROUP BY YEAR(fa.WeekendDate)
	) AS YTD
	FROM #FullAttendanceCurrentMoOnePrior fa
	GROUP BY  year(fa.WeekendDate) --, month(fa.WeekendDate)

	UNION  --Two Years Prior
	
	SELECT YEAR(fa.WeekendDate) as Year  
	, (SUM(fa.AttendanceCount) / COUNT(distinct(fa.WeekendDate))) as CurrentMonth
	, (
		SELECT (SUM(fa.AttendanceCount) / COUNT(DISTINCT(fa.WeekendDate))) as CurrentMonth
		FROM #FullAttendanceYTDTwoPrior fa
		GROUP BY YEAR(fa.WeekendDate)
	) AS YTD
	FROM #FullAttendanceCurrentMoTwoPrior fa
	GROUP BY  year(fa.WeekendDate) --, month(fa.WeekendDate)

drop table #FullAttendanceCurrent
drop table #FullAttendanceYTD
drop table #FullAttendanceCurrentMoOnePrior
drop table #FullAttendanceYTDOnePrior
drop table #FullAttendanceCurrentMoTwoPrior
drop table #FullAttendanceYTDTwoPrior