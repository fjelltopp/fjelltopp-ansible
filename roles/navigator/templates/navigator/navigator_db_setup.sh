#!/bin/bash
set -x
export PGPASSWORD="$POSTGRES_PASSWORD"

export COUNTER=0

while ! pg_isready -h "$POSTGRES_HOSTNAME" -d postgres -t 10 && (( COUNTER < 20 ))
do
	echo "Waiting for the database to be ready..."
	sleep 5
  (( COUNTER=COUNTER+1 ))
done

psql -h "$POSTGRES_HOSTNAME" --username="$POSTGRES_USER" -d postgres -f /tmp/navigator_db_setup.sql

{% if fjelltopp_env_type == 'local' %}
psql -h "$POSTGRES_HOSTNAME" --username="$POSTGRES_USER" -d postgres -f /tmp/navigator_testdb_setup.sql
{% endif %}
