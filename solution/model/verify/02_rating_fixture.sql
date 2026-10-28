BEGIN;


INSERT INTO core.sellers(seller_id)
VALUES ('__rating_a'),
       ('__rating_b'),
       ('__rating_none');


INSERT INTO core.orders(order_id, customer_id, order_status, order_purchase_timestamp)
SELECT
    '__rating_' || n,
    customer_id,
    'canceled',timestamp '2017-01-01'
FROM generate_series(1, 4) n
CROSS JOIN
    (SELECT customer_id
     FROM core.customer_context
     LIMIT 1) c;


INSERT INTO core.orders_delivery(order_id)
SELECT '__rating_' || n
FROM generate_series(1, 4) n;


INSERT INTO core.order_items(order_id, order_item_id, product_id, seller_id, price, freight_value)
SELECT
    '__rating_' || o,
    seq,
    product_id,
    seller,
    1,
    0
FROM (
      VALUES (
                  1,
                  1,
                  '__rating_a'),(
                                     1,
                                     2,
                                     '__rating_a'),(
                                                        2,
                                                        1,
                                                        '__rating_a'), (
                                                                            3,
                                                                            1,
                                                                            '__rating_a'),(
                                                                                               3,
                                                                                               2,
                                                                                               '__rating_b'),(
                                                                                                                  4,
                                                                                                                  1,
                                                                                                                  '__rating_a')) v(o, seq, seller)
CROSS JOIN
    (SELECT product_id
     FROM core.products
     LIMIT 1) p;


INSERT INTO core.order_reviews(order_id, review_id, review_score)
VALUES ('__rating_1','__review_1',1),
       ('__rating_1','__review_2',5),
       ('__rating_2','__review_3',5),
       ('__rating_3','__review_4',1);

DO $$ BEGIN
 IF NOT EXISTS(SELECT FROM mart.seller_rating WHERE seller_id='__rating_a'
 AND seller_rating=4 AND rated_order_count=2 AND eligible_single_seller_order_count=3
 AND multi_seller_order_count=1 AND round(rated_order_pct,2)=66.67) THEN RAISE EXCEPTION 'Order weighting or item fanout incorrect'; END IF;
 IF NOT EXISTS(SELECT FROM mart.seller_rating WHERE seller_id='__rating_b' AND seller_rating IS NULL AND rated_order_count=0 AND eligible_single_seller_order_count=0 AND multi_seller_order_count=1 AND rated_order_pct IS NULL) THEN RAISE EXCEPTION 'Multi-seller exclusion incorrect'; END IF;
 IF NOT EXISTS(SELECT FROM mart.seller_rating WHERE seller_id='__rating_none' AND seller_rating IS NULL AND rated_order_count=0 AND multi_seller_order_count=0) THEN RAISE EXCEPTION 'No-order seller incorrect'; END IF;
END $$;


SELECT 'rating fixture passed: per-order weighting, repeated items, multi-seller exclusion, all statuses, NULL ratings' AS RESULT;


ROLLBACK;
