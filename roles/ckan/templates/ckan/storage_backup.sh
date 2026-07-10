#!/usr/bin/env bash
set -euo pipefail

export AWS_REGION="{{ aws_region }}"
export AWS_DEFAULT_REGION="{{ aws_region }}"
export AWS_ACCESS_KEY_ID="{{ ckan_backup_access_key }}"
export AWS_SECRET_ACCESS_KEY="{{ ckan_backup_access_secret }}"

grep -q " /var/lib/ckan/storage " /proc/mounts || {
  echo "ERROR: ckan-storage PVC is not mounted at /var/lib/ckan/storage — aborting to prevent wiping S3 backup"
  exit 1
}

echo "Time started: $(date -u)"
echo "Syncing /var/lib/ckan/storage/ -> {{ ckan_backup_s3 }}/storage_backups/"
aws s3 sync /var/lib/ckan/storage/ "{{ ckan_backup_s3 }}/storage_backups/" --delete
echo "Time finished: $(date -u)"
