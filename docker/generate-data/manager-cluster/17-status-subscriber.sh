#!/usr/bin/env bash

export PGPASSWORD="postgres"

psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5434 <<EOF
SELECT
  subname,
  pid,
  received_lsn,
  latest_end_lsn,
  latest_end_time,
  now() - latest_end_time AS replication_delay
FROM pg_stat_subscription;
EOF
