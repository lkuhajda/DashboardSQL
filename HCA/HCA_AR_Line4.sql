/*
AR table:
	General, Reserve, Mortgage Sinking Fund, Systems Project, Camp Reserve, HCA Endowment 
	(all except Chicago West as it is a manual form
*/

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth INT = 2
DECLARE @Over90 INT = 56566
DECLARE @ReportDate DATE

SET @ReportDate = convert(varchar(2),  @ReportMonth)  + '/1/' + convert(varchar(4),  @ReportYear)


; WITH DoubtfulAllow as (
	SELECT 1 as rownum
	, SUM(t1.amount) as DoubtfulAllowance , fundcode --, FundName	
	FROM [Analytics].[DW].[FactFinancialOther] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] fc
	ON t1.[FinancialCategoryID] = fc.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	WHERE t3.[ActualDate] < convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))
	--where t3.ministryyear = @ReportYear  --we are reporting on the prior fiscal year
	--AND t3.[MinistryQuarter]  = 1
	AND fc.EntityCode  = 'HCA'
	----this is the Doubtful Allowance
	AND fc.FundCode = '025' 
	AND GLCode = '12015'
	AND t1.DateID >= 20140801  --this is exact 
	GROUP BY fundcode -- , GLCode
	)

	,  totalAR as (
	SELECT 1 as rownum
	, SUM(t1.amount) as arsum , fundcode --, dw. --, FundName
	FROM [Analytics].[DW].[FactFinancialOther] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] fc
	ON t1.[FinancialCategoryID] = fc.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	WHERE t3.[ActualDate] < convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))
	--where t3.ministryyear = @ReportYear
	--AND t3.[MinistryQuarter]  = 1
	AND fc.EntityCode  = 'HCA'
	AND fc.FundCode = '025' 
	AND GLCode BETWEEN 12010 AND 12013 AND t1.DateID >= 20140801  --this is exact
	GROUP BY fundcode
	)

	--currentYear
	select convert(varchar, DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@ReportDate)+1,0)), 101) as ReportDate
	, t1.DoubtfulAllowance, t2.arsum as TotalAR, t1.DoubtfulAllowance/t2.arsum * 100 as DoubtPercent 
	, @Over90 as Over90 , t2.arsum - @Over90 as Under90 from DoubtfulAllow t1 join totalAR t2 
	on t1.rownum = t2.rownum


	
