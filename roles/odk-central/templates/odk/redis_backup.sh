#!/bin/bash

apt update
apt install awscli curl -y

aws_cli=$(command -v aws)
export AWS_REGION="eu-west-1"
export AWS_ACCESS_KEY_ID="{{ odk_backup_aws_user_id }}"
export AWS_SECRET_ACCESS_KEY="{{ odk_backup_aws_user_key }}"
TEMP_BACKUP_LOCATION=/tmp/odk_backup
DATE=$(date +%Y%m%d)
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
cd "${DIR}" || exit 1

if [ -z "$slack_channel" ]; then
  slack_channel="infrastrucure"
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
    slack_channel="sentry-prod" slack_notify "{{ application_namespace }} ODK Redis backup" "Redis backup has failed on: $1." "ERROR"
  fi
  return 1
}

get_s3_backup_vars(){
  odk_backup_bucket="{{ odk_backup_bucket }}"
  odk_backup_sql_directory_s3="{{ odk_backup_sql_directory_s3 }}"
}

create_redis_dump(){
  redis-cli -h redis-enketo-main --rdb /tmp/"$DATE"_redis_enketo_main_dump.rdb
}

transfer_to_s3(){
  get_s3_backup_vars || error "getting variables from Secrets Manager"
  $aws_cli s3 mv "$1" s3://"$odk_backup_bucket"/"$odk_backup_sql_directory_s3"/
}

create_backup(){
  if [ ! -d "$TEMP_BACKUP_LOCATION" ]; then
    mkdir "$TEMP_BACKUP_LOCATION"
  fi
  create_redis_dump || error "creating ODK DB sql backup"
  transfer_to_s3 /tmp/"$DATE"_redis_enketo_main_dump.rdb ||  error "transferring ODK sql backup"
}

create_backup || error Create_backup

if [ -z "$SKIP_SLACK" ]; then
  slack_notify "{{ application_namespace }} ODK Redis backup" "{{ application_namespace }} ODK Redis backup has finished" "OK"
fi
echo "Time finished: "
date

