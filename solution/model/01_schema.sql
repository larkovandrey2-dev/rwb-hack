CREATE SCHEMA IF NOT EXISTS core;


CREATE SCHEMA IF NOT EXISTS mart;


CREATE TABLE IF NOT EXISTS core.customer(customer_unique_id text PRIMARY KEY);


CREATE TABLE IF NOT EXISTS core.category(category_name text
                                             PRIMARY KEY,
                                             category_english text, is_unknown boolean
                                             NOT NULL,
                                             translation_missing boolean NOT NULL);


CREATE TABLE IF NOT EXISTS core.calendar_month(MONTH date PRIMARY KEY);


CREATE TABLE IF NOT EXISTS core.product_category_translation (product_category_name text, product_category_name_english text, _source_file text,
                                                                  _loaded_at timestamptz,
                                                                  PRIMARY KEY(product_category_name));


CREATE TABLE IF NOT EXISTS core.customer_context (customer_id text
                                                      NOT NULL,
                                                      customer_unique_id text
                                                      NOT NULL,
                                                      customer_zip_code_prefix text, customer_city text, customer_state text, _source_file text,
                                                      _loaded_at timestamptz,
                                                      PRIMARY KEY(customer_id), city_normalized text, zip_prefix_normalized text,
                                                  FOREIGN KEY(customer_unique_id) REFERENCES core.customer);


CREATE TABLE IF NOT EXISTS core.sellers (seller_id text
                                             NOT NULL,
                                             seller_zip_code_prefix text, seller_city text, seller_state text, _source_file text,
                                             _loaded_at timestamptz,
                                             PRIMARY KEY(seller_id), city_normalized text, zip_prefix_normalized text);


CREATE TABLE IF NOT EXISTS core.products (product_id text
                                              NOT NULL,
                                              product_category_name text, product_name_lenght integer, product_description_lenght integer, product_photos_qty integer, product_weight_g integer, product_length_cm integer, product_height_cm integer, product_width_cm integer, _source_file text,
                                              _loaded_at timestamptz,
                                              PRIMARY KEY(product_id), category_key text
                                              NOT NULL,
                                              weight_is_zero boolean GENERATED
                                              ALWAYS AS (product_weight_g = 0) STORED,
                                          FOREIGN KEY(category_key) REFERENCES core.category(category_name));


CREATE TABLE IF NOT EXISTS core.orders (order_id text
                                            PRIMARY KEY,
                                            customer_id text NOT NULL REFERENCES
                                            core.customer_context,
                                            order_status text
                                            NOT NULL,
                                            order_purchase_timestamp timestamp
                                            NOT NULL,
                                            order_approved_at timestamp);


CREATE TABLE IF NOT EXISTS core.orders_delivery (order_id text PRIMARY KEY REFERENCES
                                                     core.orders,
                                                     order_delivered_carrier_date timestamp, order_delivered_customer_date timestamp, order_estimated_delivery_date timestamp, _source_file text, _loaded_at timestamptz);


CREATE TABLE IF NOT EXISTS core.order_items (order_id text
                                                 NOT NULL,
                                                 order_item_id integer, product_id text
                                                 NOT NULL,
                                                 seller_id text
                                                 NOT NULL,
                                                 shipping_limit_date timestamp WITHOUT TIME
                                                 ZONE,
                                                 price numeric(18, 2)
                                                 NOT NULL,
                                                 freight_value numeric(18, 2)
                                                 NOT NULL,
                                                 _source_file text,
                                                 _loaded_at timestamptz,
                                                 PRIMARY KEY(
                                                                 order_id,
                                                                 order_item_id), CHECK (price >= 0
                                                                                        AND price NOT IN (
                                                                                                              'NaN'::numeric,
                                                                                                              'Infinity'::numeric,
                                                                                                              '-Infinity'::numeric)), CHECK (freight_value >= 0
                                                                                                                                             AND freight_value NOT IN (
                                                                                                                                                                           'NaN'::numeric,
                                                                                                                                                                           'Infinity'::numeric,
                                                                                                                                                                           '-Infinity'::numeric)),
                                                 CHECK(order_item_id > 0),
                                             FOREIGN KEY(order_id) REFERENCES
                                                 core.orders,
                                             FOREIGN KEY(product_id) REFERENCES
                                                 core.products,
                                             FOREIGN KEY(seller_id) REFERENCES core.sellers);


CREATE TABLE IF NOT EXISTS core.order_payments (order_id text
                                                    NOT NULL,
                                                    payment_sequential integer, payment_type text, payment_installments integer
                                                    NOT NULL,
                                                    payment_value numeric(18, 2)
                                                    NOT NULL,
                                                    _source_file text,
                                                    _loaded_at timestamptz,
                                                    PRIMARY KEY(
                                                                    order_id,
                                                                    payment_sequential), CHECK (payment_value >= 0
                                                                                                AND payment_value NOT IN (
                                                                                                                              'NaN'::numeric,
                                                                                                                              'Infinity'::numeric,
                                                                                                                              '-Infinity'::numeric)),
                                                    CHECK(payment_sequential > 0),
                                                    CHECK(payment_installments >= 0),
                                                FOREIGN KEY(order_id) REFERENCES core.orders);


CREATE TABLE IF NOT EXISTS core.order_reviews (review_id text, order_id text
                                                   NOT NULL,
                                                   review_score integer
                                                   NOT NULL,
                                                   review_comment_title text, review_comment_message text, review_creation_date timestamp WITHOUT TIME
                                                   ZONE,
                                                   review_answer_timestamp timestamp WITHOUT TIME
                                                   ZONE,
                                                   _source_file text,
                                                   _loaded_at timestamptz,
                                                   PRIMARY KEY(
                                                                   order_id,
                                                                   review_id),
                                                   CHECK(review_score BETWEEN 1 AND 5),
                                               FOREIGN KEY(order_id) REFERENCES core.orders);
