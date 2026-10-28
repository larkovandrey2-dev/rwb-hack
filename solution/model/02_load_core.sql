TRUNCATE
    core.customer,
    core.category,
    core.calendar_month,
    core.product_category_translation,
    core.customer_context,
    core.sellers,
    core.products,
    core.orders,
    core.orders_delivery,
    core.order_items,
    core.order_payments,
    core.order_reviews;


INSERT INTO core.customer
SELECT DISTINCT customer_unique_id
FROM raw.customers;


INSERT INTO core.category
SELECT
    n,
    t.product_category_name_english,
    n = 'UNKNOWN',
    n <> 'UNKNOWN'
AND t.product_category_name_english IS NULL
FROM
    (SELECT product_category_name AS n
     FROM raw.product_category_translation
     UNION SELECT nullif(btrim(product_category_name), '')
     FROM raw.products
     UNION SELECT 'UNKNOWN') c
LEFT JOIN raw.product_category_translation t ON t.product_category_name = c.n
WHERE n IS NOT NULL;


INSERT INTO core.calendar_month
SELECT d::date
FROM generate_series(date '2016-09-01',date '2018-08-01',interval '1 month') d;


INSERT INTO core.product_category_translation (product_category_name, product_category_name_english, _source_file, _loaded_at)
SELECT
    product_category_name,
    product_category_name_english,
    _source_file,
    _loaded_at
FROM raw.product_category_translation;


INSERT INTO core.customer_context (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state, _source_file, _loaded_at, city_normalized, zip_prefix_normalized)
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    _source_file,
    _loaded_at,
    lower(regexp_replace(btrim(replace(normalize(customer_city, NFKC), chr(160), ' ')), '[[:space:]]+', ' ', 'g')),
    CASE
        WHEN customer_zip_code_prefix ~ '^[0-9]{1,5}$' THEN lpad(customer_zip_code_prefix, 5, '0')
    END
FROM raw.customers;


INSERT INTO core.sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state, _source_file, _loaded_at, city_normalized, zip_prefix_normalized)
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state,
    _source_file,
    _loaded_at,
    lower(regexp_replace(btrim(replace(normalize(seller_city, NFKC), chr(160), ' ')), '[[:space:]]+', ' ', 'g')),
    CASE
        WHEN seller_zip_code_prefix ~ '^[0-9]{1,5}$' THEN lpad(seller_zip_code_prefix, 5, '0')
    END
FROM raw.sellers;


INSERT INTO core.products (product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm, _source_file, _loaded_at, category_key)
SELECT
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
    _loaded_at,
    coalesce(nullif(btrim(product_category_name), ''), 'UNKNOWN')
FROM raw.products;


INSERT INTO core.orders
SELECT
    order_id,
    customer_id,
    order_status,
    nullif(btrim(order_purchase_timestamp), '')::timestamp,
    nullif(btrim(order_approved_at), '')::timestamp
FROM raw.orders;


INSERT INTO core.orders_delivery
SELECT
    order_id,
    nullif(btrim(order_delivered_carrier_date), '')::timestamp,
    nullif(btrim(order_delivered_customer_date), '')::timestamp,
    nullif(btrim(order_estimated_delivery_date), '')::timestamp,
    _source_file,
    _loaded_at
FROM raw.orders;


INSERT INTO core.order_items (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value, _source_file, _loaded_at)
SELECT
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
FROM raw.order_items;


INSERT INTO core.order_payments (order_id, payment_sequential, payment_type, payment_installments, payment_value, _source_file, _loaded_at)
SELECT
    order_id,
    nullif(btrim(payment_sequential), '')::integer,
    payment_type,
    nullif(btrim(payment_installments), '')::integer,
    nullif(btrim(payment_value), '')::numeric(18, 2),
    _source_file,
    _loaded_at
FROM raw.order_payments;


INSERT INTO core.order_reviews (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp, _source_file, _loaded_at)
SELECT
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
FROM raw.order_reviews;

ANALYZE core.product_category_translation;

ANALYZE core.customer_context;

ANALYZE core.sellers;

ANALYZE core.products;

ANALYZE core.orders;

ANALYZE core.order_items;

ANALYZE core.order_payments;

ANALYZE core.order_reviews;

ANALYZE core.orders_delivery;
