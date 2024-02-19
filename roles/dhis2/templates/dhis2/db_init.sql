CREATE ROLE {{ dhis_db_user }} NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD '{{ lookup('aws_secret', application_namespace + '_postgres_password' , region = aws_region ) }}';
GRANT {{ dhis_db_user }} to {{ rds_admin_username }};
GRANT rds_superuser to {{ dhis_db_user }};
ALTER SCHEMA public OWNER to {{ dhis_db_user }};
GRANT ALL ON SCHEMA public TO {{ dhis_db_user }};
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO {{ dhis_db_user }};
CREATE DATABASE dhis2 OWNER {{ dhis_db_user }} ENCODING 'utf-8';
ALTER VIEW geography_columns OWNER TO {{ dhis_db_user }};
ALTER VIEW geometry_columns OWNER TO {{ dhis_db_user }};
ALTER TABLE spatial_ref_sys OWNER TO {{ dhis_db_user }};
GRANT ALL on TABLE public.spatial_ref_sys TO {{ rds_admin_username }};
GRANT ALL ON TABLE public.spatial_ref_sys TO {{ dhis_db_user }};
GRANT SELECT ON TABLE public.spatial_ref_sys TO PUBLIC;
REVOKE SELECT ON TABLE public.geometry_columns FROM PUBLIC;
GRANT ALL ON TABLE public.geometry_columns TO {{ dhis_db_user }};
GRANT SELECT ON TABLE public.geometry_columns TO PUBLIC;
REVOKE {{ dhis_db_user }} from {{ rds_admin_username }};

