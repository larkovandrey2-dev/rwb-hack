SELECT
    sales.*,
    rating.seller_rating,
    rating.rated_order_count,
    rating.eligible_single_seller_order_count,
    rating.multi_seller_order_count,
    rating.rated_order_pct
FROM mart.seller_sales AS sales
JOIN mart.seller_rating AS rating USING(seller_id)
ORDER BY
    sales.revenue DESC,
    sales.seller_id
LIMIT %s
OFFSET %s;
