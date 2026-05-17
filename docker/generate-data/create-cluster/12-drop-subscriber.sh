#!/usr/bin/env bash

export PGPASSWORD="postgres"

psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5434 <<EOF
ALTER SUBSCRIPTION "app_subscriber" disable;
ALTER SUBSCRIPTION "app_subscriber" SET (slot_name = none);
DROP SUBSCRIPTION "app_subscriber";
DROP ROLE "app-subscriber";
EOF
