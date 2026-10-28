CREATE OR REPLACE VIEW mart.overview AS
SELECT

    (SELECT sum(revenue)
     FROM mart.monthly_sales) AS revenue,
    a.*,
    c.customers,
    c.repeat_customers,
    c.repeat_pct,
    date '2016-09-01' AS monthly_period_start,
    date '2018-09-01' AS monthly_period_end_exclusive
FROM mart.average_order a
CROSS JOIN mart.customer_repeat c;
