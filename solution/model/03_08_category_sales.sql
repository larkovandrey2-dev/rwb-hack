CREATE OR REPLACE VIEW mart.category_sales AS
WITH sales AS
    (SELECT
         category_name,
         max(category_english) AS category_english,
         sum(price) AS revenue
     FROM mart.item_sales
     WHERE order_status = 'delivered'
     GROUP BY category_name)
SELECT
    *,
    100.0 * revenue / nullif(sum(revenue) OVER(), 0) AS revenue_pct
FROM sales;
