
USE Analytics
/*
Projected expenses for HBCG line chart 1
*/

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 12

;WITH Expenses AS (
	SELECT 
	SUM(t1.amount) as Amount,  BudgetMonth, BudgetYear 
  , ROW_NUMBER() OVER(ORDER BY t1.[BudgetYear] , t1.[BudgetMonth]) AS RowNum

	FROM [Analytics].[DW].[FactBudgetExpense] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	INNER JOIN dw.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID

	WHERE   t2.TenantID = 3
	and Budgetyear = @ReportYear
	AND
		(
		(t4.Code IN ('HCA', 'WITW', 'HBF', 'HBC') AND t2.fundcode = '025') 
		OR
		(t4.Code = 'HBC' AND t2.fundcode = '025' AND t2.[GLCode] = '30010' AND t2.[DepartmentCode] = '3015')
		)
	 
	 GROUP BY BudgetMonth, BudgetYear --, t4.Code
	 )

	 --select * from expenses

	 select Amount,  tr.[BudgetMonth], tr.[BudgetYear]  
	 , (SELECT SUM(tc.Amount) from Expenses tc WHERE tc.RowNum <= tr.RowNum ) AS CumulativeSum
	 FROM expenses tr 
	 ORDER BY  tr.[BudgetMonth], tr.[BudgetYear]  