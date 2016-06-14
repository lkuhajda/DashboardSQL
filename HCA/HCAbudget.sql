/*
HCA Budget 
*/
DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 2

; WITH budget AS (
	SELECT 
	t3.[CalendarYear] , t3.[CalendarMonth]
	, SUM(t1.amount)  as Amount
	, ROW_NUMBER() OVER (ORDER BY t3.[CalendarYear] , t3.[CalendarMonth]) AS row
	FROM [Analytics].[DW].[FactExpense] t1
	
	LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	INNER JOIN dw.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID
	WHERE 

	t3.[MinistryYear] = @ReportYear -- year(getdate())
	AND t4.Code = 'HCA'
	AND fundcode = '025'  
	AND t2.[TenantID] = 3
		AND
	(
		(t3.[CalendarYear] = @ReportYear and t3.[CalendarMonth] <= @ReportMonth )
		OR 
		(t3.[CalendarYear]  < @ReportYear )
	)
	GROUP BY  t3.[CalendarYear] , t3.[CalendarMonth]	
)

, expense AS (
 SELECT 
	SUM(t1.amount) as ProjectedAmount
	-- , t3.[ActualDate]
	, t1.[BudgetYear] , t1.[BudgetMonth]
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

)


SELECT AVG(Amount) as YTDMonthlyBurn,  AVG(ProjectedAmount) as ApprovedMonthlyBudget, AVG(ProjectedAmount) - AVG(Amount) as MothlySurplusShort
, (select amount FROM budget where row = (select  max(row) from budget)) as CurMonthBurn
FROM expense t3  join budget T4 
on t3.BudgetYear = t4.CalendarYear and t3.BudgetMonth = t4.CalendarMonth 



