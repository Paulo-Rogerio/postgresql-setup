#!/usr/bin/env bash

export PGPASSWORD="postgres"

export BIGTABLES=$(psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 \
  -At <<EOF
SELECT string_agg(quote_ident(schemaname) || '.' || quote_ident(tablename), ', ')
FROM pg_tables
WHERE schemaname = 'sistemas' 
AND tablename IN ('people');
EOF
)

psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
CREATE ROLE "app-publisher" LOGIN SUPERUSER;
SET ROLE "app-publisher";
CREATE PUBLICATION "app_publisher_bigtable" FOR TABLE ${BIGTABLES};
EOF
