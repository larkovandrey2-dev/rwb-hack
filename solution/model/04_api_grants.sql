DO $$ BEGIN
 IF EXISTS(SELECT FROM pg_roles WHERE rolname='capibara_dashboard') THEN
  GRANT USAGE ON SCHEMA mart TO capibara_dashboard;
  GRANT SELECT ON mart.overview,mart.monthly_sales,mart.seller_sales,mart.seller_rating,mart.category_sales,mart.customer_repeat TO capibara_dashboard;
 END IF;
END $$;
