

CREATE TABLE ref.countries (
    country_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name       TEXT NOT NULL UNIQUE,
    iso_code   CHAR(2) NOT NULL UNIQUE
) TABLESPACE shopdb_ts_data;
COMMENT ON TABLE ref.countries IS 'Страны';
COMMENT ON COLUMN ref.countries.country_id IS 'PK';
COMMENT ON COLUMN ref.countries.name IS 'Название страны';
COMMENT ON COLUMN ref.countries.iso_code IS 'ISO 3166-1 alpha-2';

CREATE TABLE ref.cities (
    city_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_id BIGINT NOT NULL REFERENCES ref.countries(country_id),
    name       TEXT NOT NULL
) TABLESPACE shopdb_ts_data;
COMMENT ON TABLE ref.cities IS 'Города';
COMMENT ON COLUMN ref.cities.city_id IS 'PK';
COMMENT ON COLUMN ref.cities.country_id IS 'FK -> countries';
COMMENT ON COLUMN ref.cities.name IS 'Название города';


CREATE TABLE ref.categories (
    category_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    parent_id   BIGINT REFERENCES ref.categories(category_id),
    name        TEXT NOT NULL UNIQUE
) TABLESPACE shopdb_ts_data;
COMMENT ON TABLE ref.categories IS 'Категории товаров (иерархия)';
COMMENT ON COLUMN ref.categories.category_id IS 'PK';
COMMENT ON COLUMN ref.categories.parent_id IS 'Родительская категория (рекурсия)';
COMMENT ON COLUMN ref.categories.name IS 'Название категории';


CREATE TABLE shop.warehouses (
    warehouse_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_id      BIGINT NOT NULL REFERENCES ref.cities(city_id),
    name         TEXT NOT NULL UNIQUE
) TABLESPACE shopdb_ts_data;
COMMENT ON TABLE shop.warehouses IS 'Склады';
COMMENT ON COLUMN shop.warehouses.warehouse_id IS 'PK';
COMMENT ON COLUMN shop.warehouses.city_id IS 'FK -> ref.cities';
COMMENT ON COLUMN shop.warehouses.name IS 'Название склада';


CREATE TABLE shop.customers (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_id     BIGINT REFERENCES ref.cities(city_id),
    email       TEXT NOT NULL UNIQUE,
    phone       TEXT,
    full_name   TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
) TABLESPACE shopdb_ts_data;
COMMENT ON TABLE shop.customers IS 'Покупатели';
COMMENT ON COLUMN shop.customers.customer_id IS 'PK';
COMMENT ON COLUMN shop.customers.city_id IS 'FK -> ref.cities';
COMMENT ON COLUMN shop.customers.email IS 'Уникальный email';
COMMENT ON COLUMN shop.customers.phone IS 'Телефон';
COMMENT ON COLUMN shop.customers.full_name IS 'ФИО';
COMMENT ON COLUMN shop.customers.created_at IS 'Дата регистрации';


CREATE TABLE shop.customer_profile (
    customer_id BIGINT PRIMARY KEY REFERENCES shop.customers(customer_id) ON DELETE CASCADE,
    birthdate   DATE,
    gender      CHAR(1) CHECK (gender IN ('M','F')),
    marketing_opt_in BOOLEAN NOT NULL DEFAULT false
) TABLESPACE shopdb_ts_data;
COMMENT ON TABLE shop.customer_profile IS 'Профиль покупателя (1:1)';
COMMENT ON COLUMN shop.customer_profile.customer_id IS 'PK & FK -> customers';
COMMENT ON COLUMN shop.customer_profile.birthdate IS 'Дата рождения';
COMMENT ON COLUMN shop.customer_profile.gender IS 'Пол: M/F';
COMMENT ON COLUMN shop.customer_profile.marketing_opt_in IS 'Согласие на рассылку';


CREATE TABLE shop.products (
    product_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku        TEXT NOT NULL UNIQUE,
    name       TEXT NOT NULL,
    category_id BIGINT REFERENCES ref.categories(category_id),
    price      NUMERIC(12,2) NOT NULL CHECK (price >= 0),
    active     BOOLEAN NOT NULL DEFAULT true
) TABLESPACE shopdb_ts_data;
COMMENT ON TABLE shop.products IS 'Товары';
COMMENT ON COLUMN shop.products.product_id IS 'PK';
COMMENT ON COLUMN shop.products.sku IS 'Артикул (UNIQUE)';
COMMENT ON COLUMN shop.products.name IS 'Название товара';
COMMENT ON COLUMN shop.products.category_id IS 'FK -> ref.categories';
COMMENT ON COLUMN shop.products.price IS 'Цена';
COMMENT ON COLUMN shop.products.active IS 'Активен к продаже';


CREATE TABLE shop.promotions (
    promotion_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name         TEXT NOT NULL,
    discount_pct NUMERIC(5,2) NOT NULL CHECK (discount_pct BETWEEN 0 AND 100),
    date_from    DATE NOT NULL,
    date_to      DATE NOT NULL,
    CHECK (date_to >= date_from)
) TABLESPACE shopdb_ts_data;
COMMENT ON TABLE shop.promotions IS 'Акции и скидки';
COMMENT ON COLUMN shop.promotions.promotion_id IS 'PK';
COMMENT ON COLUMN shop.promotions.name IS 'Название акции';
COMMENT ON COLUMN shop.promotions.discount_pct IS 'Скидка, %';
COMMENT ON COLUMN shop.promotions.date_from IS 'Начало акции';
COMMENT ON COLUMN shop.promotions.date_to IS 'Окончание акции';


CREATE TABLE shop.product_promotion (
    product_id   BIGINT NOT NULL REFERENCES shop.products(product_id) ON DELETE CASCADE,
    promotion_id BIGINT NOT NULL REFERENCES shop.promotions(promotion_id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, promotion_id)
) TABLESPACE shopdb_ts_data;
COMMENT ON TABLE shop.product_promotion IS 'Связь товаров и акций (N:M)';
COMMENT ON COLUMN shop.product_promotion.product_id IS 'FK -> products';
COMMENT ON COLUMN shop.product_promotion.promotion_id IS 'FK -> promotions';


CREATE TABLE shop.orders (
    order_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES shop.customers(customer_id),
    order_date  DATE NOT NULL DEFAULT CURRENT_DATE,
    status      TEXT NOT NULL DEFAULT 'NEW' CHECK (status IN ('NEW','PAID','SHIPPED','CANCELLED')),
    comment     TEXT,
    total_amount NUMERIC(14,2) NOT NULL DEFAULT 0
) TABLESPACE shopdb_ts_data;
COMMENT ON TABLE shop.orders IS 'Заказы (шапка)';
COMMENT ON COLUMN shop.orders.order_id IS 'PK';
COMMENT ON COLUMN shop.orders.customer_id IS 'FK -> customers';
COMMENT ON COLUMN shop.orders.order_date IS 'Дата заказа';
COMMENT ON COLUMN shop.orders.status IS 'Статус заказа';
COMMENT ON COLUMN shop.orders.comment IS 'Примечание';
COMMENT ON COLUMN shop.orders.total_amount IS 'Сумма по строкам';


CREATE TABLE shop.order_items (
    order_item_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id      BIGINT NOT NULL REFERENCES shop.orders(order_id) ON DELETE CASCADE,
    product_id    BIGINT NOT NULL REFERENCES shop.products(product_id),
    warehouse_id  BIGINT NOT NULL REFERENCES shop.warehouses(warehouse_id),
    quantity      INTEGER NOT NULL CHECK (quantity > 0),
    unit_price    NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    line_total    NUMERIC(14,2) NOT NULL
) TABLESPACE shopdb_ts_data;
COMMENT ON TABLE shop.order_items IS 'Строки заказа (факт)';
COMMENT ON COLUMN shop.order_items.order_item_id IS 'PK';
COMMENT ON COLUMN shop.order_items.order_id IS 'FK -> orders';
COMMENT ON COLUMN shop.order_items.product_id IS 'FK -> products';
COMMENT ON COLUMN shop.order_items.warehouse_id IS 'Склад отгрузки';
COMMENT ON COLUMN shop.order_items.quantity IS 'Количество';
COMMENT ON COLUMN shop.order_items.unit_price IS 'Цена за единицу';
COMMENT ON COLUMN shop.order_items.line_total IS 'Сумма строки (price*qty)';


CREATE TABLE shop.stock (
    product_id   BIGINT NOT NULL REFERENCES shop.products(product_id),
    warehouse_id BIGINT NOT NULL REFERENCES shop.warehouses(warehouse_id),
    qty_on_hand  INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (product_id, warehouse_id)
) TABLESPACE shopdb_ts_data;
COMMENT ON TABLE shop.stock IS 'Остатки на складе';
COMMENT ON COLUMN shop.stock.product_id IS 'FK -> products';
COMMENT ON COLUMN shop.stock.warehouse_id IS 'FK -> warehouses';
COMMENT ON COLUMN shop.stock.qty_on_hand IS 'Доступное количество';


CREATE TABLE shop.employees (
    employee_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name   TEXT NOT NULL,
    manager_id  BIGINT REFERENCES shop.employees(employee_id),
    hire_date   DATE  NOT NULL DEFAULT CURRENT_DATE
) TABLESPACE shopdb_ts_data;
COMMENT ON TABLE shop.employees IS 'Сотрудники (иерархия начальник-подчиненный)';
COMMENT ON COLUMN shop.employees.employee_id IS 'PK';
COMMENT ON COLUMN shop.employees.full_name IS 'ФИО';
COMMENT ON COLUMN shop.employees.manager_id IS 'FK -> employees (менеджер)';
COMMENT ON COLUMN shop.employees.hire_date IS 'Дата найма';


CREATE TABLE shop.audit_log (
    audit_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_time TIMESTAMPTZ NOT NULL DEFAULT now(),
    username   TEXT        NOT NULL,
    action     TEXT        NOT NULL,      --под операции типо insert/update/delete
    table_name TEXT        NOT NULL,
    row_id     BIGINT,
    details    TEXT
) TABLESPACE shopdb_ts_data;
COMMENT ON TABLE shop.audit_log IS 'Журнал аудита DML';
COMMENT ON COLUMN shop.audit_log.audit_id IS 'PK';
COMMENT ON COLUMN shop.audit_log.event_time IS 'Время события';
COMMENT ON COLUMN shop.audit_log.username IS 'Пользователь';
COMMENT ON COLUMN shop.audit_log.action IS 'Тип операции';
COMMENT ON COLUMN shop.audit_log.table_name IS 'Таблица';
COMMENT ON COLUMN shop.audit_log.row_id IS 'PK строки';
COMMENT ON COLUMN shop.audit_log.details IS 'Детали изменения';
