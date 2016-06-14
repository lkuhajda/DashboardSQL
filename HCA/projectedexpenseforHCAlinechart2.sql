
/*
projected expense for HCA linechart2
*/


DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 2

 SELECT 
	SUM(t1.amount) as ProjectedAmount
	-- , t3.[ActualDate]
	, t1.BudgetMonth
	, t1.BudgetYear
	FROM [Analytics].[DW].[FactBudgetExpense] t1
	LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.FinancialCategoryID = t2.FinancialCategoryID
	INNER JOIN DW.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID
	INNER JOIN DW.DimDate t5
	ON	t1.BudgetMonth = t5.CalendarMonth
	AND t1.BudgetYear = t5.CalendarYear
	AND t5.MinistryYear = @ReportYear
	AND t5.CalendarDayOfMonth = 1

	WHERE  t4.Code = 'HCA'
	AND t2.fundcode = '025'  
	AND t2.TenantID = 3
		AND
	(
		(t5.[CalendarYear] = @ReportYear and t5.[CalendarMonth] <= @ReportMonth )
		OR 
		(t5.[CalendarYear]  < @ReportYear )
	)
	GROUP BY t1.BudgetYear, t1.BudgetMonth 
	ORDER BY t1.BudgetYear, t1.BudgetMonth