CREATE DATABASE test_navigator_api ENCODING UTF8;
CREATE DATABASE test_navigator_engine ENCODING UTF8;

CREATE ROLE test_engine WITH PASSWORD '{{ test_navigator_engine_db_pw }}';
GRANT ALL ON DATABASE test_navigator_engine TO test_engine;
CREATE ROLE test_api WITH PASSWORD '{{ test_navigator_api_db_pw }}';
GRANT ALL ON DATABASE test_navigator_api TO test_api;

