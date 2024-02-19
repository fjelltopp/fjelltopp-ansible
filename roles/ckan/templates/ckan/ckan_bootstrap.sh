#!/bin/sh
CONFIG=/etc/ckan/production.ini
# we're making sure to run our custom entrypoint.
/usr/lib/ckan/ckan-entrypoint.sh
echo "DB init:"
ckan -c "$CONFIG" db init
echo "Add admin user:"
ckan -c "$CONFIG" user add admin email=admin@localhost name=admin fullname=Admin password=fjelltopp apikey={{ ckan_admin_api_key }} id=9e857b62-4d85-438d-b750-5e105a703f62
echo "Set apikey:"
psql "${CKAN_SQLALCHEMY_URL}"  -c "UPDATE public.user SET apikey = '{{ ckan_admin_api_key }}' WHERE name = 'admin';"
echo "Create API token:"
psql "${CKAN_SQLALCHEMY_URL}"  -c "INSERT INTO api_token VALUES ('S8o_LBBjXTSl-l24iDAzZh0m8mzZMtR5Stra7G-wP2AoSZlqL9dTNeFWLyohKief-mtC_lxVGmqUrlg5', 'Default Token', '9e857b62-4d85-438d-b750-5e105a703f62', now()) ON CONFLICT DO NOTHING;"
echo "make admin superuser"
ckan -c "$CONFIG" sysadmin add admin
echo bootstrap finished


