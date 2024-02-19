#!/bin/bash
set -x
export PGPASSWORD="$POSTGRES_PASSWORD"
psql -h "$POSTGRES_HOSTNAME" --username="$POSTGRES_USER" -d postgres -f /tmp/ckan_db_bootstrap.sql
