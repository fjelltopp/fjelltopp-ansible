CREATE EXTENSION postgis;
CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION postgis_tiger_geocoder;
CREATE EXTENSION postgis_topology;
ALTER VIEW geography_columns OWNER TO {{ dhis_db_user }};
ALTER VIEW geometry_columns OWNER TO {{ dhis_db_user }};
ALTER TABLE spatial_ref_sys OWNER TO {{ dhis_db_user }};
GRANT ALL on TABLE public.spatial_ref_sys TO {{ rds_admin_username }};
GRANT ALL ON TABLE public.spatial_ref_sys TO {{ dhis_db_user }};
GRANT SELECT ON TABLE public.spatial_ref_sys TO PUBLIC;
REVOKE SELECT ON TABLE public.geometry_columns FROM PUBLIC;
GRANT ALL ON TABLE public.geometry_columns TO {{ dhis_db_user }};
GRANT SELECT ON TABLE public.geometry_columns TO PUBLIC;


