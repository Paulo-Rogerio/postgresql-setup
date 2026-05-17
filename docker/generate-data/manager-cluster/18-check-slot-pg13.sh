#!/usr/bin/env bash

export PGPASSWORD="postgres"

psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
SELECT
  slot_name,
  plugin,
  slot_type,
  active,
  restart_lsn,
  confirmed_flush_lsn
FROM pg_replication_slots;
EOF
