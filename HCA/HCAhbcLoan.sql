/*
CASH table:
	General, Reserve, Mortgage Sinking Fund, Systems Project, Camp Reserve, HCA Endowment 
	(all except Chicago West as it is a manual form
*/

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 2

--SELECT convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))
	
	SELECT 
	--t1.amount, t3.[ActualDate]
	SUM(t1.amount) as TotalCashBalance  --, fundcode
	--, GLCode  --  'General' as FundName
	
	FROM [Analytics].[DW].[FactFinancialOther] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] fc
	ON t1.[FinancialCategoryID] = fc.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	
	WHERE 
	--t3.[ActualDate] < convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))
	t3.[ActualDate] < '3/1/2016'
	--AND t1.DateID >= 20150101
	AND 
	fc.EntityCode  = 'HCA'

	AND fc.FundCode = '115' 
	--AND GLCode IN ('23070') 
	
	--GROUP BY fundcode 
	