#!/bin/bash
# Provide CKAN postgres password as a parameter to this script

if [ $# -eq 0 ]; then
    echo "Provide CKAN postgres password as a parameter to this script, usually it's the same as group_vars/all ckan_postgres_password"
    echo "Make sure that you're running this script with your test CKAN venv activated"
    exit 1
fi

export PGPASSWORD="$1"

dropdb -h "$(minikube ip)" -U ckan ckan_test
dropdb -h "$(minikube ip)" -U ckan datastore_test
echo "test dbs dropped"

createdb -h "$(minikube ip)" -U ckan -O ckan ckan_test -E utf-8
echo "ckan_test db created"

createdb -h "$(minikube ip)" -U ckan -O ckan datastore_test -E utf-8
echo "datastore_test db created"

ckan -c ckan/test-core.ini datastore set-permissions | psql -h "$(minikube ip)" -U ckan
echo "datastore_test permissions set up"

