#!/bin/bash
set -x
PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$POSTGRES_HOSTNAME" --username="$POSTGRES_USER" -d postgres -f /tmp/db_bootstrap.sql
PGPASSWORD="{{ postgres_password }}"  psql -h "$POSTGRES_HOSTNAME" --username="{{ dhis_db_user }}" -d dhis2 -f /tmp/db_bootstrap_postgis.sql

