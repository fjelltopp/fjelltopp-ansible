#!/usr/bin/env bash

# This script expects a valid IAM user with write permissions to the
# target s3 bucket. This user (and IAM policy) is not created automatically
# Sample IAM policy is located in templates/ckanigator/s3_backup_access_policy.json
# (inside this role)

echo "Time started: "
date
set -e

apt update
apt install awscli -y

aws_cli=$(command -v aws)
pgdump=$(command -v pg_dump)
export AWS_REGION="eu-west-1"
export AWS_ACCESS_KEY_ID="{{ ckan_backup_access_key }}"
export AWS_SECRET_ACCESS_KEY="{{ ckan_backup_access_secret }}"
TEMP_BACKUP_LOCATION=/tmp/ckan_backup
DATE=$(date +%Y%m%d)
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
cd "${DIR}" || exit 1

error(){
  echo "${1} did fail, check your permissions"
  exit 1
}

get_s3_backup_vars(){
  ckan_backup_bucket="{{ ckan_backup_s3 }}"
  ckan_backup_sql_directory_s3="{{ ckan_backup_sql_directory_s3 }}"
}

create_pgdump(){
  $pgdump -F c -Z 6 -f "$1" "$2"
}

transfer_to_s3(){
  get_s3_backup_vars || error "getting variables from Secrets Manager"
  $aws_cli s3 mv "$1" "$ckan_backup_bucket"/"$ckan_backup_sql_directory_s3"/
}

create_backup(){
  if [ ! -d "$TEMP_BACKUP_LOCATION" ]; then
    mkdir "$TEMP_BACKUP_LOCATION"
  fi
  create_pgdump "$TEMP_BACKUP_LOCATION"/"$DATE"-ckandb.sql.custom  '{{ ckan_sqlalchemy_url }}' ||  error "creating CKAN DB sql backup"
  create_pgdump "$TEMP_BACKUP_LOCATION"/"$DATE"-datastoredb.sql.custom '{{ ckan_datastore_write_url }}' ||  error "creating Datastore DB sql backup"
  transfer_to_s3 "$TEMP_BACKUP_LOCATION"/"$DATE"-ckandb.sql.custom ||  error "transferring CKAN sql backup"
  transfer_to_s3 "$TEMP_BACKUP_LOCATION"/"$DATE"-datastoredb.sql.custom ||  error "transferring Datastore sql backup"
  rm -f /tmp/"$TEMP_BACKUP_LOCATION"/"$DATE"-ckandb.sql.custom /tmp/"$TEMP_BACKUP_LOCATION"/"$DATE"-datastoredb.sql.custom
}

create_backup || error Create_backup
echo "Time finished: "
date

