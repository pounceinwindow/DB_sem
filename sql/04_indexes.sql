

-- Индексы по foreign key  размещаем в index-TableSpace

-- ref
CREATE INDEX ref_cities_country_idx ON ref.cities(country_id) TABLESPACE shopdb_ts_index;
CREATE INDEX ref_categories_parent_idx ON ref.categories(parent_id) TABLESPACE shopdb_ts_index;

-- shop
CREATE INDEX shop_warehouses_city_idx ON shop.warehouses(city_id) TABLESPACE shopdb_ts_index;
CREATE INDEX shop_customers_city_idx  ON shop.customers(city_id)  TABLESPACE shopdb_ts_index;
CREATE INDEX shop_products_category_idx ON shop.products(category_id) TABLESPACE shopdb_ts_index;
CREATE INDEX shop_products_name_idx     ON shop.products(name)      TABLESPACE shopdb_ts_index;

CREATE UNIQUE INDEX products_sku_uidx     ON shop.products(sku)    TABLESPACE shopdb_ts_index;
CREATE UNIQUE INDEX customers_email_uidx  ON shop.customers(email) TABLESPACE shopdb_ts_index;

CREATE INDEX shop_orders_customer_idx     ON shop.orders(customer_id) TABLESPACE shopdb_ts_index;
CREATE INDEX shop_orders_date_idx         ON shop.orders(order_date)  TABLESPACE shopdb_ts_index;

CREATE INDEX orders_status_new_idx ON shop.orders(status) TABLESPACE shopdb_ts_index WHERE status = 'NEW';

CREATE INDEX shop_order_items_order_idx     ON shop.order_items(order_id)    TABLESPACE shopdb_ts_index;
CREATE INDEX shop_order_items_product_idx   ON shop.order_items(product_id)  TABLESPACE shopdb_ts_index;
CREATE INDEX shop_order_items_warehouse_idx ON shop.order_items(warehouse_id) TABLESPACE shopdb_ts_index;

CREATE INDEX shop_stock_warehouse_idx ON shop.stock(warehouse_id) TABLESPACE shopdb_ts_index;

CREATE INDEX shop_product_promotion_promo_idx ON shop.product_promotion(promotion_id) TABLESPACE shopdb_ts_index;

CREATE INDEX audit_log_tbl_time_idx ON shop.audit_log(table_name, event_time) TABLESPACE shopdb_ts_index;
