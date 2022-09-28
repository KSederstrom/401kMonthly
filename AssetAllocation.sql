---------------------------------------
--INVESTMENT ASSET Allocation tab. Sum money by fund and month. 401k only.
---------------------------------------
SELECT Calendar_day
	,Fund
	,SUM(Market_value) AS MKTvalue
	,COUNT(Market_value) AS CountNFund
FROM [DevRaw].[dbo].[Fund_Balances_n_CostBasis_EOM]
WHERE Plan_number = '75951'
GROUP BY Calendar_day
	,Fund
ORDER BY Calendar_day desc