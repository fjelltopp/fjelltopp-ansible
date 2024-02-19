#!/bin/bash

# check before starting Redis if there's a backup file present (needs to be
# copied into the pod manually, e.g. with kubectl cp) and restore it

if [ -f /var/lib/redis/restore_redis_db.rdb ]; then
  echo "Backup file exists, restoring..."
  mv /var/lib/redis/restore_redis_db.rdb /var/lib/redis/enketo-main.rdb
fi

echo "Starting Redis Server..."
redis-server /etc/redis/redis.conf
