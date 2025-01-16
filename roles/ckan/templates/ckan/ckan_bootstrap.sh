#!/bin/sh
CONFIG=/etc/ckan/production.ini

{% if ckan_datapusher_enable == 'true' %}
echo "Making datastore user"
psql "${CKAN_SQLALCHEMY_URL}" -c "CREATE ROLE datastore NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD '{{ ckan_ds_rw_pass }}';"
echo "Making datastore_ro user"
psql "${CKAN_SQLALCHEMY_URL}" -c "CREATE ROLE datastore_ro NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD '{{ ckan_ds_ro_pass }}';"
echo "Making datastore db"
psql "${CKAN_SQLALCHEMY_URL}" -c "CREATE DATABASE datastore OWNER ckan ENCODING 'utf-8';"
echo "Setup datastore permissions"
ckan -c "$CONFIG" datastore set-permissions | psql "${CKAN_SQLALCHEMY_URL}"
{% endif %}

# we're making sure to run our custom entrypoint.
/usr/lib/ckan/ckan-entrypoint.sh

echo "Add admin user:"
ckan -c "$CONFIG" user add admin email="admin@localhost" name="admin" fullname="Admin" password="fjelltopp" apikey="{{ ckan_admin_api_key }}" id="{{ ckan_admin_user_id }}"
echo "Set apikey:"
psql "${CKAN_SQLALCHEMY_URL}"  -c "UPDATE public.user SET apikey = '{{ ckan_admin_api_key }}' WHERE name = 'admin';"
echo "Create API token:"
psql "${CKAN_SQLALCHEMY_URL}"  -c "INSERT INTO api_token VALUES ('{{ ckan_admin_api_token_unencoded }}', 'Default Token', '{{ ckan_admin_user_id }}', now()) ON CONFLICT DO NOTHING;"
echo "make admin superuser"
ckan -c "$CONFIG" sysadmin add admin
echo "Build search index"
ckan -c "$CONFIG" search-index rebuild
echo bootstrap finished
