CREATE OR REPLACE VIEW mart.average_order AS
SELECT
    avg(order_value) AS average_order_value,
    avg(item_count) AS average_lines,
    avg(item_count) AS average_units,
    count(*) AS delivered_orders
FROM mart.order_finance
WHERE order_status = 'delivered';
