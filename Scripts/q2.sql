SELECT
    cohort_year,
    SUM(revenue_per_customer ) AS total_revenue,
    COUNT(DISTINCT customerkey) AS total_customers,
    SUM(revenue_per_customer) / COUNT(DISTINCT customerkey) AS customer_revenue
FROM cohort_analysis
GROUP BY 
    cohort_year;

-- Title: Customer Revenue by Cohort (Adjusted for time in market)
WITH purchase_days AS (
    SELECT
        customerkey,
        revenue_per_customer,
        orderdate - MIN(orderdate) OVER (PARTITION BY customerkey) AS days_since_first_purchase
    FROM cohort_analysis
)

SELECT
    days_since_first_purchase,
    SUM(revenue_per_customer) as total_revenue,
    SUM(revenue_per_customer) / (SELECT SUM(revenue_per_customer) FROM cohort_analysis) * 100 as percentage_of_total_revenue,
    SUM(SUM(revenue_per_customer) / (SELECT SUM(revenue_per_customer) FROM cohort_analysis) * 100) OVER (ORDER BY days_since_first_purchase) as cumulative_percentage_of_total_revenue
FROM purchase_days
GROUP BY days_since_first_purchase
ORDER BY days_since_first_purchase;

-- Title: Customer Revenue by Cohort (Adjusted for time in market) - Only First Purchase Date
SELECT
    cohort_year,
    SUM(revenue_per_customer) AS total_revenue,
    COUNT(DISTINCT customerkey) AS total_customers,
    SUM(revenue_per_customer) / COUNT(DISTINCT customerkey) AS customer_revenue
FROM cohort_analysis
WHERE orderdate = first_purchase_date
GROUP BY 
    cohort_year;