
/*
Projected revenue for HCA line chart 1
*/

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 12


	SELECT 
	SUM(t1.amount) as ProjectedAmount
	-- , t3.[ActualDate]
	, BudgetMonth
	, BudgetYear
	FROM [Analytics].[DW].[FactBudgetRevenue] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	INNER JOIN dw.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID
	INNER JOIN DW.DimDate t5
	ON	t1.BudgetMonth = t5.CalendarMonth
	AND t1.BudgetYear = t5.CalendarYear
	AND t5.MinistryYear = @ReportYear
	AND t5.CalendarDayOfMonth = 1

	WHERE  
	t4.Code = 'HCA'
	AND t2.fundcode = '025' 
	AND t2.TenantID = 3
	AND
	(
		(t5.[CalendarYear] = @ReportYear and t5.[CalendarMonth] <= @ReportMonth )
		OR 
		(t5.[CalendarYear]  < @ReportYear )
	)
	GROUP BY BudgetMonth, BudgetYear

