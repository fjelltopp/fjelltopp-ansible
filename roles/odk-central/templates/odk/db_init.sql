CREATE ROLE {{ odk_db_user }} NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD '{{ odk_postgres_password }}';
GRANT {{ odk_db_user }} to {{ rds_admin_username }};
CREATE DATABASE {{ odk_db_user }} OWNER {{ odk_db_user }} ENCODING 'utf-8';
