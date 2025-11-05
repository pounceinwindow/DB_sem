

-- выполнять суперпользователем
CREATE TABLESPACE shopdb_ts_data  LOCATION 'C:\pg_tblsp\shopdb_data';
COMMENT ON TABLESPACE shopdb_ts_data IS 'Данные ShopDB';
CREATE TABLESPACE shopdb_ts_index LOCATION 'C:\pg_tblsp\shopdb_index';
COMMENT ON TABLESPACE shopdb_ts_index IS 'Индексы ShopDB';


GRANT CREATE ON TABLESPACE shopdb_ts_data  TO user_owner;
GRANT CREATE ON TABLESPACE shopdb_ts_index TO user_owner;
