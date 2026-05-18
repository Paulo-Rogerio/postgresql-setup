#!/usr/bin/env bash

export PGPASSWORD="postgres"

echo "========================================="
echo "Check LSN Publication"
psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
  SELECT pg_current_wal_lsn();
EOF


echo "========================================="
echo "Check LSN Subscriber"
psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5434 <<EOF
SELECT latest_end_lsn
FROM pg_stat_subscription;
EOF
