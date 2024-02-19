CREATE ROLE odk NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD '{{ odk_postgres_password }}';
GRANT odk to {{ rds_admin_username }};
CREATE DATABASE odk OWNER odk ENCODING 'utf-8';
