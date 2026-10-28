CREATE OR REPLACE VIEW mart.order_finance AS WITH
    items AS
    (SELECT
         order_id,
         count(*) AS item_count,
         sum(price) AS goods_value,
         sum(freight_value) AS freight_value
     FROM core.order_items
     GROUP BY order_id),
    payments AS
    (SELECT
         order_id,
         count(*) AS payment_count,
         sum(payment_value) AS payment_value
     FROM core.order_payments
     GROUP BY order_id),
    reviews AS
    (SELECT
         order_id,
         count(*) AS review_count
     FROM core.order_reviews
     GROUP BY order_id)
SELECT
    o.*,
    d.order_delivered_carrier_date,
    d.order_delivered_customer_date,
    d.order_estimated_delivery_date,
    o.order_status = 'delivered'
AND d.order_delivered_customer_date IS
    NULL AS delivered_date_missing,
    d.order_delivered_carrier_date < o.order_purchase_timestamp AS carrier_before_purchase,
    d.order_delivered_customer_date < d.order_delivered_carrier_date AS delivered_before_carrier,
    c.customer_unique_id,
    items.order_id IS NOT NULL AS
    has_items,
    coalesce(items.item_count, 0) AS item_count,
    items.goods_value,
    items.freight_value,
    items.goods_value + items.freight_value AS order_value,
    coalesce(payments.payment_count, 0) AS payment_count,
    payments.payment_value,
    payments.payment_value - items.goods_value - items.freight_value AS payment_gap,
    coalesce(reviews.review_count, 0) AS review_count
FROM core.orders o
JOIN core.orders_delivery d USING(order_id)
JOIN core.customer_context c USING(customer_id)
LEFT JOIN items USING(order_id)
LEFT JOIN payments USING(order_id)
LEFT JOIN reviews USING(order_id);
