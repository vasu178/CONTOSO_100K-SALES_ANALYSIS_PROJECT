WITH customer_last_purchase AS(
SELECT
	customerkey,
	orderdate,
	customer_name ,
	first_purchase_date,
	cohort_year,
	ROW_NUMBER() OVER(PARTITION BY customerkey ORDER BY orderdate DESC )AS rn
FROM
	cohort_analysis
WHERE first_purchase_date >= current_date -INTERVAL '5 years'
)
,
churned_customers AS 
(
	SELECT
		customerkey,
		first_purchase_date ,
		cohort_year,
		customer_name,
		CASE
			WHEN orderdate >= (
				SELECT
					max(orderdate)
					FROM sales
			)::date - INTERVAL '6 months' THEN 'Active'
			ELSE 'Churned'
		END AS customer_churn
	FROM
		customer_last_purchase
	WHERE
		rn = 1
		AND first_purchase_date < (
			SELECT
				max(orderdate)
			FROM
				sales
		) ::date -INTERVAL '6 months'
)
SELECT 
	customer_churn,
	cohort_year,
	count(customerkey),
	sum(count(customerkey)) OVER (PARTITION BY cohort_year) AS total_customers,
	round(count(customerkey)/sum(count(customerkey)) over(PARTITION BY cohort_year),2) AS churn_percentage
FROM 
	churned_customers
GROUP BY customer_churn,cohort_year
ORDER BY cohort_year