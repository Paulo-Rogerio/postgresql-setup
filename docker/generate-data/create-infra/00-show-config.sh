#!/usr/bin/env bash

export PGPASSWORD="postgres"

echo "========================================="
psql \
  -U "postgres" \
  -h localhost \
  -d "postgres" \
  -p 5433 <<EOF
  show all;
EOF


