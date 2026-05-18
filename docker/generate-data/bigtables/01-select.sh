#!/usr/bin/env bash

export PGPASSWORD="postgres"

psql \
  -U "app" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
  SELECT * FROM people ORDER BY id;
  SELECT * FROM person ORDER BY id;
EOF
