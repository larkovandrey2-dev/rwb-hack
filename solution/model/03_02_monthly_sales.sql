CREATE OR REPLACE VIEW mart.monthly_sales AS
SELECT
    m.month,
    count(f.order_id) AS delivered_orders,
    coalesce(sum(f.goods_value), 0::numeric) AS revenue
FROM core.calendar_month m
LEFT JOIN mart.order_finance f ON date_trunc('month', f.order_purchase_timestamp)::date = m.month
AND f.order_status = 'delivered'
GROUP BY m.month;
