CREATE OR REPLACE VIEW mart.seller_rating AS
WITH order_sellers AS MATERIALIZED
    (SELECT
         order_id,
         count(DISTINCT seller_id) AS seller_count,
         min(seller_id) AS single_seller_id
     FROM core.order_items
     GROUP BY order_id), order_ratings AS MATERIALIZED
    (SELECT
         order_id,
         avg(review_score) AS order_rating
     FROM core.order_reviews
     GROUP BY order_id), eligible AS MATERIALIZED
    (SELECT
         o.single_seller_id AS seller_id,
         avg(r.order_rating) AS seller_rating,
         count(r.order_rating) AS rated_order_count,
         count(*) AS eligible_single_seller_order_count
     FROM order_sellers o
     LEFT JOIN order_ratings r USING(order_id)
     WHERE o.seller_count = 1
     GROUP BY o.single_seller_id), multi AS MATERIALIZED
    (SELECT
         i.seller_id,
         count(DISTINCT i.order_id) AS multi_seller_order_count
     FROM core.order_items i
     JOIN order_sellers o USING(order_id)
     WHERE o.seller_count > 1
     GROUP BY i.seller_id)
SELECT
    s.seller_id,
    e.seller_rating,
    coalesce(e.rated_order_count, 0) AS rated_order_count,
    coalesce(e.eligible_single_seller_order_count, 0) AS eligible_single_seller_order_count,
    coalesce(m.multi_seller_order_count, 0) AS multi_seller_order_count,
    100.0 * e.rated_order_count / nullif(e.eligible_single_seller_order_count, 0) AS rated_order_pct
FROM core.sellers s
LEFT JOIN eligible e USING(seller_id)
LEFT JOIN multi m USING(seller_id);
