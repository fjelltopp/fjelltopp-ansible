#!/bin/bash
set -x
PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$POSTGRES_HOSTNAME" --username="$POSTGRES_USER" -d postgres -f /tmp/db_bootstrap.sql

