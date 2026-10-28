CREATE OR REPLACE VIEW mart.seller_sales AS
WITH seller_totals AS
    (SELECT
         seller_id,
         count(DISTINCT order_id) AS delivered_orders,
         count(*) AS units,
         sum(price) AS revenue
     FROM mart.item_sales
     WHERE order_status = 'delivered'
     GROUP BY seller_id)
SELECT
    sellers.seller_id,
    sellers.city_normalized AS seller_city,
    sellers.seller_state,
    coalesce(totals.delivered_orders, 0) AS delivered_orders,
    coalesce(totals.units, 0) AS units,
    coalesce(totals.revenue, 0::numeric) AS revenue
FROM core.sellers AS sellers
LEFT JOIN seller_totals AS totals USING(seller_id);
