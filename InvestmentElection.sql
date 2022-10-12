-----------------------------------------------------------
--SUM investment elections in each fund for each month, and divide using a CTE for the total amount of each month to get a % invested of the monthly total for each fund.

--CTE to find the the total invested each month.
WITH MonthTotal AS (SELECT Calendar_day
	,SUM(CAST(Invest_election_percent as decimal(19, 6)))/100 AS Total_Invested_each_month
FROM [DevRaw].[dbo].[Audit_Investment_Elections_EOM]
GROUP BY Calendar_day)

SELECT Aie.Calendar_day
	,Fund
	,Count(*) as CountPeople
	,((SUM(CAST(Invest_election_percent as decimal(19, 6)))/100) / MT.Total_Invested_each_month) AS '% Invested of that month'
--The two lines below are portions of the % line above. 
	,SUM(CAST(Invest_election_percent as decimal(19, 6)))/100 AS FundInvestelected
	,Total_Invested_each_month
FROM [DevRaw].[dbo].[Audit_Investment_Elections_EOM] as Aie
--Join CTE by calendar day.
LEFT JOIN MonthTotal AS MT
	ON AIE.Calendar_day = MT.Calendar_day
GROUP BY AIE.Calendar_day, Fund, MT.Total_Invested_each_month
ORDER BY Calendar_day desc, fund desc