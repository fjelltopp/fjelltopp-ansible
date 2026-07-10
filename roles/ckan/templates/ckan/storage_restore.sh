#!/usr/bin/env bash
set -euo pipefail

export AWS_REGION="{{ aws_region }}"
export AWS_DEFAULT_REGION="{{ aws_region }}"
export AWS_ACCESS_KEY_ID="{{ ckan_backup_access_key }}"
export AWS_SECRET_ACCESS_KEY="{{ ckan_backup_access_secret }}"

grep -q " /var/lib/ckan/storage " /proc/mounts || {
  echo "ERROR: ckan-storage PVC is not mounted at /var/lib/ckan/storage — aborting"
  exit 1
}

OBJECT_COUNT=$(aws s3 ls "{{ ckan_backup_s3 }}/storage_backups/" --recursive 2>/dev/null | wc -l)
if [ "$OBJECT_COUNT" -eq 0 ]; then
  echo "ERROR: S3 prefix storage_backups/ is empty — aborting to prevent wiping ckan-storage"
  exit 1
fi

echo "Time started: $(date -u)"
echo "Syncing {{ ckan_backup_s3 }}/storage_backups/ -> /var/lib/ckan/storage/"
aws s3 sync "{{ ckan_backup_s3 }}/storage_backups/" /var/lib/ckan/storage/ --delete
echo "Time finished: $(date -u)"
