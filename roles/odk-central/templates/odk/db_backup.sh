#!/usr/bin/env bash

# This script expects a valid IAM user with write permissions to the
# target s3 bucket. This user (and IAM policy) is created automatically
# IAM policy is located in templates/odk/s3_backup_access_policy.json
# (inside this role)

echo "Time started: "
date
set -e

apt update
apt install awscli curl -y

aws_cli=$(command -v aws)
pgdump=$(command -v pg_dump)
export AWS_REGION="eu-west-1"
export AWS_ACCESS_KEY_ID="{{ odk_backup_aws_user_id }}"
export AWS_SECRET_ACCESS_KEY="{{ odk_backup_aws_user_key }}"
odk_db_url="postgres://{{ odk_db_user }}:{{ odk_postgres_password }}@{{ odk_db_hostname }}/{{ odk_db_database }}
TEMP_BACKUP_LOCATION=/tmp/odk_backup
DATE=$(date +%Y%m%d)
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
cd "${DIR}" || exit 1

if [ -z "$slack_channel" ]; then
  slack_channel="infrastructure"
fi
slack_webhook="{{ odk_slack_webhook }}"
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
    slack_channel="sentry-prod" slack_notify "{{ application_namespace }} ODK DB SQL backup" "RDS SQL DB backup has failed on: $1." "ERROR"
  fi
  return 1
}

get_s3_backup_vars(){
  odk_backup_bucket="{{ odk_backup_bucket }}"
  odk_backup_sql_directory_s3="{{ odk_backup_sql_directory_s3 }}"
}

create_pgdump(){
  $pgdump -F c -Z 6 -f "$1" "$2"
}

transfer_to_s3(){
  get_s3_backup_vars || error "getting variables from Secrets Manager"
  $aws_cli s3 mv "$1" s3://"$odk_backup_bucket"/"$odk_backup_sql_directory_s3"/
}

create_backup(){
  if [ ! -d "$TEMP_BACKUP_LOCATION" ]; then
    mkdir "$TEMP_BACKUP_LOCATION"
  fi
  create_pgdump "$TEMP_BACKUP_LOCATION"/"$DATE"-odkdb.sql.custom  "$odk_db_url" ||  error "creating ODK DB sql backup"
  transfer_to_s3 "$TEMP_BACKUP_LOCATION"/"$DATE"-odkdb.sql.custom ||  error "transferring ODK sql backup"
  rm -f /tmp/"$TEMP_BACKUP_LOCATION"/"$DATE"-odkdb.sql.custom 
}

create_backup || error Create_backup
if [ -z "$SKIP_SLACK" ]; then
  slack_notify "{{ application_namespace }} ODK DB SQL backup" "{{ application_namespace }} ODK DB SQL backup has finished" "OK"
fi
echo "Time finished: "
date

