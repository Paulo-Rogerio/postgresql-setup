#!/usr/bin/env bash

export PGPASSWORD="postgres"

psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
DROP PUBLICATION "app_publisher";
SELECT pg_drop_replication_slot('app_slot');
DROP ROLE "app-publisher";
EOF
