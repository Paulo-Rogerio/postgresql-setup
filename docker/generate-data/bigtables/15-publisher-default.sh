#!/usr/bin/env bash

export PGPASSWORD="postgres"

export TABLES=$(psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 \
  -At <<EOF
SELECT string_agg(quote_ident(schemaname) || '.' || quote_ident(tablename), ', ')
FROM pg_tables
WHERE schemaname = 'sistemas' 
AND tablename NOT IN ('people');
EOF
)

psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
SET ROLE "app-publisher";
CREATE PUBLICATION "app_publisher" FOR TABLE ${TABLES};
SELECT * FROM pg_create_logical_replication_slot('app_slot', 'pgoutput');
EOF



