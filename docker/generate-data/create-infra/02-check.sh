#!/usr/bin/env bash

export PGPASSWORD="postgres"

echo "========================================="
psql \
  -U "app" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
  show search_path;
EOF

echo "========================================="
psql \
  -U "app" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
  \dt
EOF

