DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 2

	SELECT 
		 case t4.name
			WHEN 'UNKNOWN' THEN 'Deerfield Rd'
			ELSE t4.name 
			end  as Campus, 
		  SUM(t1.amount) as RevenueAmount,
		  (SUM(t1.amount) * 100) / 
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
						AND t2.fundcode = '025'  
						AND t2.TenantID = 3) as rowPercent
		  
		   
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
	GROUP BY  t4.name 

