
USE Analytics
/*
actual Expense for HBCG line chart 1
*/

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 12

-----------------------------------------------------
--Calculate Actual Expenses
-----------------------------------------------------
; WITH Expenses AS (
	SELECT 
	 t3.[CalendarMonth] , t3.[CalendarYear] ,  SUM(t1.amount) as Amount
 -- , ROW_NUMBER() OVER(ORDER BY t3.[CalendarYear] , t3.[CalendarMonth] ) AS RowNum

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
			(t4.Code IN ('HCA', 'HBF') AND t2.fundcode = '025') 
			OR
			(t4.Code = 'HBC' AND t2.fundcode = '025' AND t2.GLCode NOT IN ('30010', '30058', '30075', '30046') AND t2.DepartmentCode <> '9120')

			OR
			(t4.Code  = 'WITW' 
				AND
					(fundcode = '025'  --for WITW only, department is loaded into "staff code"
					AND [StaffCode]  IN ( '5055', '5158', '5160', '5163', '6207' , '6217', '5162', '7217', '5178', '5180', '7219'
					, '4106', '4056', '4036', '5038', '4016', '5058', '4096', '5078', '5098', '5138' ))
					OR
					(fundcode = '086')
			)
		)

	GROUP BY  t3.[CalendarYear] , t3.[CalendarMonth] --, t4.Code

	)
	
--select * from expenses

-----------------------------------------------------
-- Actual HBF Additional Expenses
-----------------------------------------------------
, HBFXtaexpenses as (
	SELECT t3.[CalendarMonth], t3.[CalendarYear]
	  , SUM(t1.amount) as amount
	FROM [DW].[FactFinancialOther] T1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	INNER JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	WHERE  t3.[CalendarYear] = @ReportYear 
	AND t3.[CalendarMonth] <= @ReportMonth 
	AND GLCode = '15141'
	and t2.entitycode = 'HBF'
	GROUP BY  t3.[CalendarMonth], t3.[CalendarYear]
)

--select * from HBFXtaexpenses

,  ExpensesAll AS
	 (
	select [CalendarMonth], [CalendarYear], Amount from Expenses
	UNION
	select [CalendarMonth], [CalendarYear],  Amount from HBFXtaexpenses
	)

--Select * from ExpensesAll

,  ExpensesAllSummary AS
	 (
	SELECT [CalendarMonth], [CalendarYear],  SUM(Amount) as Amount
	,  ROW_NUMBER() OVER(ORDER BY [CalendarYear] , [CalendarMonth]) AS RowNum
	FROM ExpensesAll
	GROUP BY  [CalendarMonth], [CalendarYear]
	 )

	 --select * from ExpensesAllSummary

	 select [CalendarMonth], [CalendarYear],  Amount
		,	(SELECT SUM(t2.Amount) from ExpensesAllSummary t2 WHERE t2.RowNum <= t1.RowNum ) AS CumulativeSum
	 FROM ExpensesAllSummary t1
	 order by [CalendarMonth], [CalendarYear]
