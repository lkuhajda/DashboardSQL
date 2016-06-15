
DECLARE @BudgetYear int = 2016
DECLARE @BudgetMonth int = 2

SELECT  t3.[CalendarMonth] as BudgetMonth, t3.[CalendarYear] as BudgetYear
, SUM(t1.amount) as Expense
	 
FROM [Analytics].[DW].[FactExpense] t1
INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
INNER JOIN [Analytics].DW.DimDate T3
ON t1.DateID = t3.DateID
INNER JOIN DW.DimEntity T4
ON t1.EntityID = t4.EntityID
   
WHERE  
t3.[CalendarYear] = @BudgetYear --(getdate())
AND t3.[CalendarMonth] <= @BudgetMonth  --month(getdate())  --3

AND t4.Code = 'HBf'
AND t2.fundcode = '025'  
AND t2.TenantID = 3
GROUP BY  t3.[CalendarMonth], t3.[CalendarYear]
 