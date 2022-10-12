--Find a count of Unique SSNs that contributed each month, along with a Total amount contributed. Include funds.
---------------------------------
--CTE to grab the unique SSN count for every individual month and total contributed. 
WITH BigTotals AS (
SELECT EOMONTH(calendar_day) AS EndOMonth
	,Count(Distinct SSN) AS DistinctSSNs
	,SUM(Cash_amount) AS CashTotal
FROM [DevRaw].[dbo].[Audit_Participant_Level_Activity_Report]
WHERE Plan_number = '75951'
	AND Transaction_type = '1-Contributions'
	AND Source IN ('1-PRE-TAX','2-ROTH')
GROUP BY EOMONTH(calendar_day)
)

--Second CTE to grab the total count and amounts for each Source (Traditional vs Roth)for each month. 
, Middle AS (SELECT EOMONTH(calendar_day) AS EndOMonth
	,Count(Distinct SSN) AS SubTotalSSNs
	,Source
	,SUM(Cash_amount) AS CashTotal
FROM [DevRaw].[dbo].[Audit_Participant_Level_Activity_Report]
WHERE Plan_number = '75951'
	AND Transaction_type = '1-Contributions'
	AND Source IN ('1-PRE-TAX','2-ROTH')
GROUP BY EOMONTH(calendar_day)
	,Source
--ORDER BY EOMonth(Calendar_day)
)

--Third Final CTE to grab Count of SSNs and Dollar amount for each fund by each source by each month. 
, SMALL AS (SELECT EOMONTH(calendar_day) AS EndOMonth
	,Count(Distinct SSN) AS SubSubSSNs
	,Source
	,Fund
	,SUM(Cash_amount) AS SubCashTotal
FROM [DevRaw].[dbo].[Audit_Participant_Level_Activity_Report]
WHERE Plan_number = '75951'
	AND Transaction_type = '1-Contributions'
	AND Source IN ('1-PRE-TAX','2-ROTH')
GROUP BY EOMONTH(calendar_day)
	,Source
	,Fund
)

--Fourth grab total eligible to be contributing each month.
,Eligibles AS (
SELECT Calendar_day, COUNT(DISTINCT SMID) AS TMsEligibles
	FROM [Workday].[dbo].[HCE_Determination_Monthly]
	WHERE Historical_Status IN ('Active','On Leave')
		AND Eligible_401K_Wages > 0
		AND DATEDIFF(day,Hire_Date,Calendar_day) >=30
	GROUP BY Calendar_day
--	ORDER BY Calendar_day Desc
	)

--Combine all CTEs.
SELECT Big.EndOMonth
	,m.Source
	,s.Fund
	,big.DistinctSSNs
	,m.SubTotalSSNs
	,s.SubSubSSNs
	,big.CashTotal AS OverallCash
	,m.CashTotal AS SourceCash
	,s.SubCashTotal AS SourceAndFundCash
	,E.TMsEligibles
	,Year(Big.EndOMonth) AS Years
	,Month(Big.EndOMonth) AS Months
FROM BigTotals AS Big
LEFT JOIN Middle AS M
	ON M.EndOMonth = Big.EndOMonth
LEFT JOIN Small AS S
	ON M.EndOMonth = S.EndOMonth
	AND M.Source = S.Source
LEFT JOIN Eligibles AS E
	ON M.EndOMonth = E.Calendar_day
ORDER BY big.EndOMonth Desc
	,m.Source