--Condense where people have their money allocated in their account for each month. Include an age group as of each month end, 
--identify if in one fund or multiple, include the fund and tell if they are in the correct Target Date fund for their age.
-- and include the market value and the coount for each possible group.

--First CTE identifies those invested in only one fund. Identifies age.
WITH SingleCountPrep AS (
	SELECT fbc.SSN
		--Count the SSNs
		,COUNT(fbc.SSN) AS SCounts
		,fbc.Calendar_day
		--Group people by their age to know if they are in the appropriate Target date fund.
		,CASE 
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) > 74.999 THEN '75+'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 65 and 74.999 THEN '65-74'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 55 and 64.999 THEN '55-64'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 45 and 54.999 THEN '45-54'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 35 and 44.999 THEN '35-44'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 25 and 34.999 THEN '25-34'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) < 25 THEN 'Under 25'
			ELSE 'Forfeitures' END AS AgeGroup
	FROM (SELECT Calendar_day, SSN, Plan_number, Fund, SUM(Market_value) AS Market_Value FROM [DevRaw].[dbo].[Fund_Balances_n_CostBasis_EOM] WHERE Plan_number = '75951'
		GROUP BY Calendar_day, SSN, Fund,Plan_number) AS fbc
	LEFT JOIN [DevRaw].[dbo].[Demographic_Data_EOM] AS demo
		ON fbc.Plan_number = demo.Plan_number
		AND fbc.Calendar_day = demo.Calendar_day
		AND fbc.SSN = demo.SSN
	WHERE fbc.Plan_number = '75951'
	GROUP BY fbc.Calendar_day
		,fbc.SSN
		,CASE 
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) > 74.999 THEN '75+'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 65 and 74.999 THEN '65-74'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 55 and 64.999 THEN '55-64'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 45 and 54.999 THEN '45-54'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 35 and 44.999 THEN '35-44'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 25 and 34.999 THEN '25-34'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) < 25 THEN 'Under 25'
			ELSE 'Forfeitures' END
	--Only count the SSNs that occur or are in one individual fund.
	HAVING COUNT(Fbc.SSN) = 1
	)

--Second CTE identifies those invested in multiple funds. Identifies age.
,MultipleCountPrep AS (
	SELECT fbc.SSN
		,CASE WHEN COUNT(fbc.SSN) = 1 THEN 0 ELSE 1 END AS 'MCounts'
		,fbc.Calendar_day
	--Group people by their age to know if they are in the appropriate Target date fund.
		,CASE 
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) > 74.999 THEN '75+'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 65 and 74.999 THEN '65-74'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 55 and 64.999 THEN '55-64'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 45 and 54.999 THEN '45-54'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 35 and 44.999 THEN '35-44'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 25 and 34.999 THEN '25-34'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) < 25 THEN 'Under 25'
			ELSE 'Forfeitures' END AS AgeGroup
	FROM (SELECT Calendar_day, SSN, Plan_number, Fund, SUM(Market_value) AS Market_Value FROM [DevRaw].[dbo].[Fund_Balances_n_CostBasis_EOM] WHERE Plan_number = '75951'
		GROUP BY Calendar_day, SSN, Fund,Plan_number) AS fbc
	LEFT JOIN [DevRaw].[dbo].[Demographic_Data_EOM] AS demo
		ON fbc.Plan_number = demo.Plan_number
		AND fbc.Calendar_day = demo.Calendar_day
		AND fbc.SSN = demo.SSN
	WHERE fbc.Plan_number = '75951'
	GROUP BY fbc.Calendar_day
		,fbc.SSN
		,CASE 
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) > 74.999 THEN '75+'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 65 and 74.999 THEN '65-74'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 55 and 64.999 THEN '55-64'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 45 and 54.999 THEN '45-54'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 35 and 44.999 THEN '35-44'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) BETWEEN 25 and 34.999 THEN '25-34'
			WHEN (DATEDIFF(MONTH,demo.Birth_date,fbc.Calendar_day)/12.0) < 25 THEN 'Under 25'
			ELSE 'Forfeitures' END
	HAVING COUNT(Fbc.SSN) > 1
	)

--Third CTE brings in the MKT value for each fund for each person for each month.
--Also will calculate how far away from the TGT date fund they are. Ideally should be 65. This is used in fourth and fifth CTEs.
,Monies AS (
	SELECT fbc.SSN
		,fbc.Calendar_day
		,Fund
		,Market_value
		,SUM(Market_value) AS TotalMKTValue
		,CASE WHEN fbc.fund IN ('0458-FID GOVT MMKT'
			,'2328-FID 500 INDEX'
			,'2352-FID MID CAP IDX'
			,'2358-FID SM CAP IDX'
			,'2834-FID TOTAL INTL IDX'
			,'2944-FID TOTAL BOND K6'
			,'3704-MIP CL 2'
			,'2764-FID FDM IDX INC IPR') 
			THEN 0 ELSE (Right(LEFT(fbc.fund,21),4)-year(demo.Birth_date)) END AS 'TgtCheck'
	FROM [DevRaw].[dbo].[Fund_Balances_n_CostBasis_EOM] AS fbc
	LEFT JOIN [DevRaw].[dbo].[Demographic_Data_EOM] AS demo
		ON fbc.Calendar_day = demo.Calendar_day
		AND fbc.Plan_number = demo.Plan_number
		AND fbc.SSN = demo.SSN
	WHERE fbc.Plan_number = '75951'
	GROUP BY fbc.SSN, fbc.Calendar_day, Fund, Market_value
		,CASE WHEN fbc.fund IN ('0458-FID GOVT MMKT'
			,'2328-FID 500 INDEX'
			,'2352-FID MID CAP IDX'
			,'2358-FID SM CAP IDX'
			,'2834-FID TOTAL INTL IDX'
			,'2944-FID TOTAL BOND K6'
			,'3704-MIP CL 2'
			,'2764-FID FDM IDX INC IPR')
		THEN 0 ELSE (Right(LEFT(fbc.fund,21),4)-year(demo.Birth_date)) END
	)

--Fourth CTE groups the first and third together as its own table. Adds a Single Fund under column Identifier for future use.
--Also calulates if in the correct TGT fund based on difference between DoB and TFT. Currently set has to be within 7 years of ideal of 65.
,SingleCount AS(
	SELECT m.Calendar_day
		,m.Fund
		,SUM(m.TotalMKTValue) as TotalMKTS
		,SUM(SCP.SCounts) AS Counts
		,SCP.AgeGroup
	--Adjust first line for how close to target they have to be. 0 error is 65, 5 years of error is 60-70 etc....
		,CASE WHEN TgtCheck BETWEEN 58 AND 72 THEN 'Correct TGT' 
	--If over 75, it is acceptable for them to be in the income fund.
		WHEN AgeGroup IN ('75+') AND Fund IN ('2764-FID FDM IDX INC IPR') THEN 'Old correct'
		ELSE 'Wrong' END AS TgtValidation
		,CASE WHEN m.Calendar_day IS NULL THEN NULL ELSE 'Single Fund' END AS Identifier
	FROM Monies AS M
	LEFT JOIN SingleCountPrep AS SCP
		ON m.Calendar_day = SCP.Calendar_day
		AND m.SSN = SCP.SSN
	WHERE SCounts = 1
--			AND m.Calendar_day = '6/30/2022'
	GROUP BY m.Calendar_day
		,m.Fund
		,SCP.AgeGroup
		,CASE WHEN TgtCheck BETWEEN 58 AND 72 THEN 'Correct TGT' 
		WHEN AgeGroup IN ('75+') AND Fund IN ('2764-FID FDM IDX INC IPR') THEN 'Old correct'
		ELSE 'Wrong' END
	)

--Fifth CTE groups the Second and third together as its own table. Adds a 2+ Fund under column Identifier for future use.
--Also calulates if in the correct TGT fund based on difference between DoB and TFT. Currently set has to be within 7 years of ideal of 65.
,MultipleCount AS (
	SELECT m.Calendar_day
		,m.Fund
	--	,SUM(m.Market_value) AS MKTtotal
		,SUM(m.TotalMKTValue) as TotalMKTS
		,SUM(MCP.MCounts) AS Counts
		,MCP.AgeGroup
	--Adjust first line for how close to target they have to be. 0 error is 65, 5 years of error is 60-70 etc....
		,CASE WHEN TgtCheck BETWEEN 58 AND 72 THEN 'Correct TGT'
	--If over 75, it is acceptable for them to be in the income fund.
			WHEN AgeGroup IN ('75+') AND Fund IN ('2764-FID FDM IDX INC IPR') THEN 'Old correct'
			ELSE 'Wrong' END AS TgtValidation
		,CASE WHEN m.Calendar_day IS NULL THEN NULL ELSE '2+ Funds' END AS Identifier
	FROM Monies AS M
	LEFT JOIN MultipleCountPrep AS MCP
		ON m.Calendar_day = MCP.Calendar_day
		AND m.SSN = MCP.SSN
	WHERE MCounts = 1
--		AND m.Calendar_day = '6/30/2022'
	GROUP BY m.Calendar_day
		,m.Fund
		,MCP.AgeGroup
		,CASE WHEN TgtCheck BETWEEN 58 AND 72 THEN 'Correct TGT'
			WHEN AgeGroup IN ('75+') AND Fund IN ('2764-FID FDM IDX INC IPR') THEN 'Old correct'
			ELSE 'Wrong' END
	--ORDER BY m.Calendar_day, Fund, AgeGroup2
	)

--Commit a union one the fourth and fifth CTEs as they are have all the same column names. Use Identifier column to know if a single or multiple fund.	
SELECT *
FROM SingleCount
UNION (SELECT * FROM MultipleCount)
ORDER BY Calendar_day desc
	,Fund desc
	,AgeGroup ASC
	,Identifier 