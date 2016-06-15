
USE Analytics
/*
actual Expense for HBCG line chart 1
*/

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 12

;WITH Expenses AS (
	SELECT 
	SUM(t1.amount) as Amount, t3.[CalendarYear] , t3.[CalendarMonth] 
  , ROW_NUMBER() OVER(ORDER BY t3.[CalendarYear] , t3.[CalendarMonth] ) AS RowNum

	FROM [Analytics].[DW].[FactExpense] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]

	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID

	INNER JOIN dw.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID

	WHERE   t2.TenantID = 3
	AND t3.[CalendarYear] = @ReportYear
	AND
		(
		(t4.Code IN ('HCA', 'WITW', 'HBF', 'HBC') AND t2.fundcode = '025') 
		OR
		(t4.Code = 'HBC' AND t2.fundcode = '025' AND t2.[GLCode] = '30010' AND t2.[DepartmentCode] = '3015')
		)

	GROUP BY  t3.[CalendarYear] , t3.[CalendarMonth] --, t4.Code

	)

	SELECT Amount,   tr.[CalendarYear] , tr.[CalendarMonth]  
	, (SELECT SUM(tc.Amount) FROM Expenses tc WHERE tc.RowNum <= tr.RowNum ) AS CumulativeSum
	FROM Expenses tr 
	ORDER BY   tr.[CalendarYear] , tr.[CalendarMonth]  