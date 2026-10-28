CREATE OR REPLACE VIEW mart.customer_repeat AS
WITH customer_orders AS
    (SELECT
         customers.customer_unique_id,
         count(*) AS order_count
     FROM core.orders AS orders
     JOIN core.customer_context AS customers USING(customer_id)
     GROUP BY customers.customer_unique_id)
SELECT
    count(*) AS customers,
    count(*) FILTER(
                    WHERE order_count > 1) AS repeat_customers,
    100.0 * count(*) FILTER(
                            WHERE order_count > 1) / nullif(count(*), 0) AS repeat_pct
FROM customer_orders;
