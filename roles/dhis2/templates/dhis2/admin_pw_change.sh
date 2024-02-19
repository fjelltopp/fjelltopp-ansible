#!/bin/bash
# This script is used to change the default DHIS2 admin password, "district" to
# something more secure. It's supposed to run during environment bootstraping, 
# after the metadata import is complete

set -e

DEFAULT_ADMIN_PW="district"
NEW_ADMIN_PW="{{ dhis2_admin_password }}"
DHIS2_URL="http://dhis2:8080"

# Get JQ
apt update && apt install jq -y

# Get the admin ID
admin_id=$(curl -u admin:"$DEFAULT_ADMIN_PW" "$DHIS2_URL"/api/userLookup?query=admin|jq -r .users[].id)

# Get the current user information an add new password to it
curl -u admin:"$DEFAULT_ADMIN_PW" "$DHIS2_URL"/api/users/"$admin_id"|jq -r |jq --arg NEW_ADMIN_PW "$NEW_ADMIN_PW" \
'.userCredentials.password=$NEW_ADMIN_PW'> /tmp/user.json

# Update the admin passoword
curl -X PUT -d @/tmp/user.json "$DHIS2_URL"/api/users/"$admin_id" -u admin:"$DEFAULT_ADMIN_PW" -H "Content-Type: application/json"
