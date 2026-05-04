EXPLAIN ANALYZE 
 WITH customer_revenue_details AS (
	SELECT
		s.customerkey,
		s.orderdate,
		sum(s.netprice * s.quantity::double PRECISION * s.exchangerate) AS revenue_per_customer,
		count(s.orderkey) AS total_orders,
		c.country,
		c.age,
		c.givenname,
		c.surname
	FROM
		sales s
	INNER JOIN customer c ON
		s.customerkey = c.customerkey
	GROUP BY
		s.customerkey,
		c.country,
		c.age,
		c.givenname,
		c.surname,
		s.orderdateSSS
)
 SELECT
	customerkey,
	orderdate,
	revenue_per_customer,
	total_orders,
	country,
	age,
	concat(givenname, ' ', surname) AS customer_name,
	min(orderdate) OVER (
		PARTITION BY customerkey
	) AS first_purchase_date,
	EXTRACT(YEAR FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM
	customer_revenue_details;