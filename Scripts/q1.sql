WITH customer_ltv AS (
    SELECT
        customerkey,
        customer_name,
        ROUND(SUM(ca.revenue_per_customer)::NUMERIC, 2) AS total_ltv
    FROM cohort_analysis ca
    GROUP BY 
        customerkey,
        ca.customer_name
),
customer_segments AS (
    SELECT 
        PERCENTILE_CONT(.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th,
        PERCENTILE_CONT(.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th 
    FROM customer_ltv
)
,segment_values as(
SELECT 
    c.*,
    CASE 
        WHEN c.total_ltv < cs.ltv_25th THEN '1-Low value'
        WHEN c.total_ltv <= cs.ltv_75th THEN '2-Medium value'
        ELSE '3-High Value'
    END AS customer_segment
FROM customer_ltv c
CROSS JOIN customer_segments cs
)

SELECT 
customer_segment AS Customer_segments,
sum(total_ltv )AS total_revenue,
count(customerkey)AS total_customers,
sum(total_ltv )/count(customerkey) AS avg_ltv
FROM segment_values 
GROUP BY customer_segment 


