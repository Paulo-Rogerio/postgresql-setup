#!/usr/bin/env bash

export PGPASSWORD="postgres"

echo "========================================="
echo "List Publication"
psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
\x on;  
SELECT * FROM pg_subscription;
EOF

echo "========================================="
echo "List Slot Replication"
psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
\x on;  
SELECT * FROM pg_replication_slots;
EOF