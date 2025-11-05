
-- Генерация тестовых данных 

INSERT INTO ref.countries(name, iso_code)
VALUES ('Germany','DE'),('France','FR'),('Poland','PL'),('Spain','ES'),('Italy','IT')
ON CONFLICT DO NOTHING;

INSERT INTO ref.cities(country_id, name)
SELECT c.country_id, 'City_'||c.iso_code||'_'||gs::text
FROM ref.countries c
CROSS JOIN generate_series(1,20) gs;

INSERT INTO ref.categories(name) SELECT 'Cat_'||gs FROM generate_series(1,10) gs;
INSERT INTO ref.categories(parent_id,name)
SELECT p.category_id, p.name||'_Sub_'||gs
FROM ref.categories p
JOIN LATERAL generate_series(1,5) gs ON TRUE
WHERE p.parent_id IS NULL;

-- Склады (5 шт.)
INSERT INTO shop.warehouses(city_id, name)
SELECT city_id, 'WH_'||city_id::text
FROM ref.cities ORDER BY city_id LIMIT 5;

-- Товары (1000)
INSERT INTO shop.products(sku,name,category_id,price,active)
SELECT 'SKU'||gs, 'Product_'||gs, (
    SELECT category_id FROM ref.categories
    WHERE parent_id IS NOT NULL
    ORDER BY random() LIMIT 1
), (round((random()*200+1)::numeric,2)), true
FROM generate_series(1,1000) gs;

-- Клиенты (5000)
INSERT INTO shop.customers(city_id,email,phone,full_name)
SELECT (SELECT city_id FROM ref.cities ORDER BY random() LIMIT 1),
       'user'||gs||'@mail.local',
       '+49-170-'||LPAD((100000+gs)::text,6,'0'),
       'Customer '||gs
FROM generate_series(1,5000) gs;

INSERT INTO shop.customer_profile(customer_id,birthdate,gender,marketing_opt_in)
SELECT customer_id,
       date '1970-01-01' + (random()*18000)::int,
       CASE WHEN random()>0.5 THEN 'M' ELSE 'F' END,
       random()>0.7
FROM shop.customers WHERE customer_id % 2 = 0;


INSERT INTO shop.stock(product_id, warehouse_id, qty_on_hand)
SELECT p.product_id, w.warehouse_id, 1000
FROM shop.products p CROSS JOIN shop.warehouses w;


INSERT INTO shop.promotions(name, discount_pct, date_from, date_to)
SELECT 'Promo_'||gs, (round((random()*30)::numeric,2)), CURRENT_DATE - (gs*10), CURRENT_DATE + (gs*10)
FROM generate_series(1,10) gs;

INSERT INTO shop.product_promotion(product_id, promotion_id)
SELECT p.product_id, pr.promotion_id
FROM shop.products p
JOIN LATERAL (SELECT promotion_id FROM shop.promotions ORDER BY random() LIMIT 1) pr ON TRUE
WHERE p.product_id % 3 = 0;

INSERT INTO shop.employees(full_name) VALUES ('CEO');
INSERT INTO shop.employees(full_name, manager_id)
SELECT 'Manager_'||gs, 1 FROM generate_series(1,10) gs;
INSERT INTO shop.employees(full_name, manager_id)
SELECT 'Staff_'||gs, (SELECT employee_id FROM shop.employees WHERE manager_id = 1 ORDER BY random() LIMIT 1)
FROM generate_series(1,50) gs;

-- Заказы (10 000)
INSERT INTO shop.orders(customer_id, order_date, status, comment)
SELECT c.customer_id,
       CURRENT_DATE - ((random()*365)::int),
       (ARRAY['NEW','PAID','SHIPPED','CANCELLED'])[(floor(random()*4)+1)::int],
       NULL
FROM shop.customers c
WHERE c.customer_id <= 10000
ORDER BY random()
LIMIT 10000;


INSERT INTO shop.order_items(order_id, product_id, warehouse_id, quantity, unit_price, line_total)
SELECT o.order_id,
       p.product_id,
       (SELECT warehouse_id FROM shop.warehouses ORDER BY random() LIMIT 1),
       qty,
       p.price,
       p.price * qty
FROM shop.orders o
JOIN LATERAL (
    SELECT product_id FROM shop.products ORDER BY random() LIMIT (1 + (random()*4)::int)
) pids ON TRUE
JOIN shop.products p ON p.product_id = pids.product_id
JOIN LATERAL (SELECT 1 + (random()*4)::int AS qty) q ON TRUE;
