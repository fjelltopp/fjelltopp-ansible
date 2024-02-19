#!/bin/sh
set -e

# This script is supposed to run on a freshly installed DHIS2, that still runs with
# a default admin password. Once the script completes the admin password will be changed
# to a randomly generated secret (on non-local environments). This should prevent from 
# an accidental second run

DHIS2_URL="dhis2:8080/api/metadata"
GH_RAW_URL="{{ github_metadata_raw_url }}"
METADATA_FOLDERS="{{ metadata_folders }}"
METADATA_FILES="{{ metadata_files }}"
DHIS2_USER="admin"
DHIS2_PW="district"

# Create folders for metadata
for FOLDER in ${METADATA_FOLDERS}; do
  echo "Creating folder $FOLDER";
  mkdir /tmp/"$FOLDER"
done

# Import organization metadata section
for FILE in ${METADATA_FILES}; do
  echo "Running Metadata import for $FILE";
  curl -o /tmp/"$FILE" "$GH_RAW_URL/$FILE" || exit 1; 
  curl "$DHIS2_URL" -X POST \
    -d @/tmp/"$FILE" \
    -H "Content-Type: application/json" -u "$DHIS2_USER":"$DHIS2_PW" || exit 1;
  rm -f /tmp/"$FILE"
done

