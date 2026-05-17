#!/usr/bin/env bash

export PGPASSWORD="postgres"

psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5434 <<EOF
ALTER SUBSCRIPTION "app_subscriber" disable;
EOF
