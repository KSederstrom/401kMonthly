----------------------------------------
----Summarize distribution information by month, status type (summarized), and transaction type/description.
----------------------------------------
With TransactionCount as (
--This is to count the unique SSNs for each Transaction type. 
	SELECT EOMONTH(Calendar_day) as Month
	,COUNT(distinct SSN) as UniqueTransactionCounts
	,Transaction_type
	FROM [DevRaw].[dbo].[Loans_Withdrawals]
	WHERE plan_number = '75951'
	GROUP BY EOMONTH(Calendar_day)
	,Transaction_type
	)

,DescriptionCount as (
--This is to count the unique SSNs for each withdrawal description
	SELECT EOMONTH(Calendar_day) as Month
	,COUNT(distinct SSN) as UniqueDescriptionCounts
	,Transaction_type
	,Withdrawal_description
	FROM [DevRaw].[dbo].[Loans_Withdrawals]
	WHERE plan_number = '75951'
	GROUP BY EOMONTH(Calendar_day)
	,Transaction_type
	,Withdrawal_description
	)

--This CTE is to grab status, deminimus, and transaction information. It will also grab dollar total and averages	
,SubLvl AS (SELECT EOMONTH(calendar_day) as MonthEnd
--Change all Statuses into either Active or terminated
	 ,CASE WHEN Status IN ('A-ACTIVE','E-ELIGIBLE','L-LEAVE OF ABSENCE','H-REHIRE') THEN 'Active'
		WHEN Status IN ('B-BENEFICIARY-SPOUSE','D-DECEASED','Q-QDRO SPOUSAL','R-RETIRED','T-TERMINATED','V-QDRO NON-SPOUSAL','Y-NON-SPOUSE BENE') THEN 'Terminated'
		ELSE 'Undefined' END AS StatusSummary
	 ,Transaction_type
	 ,Withdrawal_description
--Grab the Total cash, count of transationcs, and count of Unique/distinct transactions. AVG?
     ,SUM(Price) PriceTotal
	 ,AVG(Price) PriceAvg
     ,SUM(Cash_amount) 'Cash_Total'
	 ,COUNT(SSN) AS SSN_Count
	 ,Fund
--Give identifier to Deminimis people. Deminimis is manually calculated. 
--Transaction type: "9-Withdrawal", Cash is less than -$5,000, Description is "Full Payout", status is Terminated. This will still be an approximation. 
--Must add Deminimus dates manually.
	,CASE WHEN ((Withdrawal_description = 'FULL PAYOUT - PREAPPROVED')
		AND Status in ( 'B-BENEFICIARY-SPOUSE', 'D-DECEASED', 'Q-QDRO SPOUSAL', 'R-RETIRED', 'T-TERMINATED', 'V-QDRO NON-SPOUSAL', 'Y-NON-SPOUSE BENE')
		AND (Trade_date in ('12/23/2019', '3/23/2020', '6/22/2020', '9/21/2020', '12/28/2020', '3/29/2021', '6/28/2021', '9/27/2021', '12/27/2021', '3/28/2022'))
		AND Cash_amount BETWEEN -5000 AND 0)
		THEN 'Deminimus' ELSE 'Normal' END AS 'Deminimis'
--Label things as being a Withdrawal, Loan or Hardship
	,CASE WHEN Withdrawal_description in ('E-CERTIFIED HARDSHIP PREAPPROVED') THEN 'Hardship'
		WHEN Withdrawal_description in ('HOME LOAN - SPONSOR DIRECTED', 'GENERAL LOAN - PREAPPROVED') THEN 'Loan'
		WHEN Withdrawal_description in ('FULL PAYOUT - PREAPPROVED', 
			'PARTIAL WITHDRAWAL - PREAPPROVED', 
			'ROLLOVER WITHDRAWAL - PREAPPROVED', 
			'SWP - PREAPPROVED',
			'AGE 59.5 WITHDRAWAL - PREAPPROVED',
			'CORONAVIRUS (CARES ACT) DISTRIBUTION PRE',
			'HEART ACT WITHDRAWAL - PREAPPROVED',
			'MRD - PREAPPROVED',
			'PMRD - PREAPPROVED') THEN 'Withdrawal'
		WHEN Withdrawal_description IS NULL AND Transaction_type IN ('9-Withdrawal') THEN 'Withdrawal'
		ELSE 'Missed' END AS 'Transaction_Summary'
	FROM [DevRaw].[dbo].[Loans_Withdrawals]
	WHERE Plan_number = '75951'
	GROUP BY Transaction_type
		 ,Withdrawal_description
		 ,Plan_number
		 ,EOMONTH(calendar_day)
		 ,CASE WHEN Status IN ('A-ACTIVE','E-ELIGIBLE','L-LEAVE OF ABSENCE','H-REHIRE') THEN 'Active'
			WHEN Status IN ('B-BENEFICIARY-SPOUSE','D-DECEASED','Q-QDRO SPOUSAL','R-RETIRED','T-TERMINATED','V-QDRO NON-SPOUSAL','Y-NON-SPOUSE BENE') THEN 'Terminated'
			ELSE 'Undefined' END
		,CASE WHEN ((Withdrawal_description = 'FULL PAYOUT - PREAPPROVED')
			AND Status in ( 'B-BENEFICIARY-SPOUSE', 'D-DECEASED', 'Q-QDRO SPOUSAL', 'R-RETIRED', 'T-TERMINATED', 'V-QDRO NON-SPOUSAL', 'Y-NON-SPOUSE BENE')
			AND (Trade_date in ('12/23/2019', '3/23/2020', '6/22/2020', '9/21/2020', '12/28/2020', '3/29/2021', '6/28/2021', '9/27/2021', '12/27/2021', '3/28/2022')) 
			AND Cash_amount BETWEEN -5000 AND 0)
			THEN 'Deminimus' ELSE 'Normal' END
		,Fund
		,CASE WHEN Withdrawal_description in ('E-CERTIFIED HARDSHIP PREAPPROVED') THEN 'Hardship'
			WHEN Withdrawal_description in ('HOME LOAN - SPONSOR DIRECTED', 'GENERAL LOAN - PREAPPROVED') THEN 'Loan'
			WHEN Withdrawal_description in ('FULL PAYOUT - PREAPPROVED', 
				'PARTIAL WITHDRAWAL - PREAPPROVED', 
				'ROLLOVER WITHDRAWAL - PREAPPROVED', 
				'SWP - PREAPPROVED',
				'AGE 59.5 WITHDRAWAL - PREAPPROVED',
				'CORONAVIRUS (CARES ACT) DISTRIBUTION PRE',
				'HEART ACT WITHDRAWAL - PREAPPROVED',
				'MRD - PREAPPROVED',
				'PMRD - PREAPPROVED') THEN 'Withdrawal'
			WHEN Withdrawal_description IS NULL AND Transaction_type IN ('9-Withdrawal') THEN 'Withdrawal'
			ELSE 'Missed' END
	--	,Source
--ORDER BY EOMONTH(calendar_day) desc, Withdrawal_description 
	)

,TransactionSummaryCounts AS (
	SELECT eomonth (Calendar_day) AS MonthEnd
		,COUNT(Distinct SSN) AS Count_TransactionSummary
		,CASE WHEN Withdrawal_description in ('E-CERTIFIED HARDSHIP PREAPPROVED') THEN 'Hardship'
		WHEN Withdrawal_description in ('HOME LOAN - SPONSOR DIRECTED', 'GENERAL LOAN - PREAPPROVED') THEN 'Loan'
		WHEN Withdrawal_description in ('FULL PAYOUT - PREAPPROVED', 
			'PARTIAL WITHDRAWAL - PREAPPROVED', 
			'ROLLOVER WITHDRAWAL - PREAPPROVED', 
			'SWP - PREAPPROVED',
			'AGE 59.5 WITHDRAWAL - PREAPPROVED',
			'CORONAVIRUS (CARES ACT) DISTRIBUTION PRE',
			'HEART ACT WITHDRAWAL - PREAPPROVED',
			'MRD - PREAPPROVED',
			'PMRD - PREAPPROVED') THEN 'Withdrawal'
		WHEN Withdrawal_description IS NULL AND Transaction_type IN ('9-Withdrawal') THEN 'Withdrawal'
		ELSE 'Missed' END AS 'Transaction_Summary'
	FROM [DevRaw].[dbo].[Loans_Withdrawals]
		WHERE Plan_number = '75951'
	GROUP BY eomonth (Calendar_day)
		,CASE WHEN Withdrawal_description in ('E-CERTIFIED HARDSHIP PREAPPROVED') THEN 'Hardship'
		WHEN Withdrawal_description in ('HOME LOAN - SPONSOR DIRECTED', 'GENERAL LOAN - PREAPPROVED') THEN 'Loan'
		WHEN Withdrawal_description in ('FULL PAYOUT - PREAPPROVED', 
			'PARTIAL WITHDRAWAL - PREAPPROVED', 
			'ROLLOVER WITHDRAWAL - PREAPPROVED', 
			'SWP - PREAPPROVED',
			'AGE 59.5 WITHDRAWAL - PREAPPROVED',
			'CORONAVIRUS (CARES ACT) DISTRIBUTION PRE',
			'HEART ACT WITHDRAWAL - PREAPPROVED',
			'MRD - PREAPPROVED',
			'PMRD - PREAPPROVED') THEN 'Withdrawal'
		WHEN Withdrawal_description IS NULL AND Transaction_type IN ('9-Withdrawal') THEN 'Withdrawal'
		ELSE 'Missed' END
	)

SELECT S.MonthEnd
	,StatusSummary
	,S.Transaction_type
	,S.Transaction_Summary
	,S.Withdrawal_description
	,Deminimis
	,PriceTotal
	,PriceAvg
	,Cash_Total
	,TC.UniqueTransactionCounts 
	,DC.UniqueDescriptionCounts --This is the unique SSNs for the withdrawal description each month.
	,SSN_Count
	,TS.Count_TransactionSummary
	,Fund
	,Year(S.MonthEnd) AS years
	,MONTH(S.MonthEnd) AS months
FROM SubLvl AS S
LEFT JOIN TransactionCount AS TC
	ON S.MonthEnd = TC.Month
	AND S.Transaction_type = TC.Transaction_type
LEFT JOIN DescriptionCount AS DC
	ON S.MonthEnd = DC.Month
	AND S.Transaction_type = DC.Transaction_type
	AND S.Withdrawal_description = DC.Withdrawal_description
LEFT JOIN TransactionSummaryCounts AS TS
	ON TS.monthend = S.MonthEnd
	AND TS.transaction_Summary = S.Transaction_Summary
ORDER BY MonthEnd desc, Transaction_type asc, Withdrawal_description desc