#!/usr/bin/env bash

export PGPASSWORD="postgres"

psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
SELECT * FROM pg_create_logical_replication_slot('app_slot_bigtable', 'pgoutput');
EOF

