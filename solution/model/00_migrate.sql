DROP VIEW IF EXISTS mart.overview;


DROP VIEW IF EXISTS mart.seller_sales;


DROP VIEW IF EXISTS mart.category_sales;


DROP VIEW IF EXISTS mart.customer_repeat;


DROP VIEW IF EXISTS mart.average_order;


DROP VIEW IF EXISTS mart.seller_rating;


DROP VIEW IF EXISTS mart.item_sales;


DROP VIEW IF EXISTS mart.monthly_sales;


DROP VIEW IF EXISTS mart.order_finance;

DO $$ BEGIN
 IF EXISTS(SELECT FROM information_schema.columns WHERE table_schema='core' AND table_name='orders' AND column_name='order_delivered_carrier_date') THEN
  CREATE TABLE IF NOT EXISTS core.orders_delivery (
   order_id text PRIMARY KEY REFERENCES core.orders,
   order_delivered_carrier_date timestamp,order_delivered_customer_date timestamp,
   order_estimated_delivery_date timestamp,_source_file text,_loaded_at timestamptz
  );
  INSERT INTO core.orders_delivery
  SELECT order_id,order_delivered_carrier_date,order_delivered_customer_date,
         order_estimated_delivery_date,_source_file,_loaded_at FROM core.orders
  ON CONFLICT(order_id) DO NOTHING;
  ALTER TABLE core.orders
   DROP COLUMN delivered_date_missing,
   DROP COLUMN carrier_before_purchase,
   DROP COLUMN delivered_before_carrier,
   DROP COLUMN order_delivered_carrier_date,
   DROP COLUMN order_delivered_customer_date,
   DROP COLUMN order_estimated_delivery_date,
   DROP COLUMN _source_file,
   DROP COLUMN _loaded_at;
 END IF;
END $$;
