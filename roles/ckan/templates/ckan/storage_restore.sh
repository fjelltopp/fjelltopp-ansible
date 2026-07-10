#!/usr/bin/env bash
set -euo pipefail

export AWS_REGION="{{ aws_region }}"
export AWS_DEFAULT_REGION="{{ aws_region }}"
export AWS_ACCESS_KEY_ID="{{ ckan_backup_access_key }}"
export AWS_SECRET_ACCESS_KEY="{{ ckan_backup_access_secret }}"

echo "Time started: $(date -u)"
echo "Syncing {{ ckan_backup_s3 }}/storage_backups/ -> /var/lib/ckan/storage/"
aws s3 sync "{{ ckan_backup_s3 }}/storage_backups/" /var/lib/ckan/storage/ --delete
echo "Time finished: $(date -u)"
