SELECT EOMONTH(Calendar_day) AS EndOMonth
	,COUNT (Distinct SSN) AS CountUniqueSSNs
	,SUM(Outstanding_balance) AS TotalOutstandingLoan
	,AVG(Outstanding_balance) AS AvgOutstanding
FROM [DevRaw].[dbo].[LoanBalances_EOM]
GROUP BY EOMonth(calendar_day)
ORDER BY EOMonth(calendar_day) desc