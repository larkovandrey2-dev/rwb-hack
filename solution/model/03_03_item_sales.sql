CREATE OR REPLACE VIEW mart.item_sales AS
SELECT
    i.*,
    o.order_status,
    o.order_purchase_timestamp,
    p.category_key AS category_name,
    c.category_english,
    s.city_normalized AS seller_city,
    s.seller_state
FROM core.order_items i
JOIN core.orders o USING(order_id)
JOIN core.products p USING(product_id)
JOIN core.category c ON c.category_name = p.category_key
JOIN core.sellers s USING(seller_id);
