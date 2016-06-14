/*
CASH table:
	General, Reserve, Mortgage Sinking Fund, Systems Project, Camp Reserve, HCA Endowment 
	(all except Chicago West as it is a manual form
*/

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 2


	SELECT 
	SUM(t1.amount) as TotalCashBalance , fundcode, FundName
	--, GLCode  --  'General' as FundName
	
	FROM [Analytics].[DW].[FactFinancialOther] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] fc
	ON t1.[FinancialCategoryID] = fc.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	
	WHERE t3.[ActualDate] < convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))
	--AND t1.DateID >= 20150101
	AND fc.EntityCode  = 'HCA'
	--AND fc.FundCode IN ('025')
	--AND fc.FundCode IN ('025',  '086')

	AND (
			(fc.FundCode = '115' AND GLCode IN ('10016','10017','20010','20020','22025')  AND t1.DateID >= 20140801)
			OR
			(fc.FundCode = '415' AND GLCode IN ('10016','13077') AND t1.DateID >= 20140801)
			OR
			(fc.FundCode = '025' AND GLCode IN ('10016') AND t1.DateID >= 20150801  )
			OR
			(fc.FundCode = '245' AND GLCode IN ('10016','10017') AND t1.DateID >= 20150801 )
			--OR

			--(fc.FundCode  in (025, 027, 115, 155, 157, 185, 215, 225, 227, 235, 237, 245, 247, 285, 287, 289, 395, 397, 415, 417))

			--(fc.FundCode = '115' AND GLCode NOT IN ('10016','10017','20010','20020','22025')  AND t1.DateID >= 20140801)
			--OR
			--(fc.FundCode = '415' AND GLCode NOT IN ('10016','13077') AND t1.DateID >= 20140801)
			--OR
			--(fc.FundCode = '025' AND GLCode  NOT IN ('10016') AND t1.DateID >= 20140801)

		)

	GROUP BY fundcode , FundName
	UNION

	SELECT 
	SUM(t1.amount) as TotalCashBalance, 'Other' as fundcode, 'Other' as  FundName
	--, fundcode
	--, GLCode  --  'General' as FundName
	
	FROM [Analytics].[DW].[FactFinancialOther] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] fc
	ON t1.[FinancialCategoryID] = fc.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	
	WHERE t3.[ActualDate] < convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))
	--AND t1.DateID >= 20150101
	AND fc.EntityCode  = 'HCA'

	--full list minus those from above
	--AND fc.FundCode  in ( 027,  155, 157, 185, 215, 225, 227, 235, 237, 247, 285, 287, 289, 395, 397, 417)
	--AND t1.DateID >= 20140801

	--list from the dashboard
	AND fc.FundCode  in ( 155,  185, 225,  285,  395)
	AND t1.DateID >= 20140801

	--select TotalCashBalance, fundcode  --,  Liabilities, '-1087580' as EightWeekReserve 


