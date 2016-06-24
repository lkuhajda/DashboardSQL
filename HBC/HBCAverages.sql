/*
HBC Averages
*/

DECLARE @ReportYear INT = 2016

DECLARE @ReportMonth TINYINT = 2
DECLARE @NumSunCurrent INT
DECLARE @NumSunPrior INT

--For Current Year
,  @YTDrevenue MONEY
, @AttendanceCountCurrent INT

--For Prior Year
,  @YTDrevenuePrior MONEY
, @AttendanceCountPrior int

--For Rolling 12 month Current
,  @YTDrevenueRollCurrent MONEY
, @AttendanceCountRollCurrent INT
, @NumSunRollCurrent INT

--For Rolling 12 month Prior
,  @YTDrevenueRollPrior MONEY
, @AttendanceCountRollPrior INT
, @NumSunRollPrior INT

	--------revenue
	--;WITH YTDrevenue AS (
	SELECT SUM(t1.amount) as RevenueAmount
	, t3.[CalendarYear]
	INTO #YTDrevenue
	FROM [Analytics].[DW].[FactRevenue] t1
	LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	INNER JOIN DW.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID
	WHERE 
	((t3.[CalendarYear] =  @ReportYear
	AND t3.[CalendarMonth] <= @ReportMonth)
		OR (t3.[CalendarYear] =  @ReportYear -1
	AND t3.[CalendarMonth] <= @ReportMonth))
	AND t4.Code = 'HBC'
	AND t2.[GLCode] = '30010'
	AND t2.[DepartmentCode] = '3015'
	AND fundcode = '025'  --I added, this was not in the spec
	AND t2.[TenantID] = 3
	group by t3.[CalendarYear]
	--)

	----------current rolling 12months revenue
	--;WITH RollrevenueCurrent AS (
	SELECT @YTDrevenueRollCurrent = SUM(t1.amount)  -- as RollRevenueAmount
	--, t3.[CalendarYear]
	--INTO #RollrevenueCurrent
	FROM [Analytics].[DW].[FactRevenue] t1
	LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	INNER JOIN DW.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID
	WHERE 
	((t3.[CalendarYear] =  @ReportYear
	AND t3.[CalendarMonth] <= @ReportMonth)
		OR (t3.[CalendarYear] =  @ReportYear -1
	AND t3.[CalendarMonth] > @ReportMonth))
	AND t4.Code = 'HBC'
	--AND t2.[GLCode] = '30010'
	--AND t2.[DepartmentCode] = '3015'
	AND fundcode = '025'  
	AND t2.[TenantID] = 3

	----------prior rolling 12months revenue
	SELECT @YTDrevenueRollPrior = SUM(t1.amount)  -- as RollRevenueAmount
	--, t3.[CalendarYear]
	--INTO #RollrevenueCurrent
	FROM [Analytics].[DW].[FactRevenue] t1
	LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	INNER JOIN DW.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID
	WHERE 
	((t3.[CalendarYear] =  @ReportYear -1
	AND t3.[CalendarMonth] <= @ReportMonth)
		OR (t3.[CalendarYear] =  @ReportYear -2
	AND t3.[CalendarMonth] > @ReportMonth))
	AND t4.Code = 'HBC'
	--AND t2.[GLCode] = '30010'
	--AND t2.[DepartmentCode] = '3015'
	AND fundcode = '025'  
	AND t2.[TenantID] = 3

	--------------attendance
	-------------- attendance dates current YTD
	SELECT   ActualDate, DateID
	INTO #LastNSundaysCurrentYear
	FROM DW.DimDate
	WHERE
		--DateID <= 20160229 -- Last Day of reporting period month
		actualdate  <= DATEADD(d,-1, (convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))))
		--and DateID >= 20160101 
		AND actualdate >= CONVERT(DATE, '01/01/' +  CONVERT(VARCHAR(4), @ReportYear) )
		AND CalendarDayOfWeekLabel = 'Sunday'
	
	SELECT @NumSunCurrent = COUNT(1) FROM #LastNSundaysCurrentYear

	--------------attendance dates prior YTD
	SELECT ActualDate, DateID
	INTO #LastNSundaysPriorYear
	FROM DW.DimDate
	WHERE
	--DateID <= 20150228 and DateID >= 20150101 
		actualdate  <= DATEADD(d,-1, (convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear -1))))
		AND actualdate >= CONVERT(DATE, '01/01/' +  CONVERT(VARCHAR(4), @ReportYear -1) )
		AND CalendarDayOfWeekLabel = 'Sunday'

	SELECT @NumSunPrior = COUNT(1) FROM #LastNSundaysPriorYear

	--------------attendance dates current rolling 12 month
	SELECT ActualDate, DateID
	INTO #LastNSundaysCurrentRoll
	FROM DW.DimDate
	WHERE
	--DateID <= 20150228 and DateID >= 20150101 
		actualdate  <=   DATEADD(d,-1, (convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))))
		AND actualdate >=  convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear -1))
		AND CalendarDayOfWeekLabel = 'Sunday'

	SELECT @NumSunRollCurrent = COUNT(1) FROM #LastNSundaysPriorYear

	--------------attendance dates prior rolling 12 month
	SELECT ActualDate, DateID
	INTO #LastNSundaysPriorRoll
	FROM DW.DimDate
	WHERE
	--DateID <= 20150228 and DateID >= 20150101 
		actualdate  <= DATEADD(d,-1, (convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear -1))))
		AND actualdate >=  convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear -2))
		AND CalendarDayOfWeekLabel = 'Sunday'

	SELECT @NumSunRollPrior = COUNT(1) FROM #LastNSundaysPriorYear

	-----------------------------------------------------
	----------Attendance data current 

; with LastTwoWeekendsCurrent AS (
	SELECT 'Current Week' AS SectionName, #LastNSundaysCurrentYear.ActualDate, DateID FROM #LastNSundaysCurrentYear
	UNION
	SELECT 'Previous Week' AS SectionName, #LastNSundaysCurrentYear.ActualDate, DateID -1  FROM #LastNSundaysCurrentYear
)

	SELECT DISTINCT
		  LastTwoWeekendsCurrent.SectionName
		, LastTwoWeekendsCurrent.ActualDate AS WeekendDate
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
	INNER JOIN LastTwoWeekendsCurrent 
		ON FactAttendance.InstanceDateID = LastTwoWeekendsCurrent.DateID
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
		--OR 
		--(DimMinistry.Name LIKE '%Harvest Kids'
		-- and  t2.Name LIKE '%Kids Weekend')
	
		----------Attendance data prior 
	; with  LastTwoWeekendsPrior AS (
	SELECT 'Current Week' AS SectionName, #LastNSundaysPriorYear.ActualDate, DateID FROM #LastNSundaysPriorYear
	UNION
	SELECT 'Previous Week' AS SectionName, #LastNSundaysPriorYear.ActualDate, DateID -1  FROM #LastNSundaysPriorYear
)

	SELECT DISTINCT
		  LastTwoWeekendsprior.SectionName
		, LastTwoWeekendsprior.ActualDate AS WeekendDate
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
		into #FullAttendancePrior
	FROM DW.FactAttendance
	INNER JOIN LastTwoWeekendsPrior 
		ON FactAttendance.InstanceDateID = LastTwoWeekendsPrior.DateID
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
		--OR 
		--(DimMinistry.Name LIKE '%Harvest Kids'
		-- and  t2.Name LIKE '%Kids Weekend')
	

	----------Attendance data  current Rolling 12 months
	; with  LastTwoWeekendsRollCurrent AS (
	SELECT 'Current Week' AS SectionName, #LastNSundaysCurrentRoll.ActualDate, DateID FROM #LastNSundaysCurrentRoll
	UNION
	SELECT 'Previous Week' AS SectionName, #LastNSundaysCurrentRoll.ActualDate, DateID -1  FROM #LastNSundaysCurrentRoll
)

	SELECT DISTINCT
		  LastTwoWeekendsRollCurrent.SectionName
		, LastTwoWeekendsRollCurrent.ActualDate AS WeekendDate
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
		into #FullAttendanceRollCurrent
	FROM DW.FactAttendance
	INNER JOIN LastTwoWeekendsRollCurrent 
		ON FactAttendance.InstanceDateID = LastTwoWeekendsRollCurrent.DateID
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
		--OR 
		--(DimMinistry.Name LIKE '%Harvest Kids'
		-- and  t2.Name LIKE '%Kids Weekend')

	----------Attendance data Prior Rolling 12 months
	; with  LastTwoWeekendsRollPrior AS (
	SELECT 'Current Week' AS SectionName, #LastNSundaysPriorRoll.ActualDate, DateID FROM #LastNSundaysPriorRoll
	UNION
	SELECT 'Previous Week' AS SectionName, #LastNSundaysPriorRoll.ActualDate, DateID -1  FROM #LastNSundaysPriorRoll
)

	SELECT DISTINCT
		  LastTwoWeekendsRollPrior.SectionName
		, LastTwoWeekendsRollPrior.ActualDate AS WeekendDate
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
		into #FullAttendanceRollPrior
	FROM DW.FactAttendance
	INNER JOIN LastTwoWeekendsRollPrior  
		ON FactAttendance.InstanceDateID = LastTwoWeekendsRollPrior.DateID
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
		--OR 
		--(DimMinistry.Name LIKE '%Harvest Kids'
		-- and  t2.Name LIKE '%Kids Weekend')

------------------------------

--DECLARE @ReportYear INT = 2016

--DECLARE @ReportMonth TINYINT = 2
--DECLARE @NumSunCurrent INT
--DECLARE @NumSunPrior INT

----For Current Year
--,  @YTDrevenue MONEY
--, @AttendanceCountCurrent INT

----For Prior Year
--,  @YTDrevenuePrior MONEY
--, @AttendanceCountPrior int

----For Rolling 12 month Current
--,  @YTDrevenueRollCurrent MONEY
--, @AttendanceCountRollCurrent INT
--, @NumSunRollCurrent INT

----For Rolling 12 month Prior
--,  @YTDrevenueRollPrior MONEY
--, @AttendanceCountRollPrior INT
--, @NumSunRollPrior INT


SELECT  @AttendanceCountPrior = SUM(AttendanceCount) FROM  #FullAttendancePrior 
SELECT  @AttendanceCountCurrent = SUM(AttendanceCount) FROM  #FullAttendanceCurrent
SELECT  @AttendanceCountRollCurrent = SUM(AttendanceCount) FROM  #FullAttendanceRollCurrent 
SELECT  @AttendanceCountRollPrior = SUM(AttendanceCount) FROM  #FullAttendanceRollPrior

SELECT @AttendanceCountPrior, @AttendanceCountCurrent, @AttendanceCountRollCurrent, @AttendanceCountRollPrior


select (@YTDrevenueRollPrior / @NumSunRollCurrent  ) / (@AttendanceCountRollCurrent / @NumSunRollCurrent ) as Rolling12MoPerAdult
select(@YTDrevenueRollPrior / @NumSunRollPrior  ) / (@AttendanceCountRollPrior / @NumSunRollPrior ) as Rolling12MoPerAdult

select CalendarYear ,  @AttendanceCountCurrent/@NumSunCurrent AS WklyAttend, RevenueAmount/@NumSunCurrent  AS WklyGiving
, (RevenueAmount/@NumSunCurrent) / (@AttendanceCountCurrent/@NumSunCurrent)  as GivingPerAdult
, (@YTDrevenueRollCurrent / @NumSunRollCurrent  ) / (@AttendanceCountRollCurrent / @NumSunRollCurrent ) as Rolling12MoPerAdult
from #YTDrevenue where calendaryear = @ReportYear

union
select CalendarYear , @AttendanceCountPrior/@NumSunPrior AS WklyAttend, RevenueAmount/@NumSunPrior AS WklyGiving
, (RevenueAmount/@NumSunPrior) / (@AttendanceCountPrior/@NumSunPrior)  as GivingPerAdult
, (@YTDrevenueRollPrior / @NumSunRollPrior  ) / (@AttendanceCountRollPrior / @NumSunRollPrior ) as Rolling12MoPerAdult
from #YTDrevenue where calendaryear = @ReportYear -1


/*
drop table #FullAttendanceCurrent
drop table #FullAttendancePrior
drop table #LastNSundaysCurrentYear
drop table #LastNSundaysPriorYear
drop table #YTDrevenue
drop table #LastNSundaysCurrentRoll
drop table #LastNSundaysPriorRoll
drop table #FullAttendanceRollCurrent
drop table #FullAttendanceRollPrior
--drop table #RollrevenueCurrent
*/

