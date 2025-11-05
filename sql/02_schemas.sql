


CREATE SCHEMA IF NOT EXISTS ref AUTHORIZATION user_owner;
COMMENT ON SCHEMA ref IS 'Справочники';

CREATE SCHEMA IF NOT EXISTS shop AUTHORIZATION user_owner;
COMMENT ON SCHEMA shop IS 'Операционные данные магазина';

CREATE SCHEMA IF NOT EXISTS analytics AUTHORIZATION user_owner;
COMMENT ON SCHEMA analytics IS 'Аналитические представления и MVs';
