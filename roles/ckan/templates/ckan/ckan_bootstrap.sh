#!/bin/sh
CONFIG=/etc/ckan/production.ini
# we're making sure to run our custom entrypoint.
/usr/lib/ckan/ckan-entrypoint.sh
echo "DB init:"
ckan -c "$CONFIG" db init
echo "Add admin user:"
ckan -c "$CONFIG" user add admin email="admin@localhost" name="admin" fullname="Admin" password="fjelltopp" apikey="{{ ckan_admin_api_key }}" id="{{ ckan_admin_user_id }}"
echo "Set apikey:"
psql "${CKAN_SQLALCHEMY_URL}"  -c "UPDATE public.user SET apikey = '{{ ckan_admin_api_key }}' WHERE name = 'admin';"
echo "Create API token:"
psql "${CKAN_SQLALCHEMY_URL}"  -c "INSERT INTO api_token VALUES ('{{ ckan_default_api_token }}', 'Default Token', '{{ ckan_admin_user_id }}', now()) ON CONFLICT DO NOTHING;"
echo "make admin superuser"
ckan -c "$CONFIG" sysadmin add admin
echo "Set datastore permissions"
ckan -c "$CONFIG" datastore set-permissions | psql "${CKAN_SQLALCHEMY_URL}"
echo bootstrap finished
