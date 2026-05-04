
CREATE OR REPLACE VIEW public.cohort_analysis AS 
WITH customer_revenue_details AS (
         SELECT s.customerkey,
            s.orderdate,
            sum(s.netprice * s.quantity::double precision * s.exchangerate) AS revenue_per_customer,
            count(s.orderkey) AS total_orders,
            c.country,
            c.age,
            c.givenname,
            c.surname
           FROM sales s
             LEFT JOIN customer c ON s.customerkey = c.customerkey
          GROUP BY s.customerkey, c.country, c.age, c.givenname, c.surname, s.orderdate
        )
 SELECT customerkey,
    orderdate,
    revenue_per_customer,
    total_orders,
    country,
    age,
    concat(givenname , ' ',surname ) AS customer_name,
    min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
   FROM customer_revenue_details;