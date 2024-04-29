#!/usr/bin/env bash

# This script expects a valid IAM user with read permissions to the
# target s3 bucket. This user (and IAM policy) is not created automatically
# Sample IAM policy is located in templates/ckan/s3_backup_access_policy.json
# (inside this role)

echo "Time started: "
date
set -e

apt update
apt install awscli curl -y

aws_cli=$(command -v aws)
pgrestore=$(command -v pg_restore)
export AWS_REGION="{{ aws_region }}"
export AWS_ACCESS_KEY_ID="{{ ckan_backup_access_key }}"
export AWS_SECRET_ACCESS_KEY="{{ ckan_backup_access_secret }}"
TEMP_BACKUP_LOCATION=/tmp/ckan_backup
DATE=$(date +%Y%m%d)
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
cd "${DIR}" || exit 1

if [ -z "$slack_channel" ]; then
  slack_channel="infrastructure"
fi
slack_webhook="{{ ckan_slack_webhook }}"

# run with "Message title" "Message body" "Message status" parameters, where
# "Message status" "ERROR" will print message in red block, otherwise it's green
slack_notify(){
  local color='good'
  if [ "${3}" == 'ERROR' ]; then
      color='danger'
  fi
  echo 'Sending to '${slack_channel}'...'
  local message="payload={\"channel\": \"#${slack_channel}\",\"attachments\":[{\"pretext\":\"${1}\",\"text\":\"${2}\",\"color\":\"${color}\"}]}"
  # set variable SKIP_SLACK if you don't want to send any Slack notifications
  if [ -z "$SKIP_SLACK" ]; then
    curl -X POST --data-urlencode "${message}" "${slack_webhook}"
  fi
}

error(){
  echo "${1} did fail, check your permissions"
  if [ -z "$SKIP_SLACK" ]; then
    slack_channel="sentry-stg" slack_notify "{{ application_namespace }} CKAN DB SQL restore" "RDS SQL dev DB restore has failed on: $1." "ERROR"
  fi
  return 1
}

get_s3_backup_vars(){
  ckan_backup_bucket="{{ ckan_backup_s3 }}"
  ckan_backup_sql_directory_s3="{{ ckan_backup_sql_directory_s3 }}"
}

run_dbcleanup(){
  export PGHOST="{{ ckan_rds_info.instances[0].endpoint.address }}"
  PGPASSWORD="{{ ckan_postgres_password }}" PGUSER="ckan" dropdb -f ckan
  PGPASSWORD="{{ ckan_postgres_password }}" PGUSER="ckan" dropdb -f datastore
  export PGPASSWORD="$POSTGRES_PASSWORD"
  psql -h "$POSTGRES_HOSTNAME" --username="$POSTGRES_USER" -d postgres -f /tmp/ckan_db_bootstrap.sql
}

run_pgrestore(){
  export PGHOST="{{ ckan_rds_info.instances[0].endpoint.address }}"
  PGPASSWORD="{{ ckan_postgres_password }}" PGUSER="ckan" $pgrestore -d "$2" -F c "$1"
}

copy_from_s3(){
  get_s3_backup_vars || error "getting variables from Secrets Manager"
  $aws_cli s3 cp "$ckan_backup_bucket"/"$ckan_backup_sql_directory_s3"/"$1" "$2"
}

sync_s3_storage(){
  $aws_cli s3 sync "s3://{{ giftless_env_sync_s3_source }}/"  "s3://{{ giftless_env_sync_s3_target }}/"
}

restore_backup(){
  if [ ! -d "$TEMP_BACKUP_LOCATION" ]; then
    mkdir "$TEMP_BACKUP_LOCATION"
  fi
  copy_from_s3 "$DATE"-ckandb.sql.custom "$TEMP_BACKUP_LOCATION"/"$DATE"-ckandb.sql.custom ||  error "transferring CKAN sql backup"
  copy_from_s3 "$DATE"-datastoredb.sql.custom "$TEMP_BACKUP_LOCATION"/"$DATE"-datastoredb.sql.custom ||  error "transferring Datastore sql backup"
  run_dbcleanup
  run_pgrestore "$TEMP_BACKUP_LOCATION"/"$DATE"-ckandb.sql.custom ckan ||  error "restoring CKAN DB sql backup"
  run_pgrestore "$TEMP_BACKUP_LOCATION"/"$DATE"-datastoredb.sql.custom datastore ||  error "restoring Datastore DB sql backup"
  rm -f /tmp/"$TEMP_BACKUP_LOCATION"/"$DATE"-ckan_engine.sql.custom /tmp/"$TEMP_BACKUP_LOCATION"/"$DATE"-ckan_api.sql.custom
  sync_s3_storage || error "Syncing Giftless S3 buckets"
}

restore_backup || error restore_backup
if [ -z "$SKIP_SLACK" ]; then
  slack_notify "{{ application_namespace }} CKAN DB SQL restore" "{{ application_namespace }} CKAN DB SQL restore has finished" "OK"
fi
echo "Time finished: "
date

