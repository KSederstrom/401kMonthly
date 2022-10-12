SELECT EOMONTH(Calendar_day) AS EndOfMonth
	,COUNT(Distinct SSN) AS CountUniqueSSNs
	,SUM(Outstanding_balance) AS TotalOutstanding
	,AVG(Outstanding_balance) AS AvgOutstanding
FROM [DevRaw].[dbo].[LoanBalances_EOM]
GROUP BY EOMONTH(Calendar_day)
ORDER BY EOMONTH(Calendar_day) desc