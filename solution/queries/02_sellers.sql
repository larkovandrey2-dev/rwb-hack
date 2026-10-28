SELECT *
FROM mart.seller_sales
ORDER BY
    revenue DESC,
    seller_id
LIMIT 10;
