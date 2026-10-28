CREATE TEMP TABLE build_checks(check_name text, passed boolean, detail text) ON
COMMIT
DROP;


INSERT INTO build_checks
SELECT
    'rows:product_category_translation',

    (SELECT count(*)
     FROM core.product_category_translation) =
    (SELECT count(*)
     FROM raw.product_category_translation),
    count(*)::text
FROM core.product_category_translation;


INSERT INTO build_checks
SELECT
    'source_preserved:product_category_translation',
    NOT EXISTS (
                    (SELECT
                         product_category_name,
                         product_category_name_english,
                         _source_file,
                         _loaded_at
                     FROM raw.product_category_translation
                     EXCEPT ALL SELECT
                         product_category_name,
                         product_category_name_english,
                         _source_file,
                         _loaded_at
                     FROM core.product_category_translation)
                UNION ALL
                    (SELECT
                         product_category_name,
                         product_category_name_english,
                         _source_file,
                         _loaded_at
                     FROM core.product_category_translation
                     EXCEPT ALL SELECT
                         product_category_name,
                         product_category_name_english,
                         _source_file,
                         _loaded_at
                     FROM raw.product_category_translation)), 'all source columns, both directions';


INSERT INTO build_checks
SELECT
    'rows:customer_context',

    (SELECT count(*)
     FROM core.customer_context) =
    (SELECT count(*)
     FROM raw.customers),
    count(*)::text
FROM core.customer_context;


INSERT INTO build_checks
SELECT
    'source_preserved:customer_context',
    NOT EXISTS (
                    (SELECT
                         customer_id,
                         customer_unique_id,
                         customer_zip_code_prefix,
                         customer_city,
                         customer_state,
                         _source_file,
                         _loaded_at
                     FROM raw.customers
                     EXCEPT ALL SELECT
                         customer_id,
                         customer_unique_id,
                         customer_zip_code_prefix,
                         customer_city,
                         customer_state,
                         _source_file,
                         _loaded_at
                     FROM core.customer_context)
                UNION ALL
                    (SELECT
                         customer_id,
                         customer_unique_id,
                         customer_zip_code_prefix,
                         customer_city,
                         customer_state,
                         _source_file,
                         _loaded_at
                     FROM core.customer_context
                     EXCEPT ALL SELECT
                         customer_id,
                         customer_unique_id,
                         customer_zip_code_prefix,
                         customer_city,
                         customer_state,
                         _source_file,
                         _loaded_at
                     FROM raw.customers)), 'all source columns, both directions';


INSERT INTO build_checks
SELECT
    'rows:sellers',

    (SELECT count(*)
     FROM core.sellers) =
    (SELECT count(*)
     FROM raw.sellers),
    count(*)::text
FROM core.sellers;


INSERT INTO build_checks
SELECT
    'source_preserved:sellers',
    NOT EXISTS (
                    (SELECT
                         seller_id,
                         seller_zip_code_prefix,
                         seller_city,
                         seller_state,
                         _source_file,
                         _loaded_at
                     FROM raw.sellers
                     EXCEPT ALL SELECT
                         seller_id,
                         seller_zip_code_prefix,
                         seller_city,
                         seller_state,
                         _source_file,
                         _loaded_at
                     FROM core.sellers)
                UNION ALL
                    (SELECT
                         seller_id,
                         seller_zip_code_prefix,
                         seller_city,
                         seller_state,
                         _source_file,
                         _loaded_at
                     FROM core.sellers
                     EXCEPT ALL SELECT
                         seller_id,
                         seller_zip_code_prefix,
                         seller_city,
                         seller_state,
                         _source_file,
                         _loaded_at
                     FROM raw.sellers)), 'all source columns, both directions';


INSERT INTO build_checks
SELECT
    'rows:products',

    (SELECT count(*)
     FROM core.products) =
    (SELECT count(*)
     FROM raw.products),
    count(*)::text
FROM core.products;


INSERT INTO build_checks
SELECT
    'source_preserved:products',
    NOT EXISTS (
                    (SELECT
                         product_id,
                         product_category_name,
                         nullif(btrim(product_name_lenght), '')::integer,
                         nullif(btrim(product_description_lenght), '')::integer,
                         nullif(btrim(product_photos_qty), '')::integer,
                         nullif(btrim(product_weight_g), '')::integer,
                         nullif(btrim(product_length_cm), '')::integer,
                         nullif(btrim(product_height_cm), '')::integer,
                         nullif(btrim(product_width_cm), '')::integer,
                         _source_file,
                         _loaded_at
                     FROM raw.products
                     EXCEPT ALL SELECT
                         product_id,
                         product_category_name,
                         product_name_lenght,
                         product_description_lenght,
                         product_photos_qty,
                         product_weight_g,
                         product_length_cm,
                         product_height_cm,
                         product_width_cm,
                         _source_file,
                         _loaded_at
                     FROM core.products)
                UNION ALL
                    (SELECT
                         product_id,
                         product_category_name,
                         product_name_lenght,
                         product_description_lenght,
                         product_photos_qty,
                         product_weight_g,
                         product_length_cm,
                         product_height_cm,
                         product_width_cm,
                         _source_file,
                         _loaded_at
                     FROM core.products
                     EXCEPT ALL SELECT
                         product_id,
                         product_category_name,
                         nullif(btrim(product_name_lenght), '')::integer,
                         nullif(btrim(product_description_lenght), '')::integer,
                         nullif(btrim(product_photos_qty), '')::integer,
                         nullif(btrim(product_weight_g), '')::integer,
                         nullif(btrim(product_length_cm), '')::integer,
                         nullif(btrim(product_height_cm), '')::integer,
                         nullif(btrim(product_width_cm), '')::integer,
                         _source_file,
                         _loaded_at
                     FROM raw.products)), 'all source columns, both directions';


INSERT INTO build_checks
SELECT
    'rows:orders',

    (SELECT count(*)
     FROM core.orders) =
    (SELECT count(*)
     FROM raw.orders),
    count(*)::text
FROM core.orders;


INSERT INTO build_checks
SELECT
    'source_preserved:orders',
    NOT EXISTS (
                    (SELECT
                         order_id,
                         customer_id,
                         order_status,
                         nullif(btrim(order_purchase_timestamp), '')::timestamp WITHOUT TIME
                         ZONE,
                         nullif(btrim(order_approved_at), '')::timestamp WITHOUT TIME
                         ZONE,
                         nullif(btrim(order_delivered_carrier_date), '')::timestamp WITHOUT TIME
                         ZONE,
                         nullif(btrim(order_delivered_customer_date), '')::timestamp WITHOUT TIME
                         ZONE,
                         nullif(btrim(order_estimated_delivery_date), '')::timestamp WITHOUT TIME
                         ZONE,
                         _source_file,
                         _loaded_at
                     FROM raw.orders
                     EXCEPT ALL SELECT
                         order_id,
                         customer_id,
                         order_status,
                         order_purchase_timestamp,
                         order_approved_at,
                         order_delivered_carrier_date,
                         order_delivered_customer_date,
                         order_estimated_delivery_date,
                         _source_file,
                         _loaded_at
                     FROM core.orders
                     JOIN core.orders_delivery USING(order_id))
                UNION ALL
                    (SELECT
                         order_id,
                         customer_id,
                         order_status,
                         order_purchase_timestamp,
                         order_approved_at,
                         order_delivered_carrier_date,
                         order_delivered_customer_date,
                         order_estimated_delivery_date,
                         _source_file,
                         _loaded_at
                     FROM core.orders
                     JOIN core.orders_delivery USING(order_id)
                     EXCEPT ALL SELECT
                         order_id,
                         customer_id,
                         order_status,
                         nullif(btrim(order_purchase_timestamp), '')::timestamp WITHOUT TIME
                         ZONE,
                         nullif(btrim(order_approved_at), '')::timestamp WITHOUT TIME
                         ZONE,
                         nullif(btrim(order_delivered_carrier_date), '')::timestamp WITHOUT TIME
                         ZONE,
                         nullif(btrim(order_delivered_customer_date), '')::timestamp WITHOUT TIME
                         ZONE,
                         nullif(btrim(order_estimated_delivery_date), '')::timestamp WITHOUT TIME
                         ZONE,
                         _source_file,
                         _loaded_at
                     FROM raw.orders)), 'all source columns, both directions';


INSERT INTO build_checks
SELECT
    'rows:order_items',

    (SELECT count(*)
     FROM core.order_items) =
    (SELECT count(*)
     FROM raw.order_items),
    count(*)::text
FROM core.order_items;


INSERT INTO build_checks
SELECT
    'source_preserved:order_items',
    NOT EXISTS (
                    (SELECT
                         order_id,
                         nullif(btrim(order_item_id), '')::integer,
                         product_id,
                         seller_id,
                         nullif(btrim(shipping_limit_date), '')::timestamp WITHOUT TIME
                         ZONE,
                         nullif(btrim(price), '')::numeric(18, 2),
                         nullif(btrim(freight_value), '')::numeric(18, 2),
                         _source_file,
                         _loaded_at
                     FROM raw.order_items
                     EXCEPT ALL SELECT
                         order_id,
                         order_item_id,
                         product_id,
                         seller_id,
                         shipping_limit_date,
                         price,
                         freight_value,
                         _source_file,
                         _loaded_at
                     FROM core.order_items)
                UNION ALL
                    (SELECT
                         order_id,
                         order_item_id,
                         product_id,
                         seller_id,
                         shipping_limit_date,
                         price,
                         freight_value,
                         _source_file,
                         _loaded_at
                     FROM core.order_items
                     EXCEPT ALL SELECT
                         order_id,
                         nullif(btrim(order_item_id), '')::integer,
                         product_id,
                         seller_id,
                         nullif(btrim(shipping_limit_date), '')::timestamp WITHOUT TIME
                         ZONE,
                         nullif(btrim(price), '')::numeric(18, 2),
                         nullif(btrim(freight_value), '')::numeric(18, 2),
                         _source_file,
                         _loaded_at
                     FROM raw.order_items)), 'all source columns, both directions';


INSERT INTO build_checks
SELECT
    'rows:order_payments',

    (SELECT count(*)
     FROM core.order_payments) =
    (SELECT count(*)
     FROM raw.order_payments),
    count(*)::text
FROM core.order_payments;


INSERT INTO build_checks
SELECT
    'source_preserved:order_payments',
    NOT EXISTS (
                    (SELECT
                         order_id,
                         nullif(btrim(payment_sequential), '')::integer,
                         payment_type,
                         nullif(btrim(payment_installments), '')::integer,
                         nullif(btrim(payment_value), '')::numeric(18, 2),
                         _source_file,
                         _loaded_at
                     FROM raw.order_payments
                     EXCEPT ALL SELECT
                         order_id,
                         payment_sequential,
                         payment_type,
                         payment_installments,
                         payment_value,
                         _source_file,
                         _loaded_at
                     FROM core.order_payments)
                UNION ALL
                    (SELECT
                         order_id,
                         payment_sequential,
                         payment_type,
                         payment_installments,
                         payment_value,
                         _source_file,
                         _loaded_at
                     FROM core.order_payments
                     EXCEPT ALL SELECT
                         order_id,
                         nullif(btrim(payment_sequential), '')::integer,
                         payment_type,
                         nullif(btrim(payment_installments), '')::integer,
                         nullif(btrim(payment_value), '')::numeric(18, 2),
                         _source_file,
                         _loaded_at
                     FROM raw.order_payments)), 'all source columns, both directions';


INSERT INTO build_checks
SELECT
    'rows:order_reviews',

    (SELECT count(*)
     FROM core.order_reviews) =
    (SELECT count(*)
     FROM raw.order_reviews),
    count(*)::text
FROM core.order_reviews;


INSERT INTO build_checks
SELECT
    'source_preserved:order_reviews',
    NOT EXISTS (
                    (SELECT
                         review_id,
                         order_id,
                         nullif(btrim(review_score), '')::integer,
                         review_comment_title,
                         review_comment_message,
                         nullif(btrim(review_creation_date), '')::timestamp WITHOUT TIME
                         ZONE,
                         nullif(btrim(review_answer_timestamp), '')::timestamp WITHOUT TIME
                         ZONE,
                         _source_file,
                         _loaded_at
                     FROM raw.order_reviews
                     EXCEPT ALL SELECT
                         review_id,
                         order_id,
                         review_score,
                         review_comment_title,
                         review_comment_message,
                         review_creation_date,
                         review_answer_timestamp,
                         _source_file,
                         _loaded_at
                     FROM core.order_reviews)
                UNION ALL
                    (SELECT
                         review_id,
                         order_id,
                         review_score,
                         review_comment_title,
                         review_comment_message,
                         review_creation_date,
                         review_answer_timestamp,
                         _source_file,
                         _loaded_at
                     FROM core.order_reviews
                     EXCEPT ALL SELECT
                         review_id,
                         order_id,
                         nullif(btrim(review_score), '')::integer,
                         review_comment_title,
                         review_comment_message,
                         nullif(btrim(review_creation_date), '')::timestamp WITHOUT TIME
                         ZONE,
                         nullif(btrim(review_answer_timestamp), '')::timestamp WITHOUT TIME
                         ZONE,
                         _source_file,
                         _loaded_at
                     FROM raw.order_reviews)), 'all source columns, both directions';


INSERT INTO build_checks
SELECT
    'sum:price',

    (SELECT sum(price)
     FROM core.order_items) =
    (SELECT sum(price::numeric)
     FROM raw.order_items),
    (SELECT sum(price)::text
     FROM core.order_items);


INSERT INTO build_checks
SELECT
    'no_money_rounding:price',
    NOT EXISTS
    (SELECT
     FROM raw.order_items
     WHERE price::numeric <> round(price::numeric, 2)),'exact cents';


INSERT INTO build_checks
SELECT
    'sum:freight_value',

    (SELECT sum(freight_value)
     FROM core.order_items) =
    (SELECT sum(freight_value::numeric)
     FROM raw.order_items),
    (SELECT sum(freight_value)::text
     FROM core.order_items);


INSERT INTO build_checks
SELECT
    'no_money_rounding:freight_value',
    NOT EXISTS
    (SELECT
     FROM raw.order_items
     WHERE freight_value::numeric <> round(freight_value::numeric, 2)),'exact cents';


INSERT INTO build_checks
SELECT
    'sum:payment_value',

    (SELECT sum(payment_value)
     FROM core.order_payments) =
    (SELECT sum(payment_value::numeric)
     FROM raw.order_payments),
    (SELECT sum(payment_value)::text
     FROM core.order_payments);


INSERT INTO build_checks
SELECT
    'no_money_rounding:payment_value',
    NOT EXISTS
    (SELECT
     FROM raw.order_payments
     WHERE payment_value::numeric <> round(payment_value::numeric, 2)),'exact cents';


INSERT INTO build_checks
SELECT
    'order_grain',
    count(*) = count(DISTINCT order_id)
AND
    count(*) =
    (SELECT count(*)
     FROM core.orders),
    count(*)::text
FROM mart.order_finance;


INSERT INTO build_checks
SELECT
    'no_goods_fanout',
    sum(goods_value) =
    (SELECT sum(price)
     FROM core.order_items),
    sum(goods_value)::text
FROM mart.order_finance;


INSERT INTO build_checks
SELECT
    'no_payments_fanout',
    sum(payment_value) =
    (SELECT sum(payment_value)
     FROM core.order_payments),
    sum(payment_value)::text
FROM mart.order_finance;


INSERT INTO build_checks
SELECT
    'unknown_products',
    count(*) = 610,
    count(*)::text
FROM core.products
WHERE category_key = 'UNKNOWN';


INSERT INTO build_checks
SELECT
    'calendar',
    count(*) = 24
AND count(*)
    FILTER(
           WHERE revenue = 0) = 1,
    count(*)::text
FROM mart.monthly_sales;


INSERT INTO build_checks
SELECT
    'monthly_total',
    sum(revenue) = 13221498.11,
    sum(revenue)::text
FROM mart.monthly_sales;


INSERT INTO build_checks
SELECT
    'monthly_source_reconciliation',
    sum(revenue) =
    (SELECT sum(i.price)
     FROM core.order_items i
     JOIN core.orders o USING(order_id)
     WHERE o.order_status = 'delivered'
         AND o.order_purchase_timestamp >= timestamp '2016-09-01'
         AND o.order_purchase_timestamp < timestamp '2018-09-01'),
    sum(revenue)::text
FROM mart.monthly_sales;


INSERT INTO build_checks
SELECT
    'foreign_keys_validated',
    bool_and(convalidated),
    count(*)::text
FROM pg_constraint
WHERE connamespace = 'core'::regnamespace
    AND contype = 'f';


INSERT INTO build_checks
SELECT
    'delivery_1_to_1',
    count(*) =
    (SELECT count(*)
     FROM core.orders)
AND
    count(*) = count(DISTINCT order_id),
    count(*)::text
FROM core.orders_delivery;


INSERT INTO build_checks
SELECT
    'item_grain',
    count(*) =
    (SELECT count(*)
     FROM core.order_items),
    count(*)::text
FROM mart.item_sales;


INSERT INTO build_checks
SELECT
    'task2_seller_max',
    max(revenue) = 226987.93,
    max(revenue)::text
FROM mart.seller_sales;


INSERT INTO build_checks
SELECT
    'task3_aov',
    round(average_order_value, 2) = 159.88,
    average_order_value::text
FROM mart.average_order;


INSERT INTO build_checks
SELECT
    'task4_repeat',
    customers = 96096
AND repeat_customers = 2997
AND
    round(repeat_pct, 2) = 3.12,
    repeat_pct::text
FROM mart.customer_repeat;


INSERT INTO build_checks
SELECT
    'task5_categories',
    count(*) = 74
AND max(revenue) = 1233131.72
AND
    sum(revenue) = 13221498.11,
    count(*)::text
FROM mart.category_sales;


INSERT INTO build_checks
SELECT
    'seller_rating_grain',
    count(*) = count(DISTINCT seller_id)
AND
    count(*) =
    (SELECT count(*)
     FROM core.sellers),
    count(*)::text
FROM mart.seller_rating;


INSERT INTO build_checks
SELECT
    'seller_rating_bounds',
    NOT EXISTS
    (SELECT
     FROM mart.seller_rating
     WHERE rated_order_count > eligible_single_seller_order_count
         OR (rated_order_count = 0
             AND seller_rating IS NOT NULL)
         OR (rated_order_count > 0
             AND seller_rating NOT BETWEEN 1 AND 5)),'rating NULL when unrated';


INSERT INTO build_checks
SELECT
    'orders_columns',
    array_agg(COLUMN_NAME::text
              ORDER BY ordinal_position) = ARRAY[
    'order_id',
    'customer_id',
    'order_status',
    'order_purchase_timestamp',
    'order_approved_at'],string_agg(COLUMN_NAME, ', '
                                    ORDER BY ordinal_position)
FROM information_schema.columns
WHERE table_schema = 'core'
    AND TABLE_NAME = 'orders';


INSERT INTO build_checks
SELECT
    'delivery_diagnostics',
    count(*) FILTER(
                    WHERE delivered_date_missing) = 8
AND count(*) FILTER(
                    WHERE carrier_before_purchase) = 166
AND count(*)
    FILTER(
           WHERE delivered_before_carrier) = 23,
    'EDA flags preserved in view'
FROM mart.order_finance;

DO $$ BEGIN IF EXISTS(SELECT FROM build_checks WHERE passed IS DISTINCT FROM true) THEN RAISE EXCEPTION 'Build checks failed: %',(SELECT string_agg(check_name,', ') FROM build_checks WHERE passed IS DISTINCT FROM true); END IF; END $$;


SELECT *
FROM build_checks
ORDER BY check_name;
