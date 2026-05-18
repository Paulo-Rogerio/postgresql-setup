#!/usr/bin/env bash

export PGPASSWORD="postgres"

echo "========================================="
psql \
  -U "app" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
  SELECT * FROM person ORDER BY id;
EOF


echo "========================================="
psql \
  -U "app" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
  SELECT * FROM people ORDER BY id;
EOF