--Grab and consolidate information for Fund Exchange Balance, Count, and Averages tabs.
--Include dates by month, total cash, count of transactions, and the trasaction type (exchange in and out only). 
--Should also be restricted by 401k only. 
SELECT EOMONTH(Calendar_day) EndOMonth
--CASE WHEN for separating the Actives and Terminated participants. 
/*	,CASE WHEN Status in 
		('D-DECEASED','I-INACTIVE', 'Q-QDRO SPOUSAL','R-RETIRED', 'T-TERMINATED', 'V-QDRO NON-SPOUSAL', 'Y-NON-SPOUSE BENE') THEN 'Terminated'
		ELSE 'Active'
		END as StatusSummary*/
	,Fund
	,Transaction_type
	,SUM(Cash_amount) AS Cash_Total
	,COUNT(Cash_amount) AS Cash_Count
	,AVG(Cash_amount) AS AVGCash
	,COUNT(SSN) SSNCount
	,COUNT (distinct SSN) UniqueSSNCount
  FROM [DevRaw].[dbo].[Audit_Participant_Level_Activity_Report]
  WHERE Plan_number in ('75951')
	AND Transaction_type in ('5-Exchange In','12-Exchange Out')
  GROUP BY EOMONTH(Calendar_day)
--CASE WHEN for separating the Actives and Terminated participants. 
/*	,CASE WHEN Status in 
		('D-DECEASED','I-INACTIVE', 'Q-QDRO SPOUSAL','R-RETIRED', 'T-TERMINATED', 'V-QDRO NON-SPOUSAL', 'Y-NON-SPOUSE BENE') THEN 'Terminated'
		ELSE 'Active'
		END*/
	,Fund
	,Transaction_type
  ORDER BY EOMONTH(Calendar_day) desc