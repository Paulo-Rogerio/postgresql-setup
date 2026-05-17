#!/usr/bin/env bash

export PGPASSWORD="postgres"

psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
SELECT
  slot_name,
  active,
  pg_size_pretty(
    pg_wal_lsn_diff(
      pg_current_wal_lsn(),
      restart_lsn
    )
  ) AS lag,
  restart_lsn,
  confirmed_flush_lsn
FROM pg_replication_slots;
EOF
