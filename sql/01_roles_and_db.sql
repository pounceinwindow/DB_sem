

-- саоздание ролей и пользователей (выполнять суперпользователем или владельцем ролей)
CREATE ROLE role_app_rw NOINHERIT;
CREATE ROLE role_sales_ro NOINHERIT;
CREATE ROLE role_analytics_ro NOINHERIT;
CREATE ROLE role_audit_ro NOINHERIT;

COMMENT ON ROLE role_app_rw IS 'RW доступ к операционным схемам';
COMMENT ON ROLE role_sales_ro IS 'RO доступ к данным продаж';
COMMENT ON ROLE role_analytics_ro IS 'RO доступ к аналитике';
COMMENT ON ROLE role_audit_ro IS 'RO доступ к журналу аудита';

CREATE ROLE user_app     LOGIN PASSWORD 'App_Passw0rd' INHERIT;
CREATE ROLE user_analyst LOGIN PASSWORD 'Analyst_Passw0rd' INHERIT;
CREATE ROLE user_auditor LOGIN PASSWORD 'Auditor_Passw0rd' INHERIT;

GRANT role_app_rw     TO user_app;
GRANT role_sales_ro   TO user_app;
GRANT role_analytics_ro TO user_analyst;
GRANT role_audit_ro   TO user_auditor;

-- База данных
CREATE DATABASE shopdb OWNER user_owner TABLESPACE shopdb_ts_data;
COMMENT ON DATABASE shopdb IS 'Интернет-магазин электроники (семестровая)';
