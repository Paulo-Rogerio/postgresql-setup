#!/usr/bin/env bash

export PGPASSWORD="postgres"

echo "========================================="
echo "List Publication"
psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5434 <<EOF
\x on;  
SELECT * FROM pg_subscription;
EOF
