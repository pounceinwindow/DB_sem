# ShopDB — интернет-магазин электрони
 
**Имя БД:** `shopdb` (владелец `user owner`)

## Что реализовано
- 3 схемы: `ref`, `shop`, `analytics` ё
- 2 tablespace: `shopdb_ts_data` (данные) и `shopdb_ts_index` (индексы).
- 14 таблиц. Связи:
  - 1:1 — `shop.customers` <=> `shop.customer_profile`
  - 1:N — `shop.customers` => `shop.orders` => `shop.order_items`
  - N:M — `shop.products` <=> `shop.promotions` через `shop.product_promotion`
  - Рекурсии — `ref.categories` и `shop.employees`
- Индексы по PK/UK/FK, все в TS индексов.
- Комментарии `COMMENT ON` на все таблицы и все поля.
- Данные: > 1000 строк в `shop.order_items`.

## Модели данных 
- `concept_model.png` — концептуальная диаграмма (сущности/связи).
- `logic_model.png` — логическая диаграмма (таблицы + ключевые поля).


