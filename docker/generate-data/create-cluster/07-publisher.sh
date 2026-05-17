#!/usr/bin/env bash

export PGPASSWORD="postgres"

psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
CREATE ROLE "app-publisher" LOGIN SUPERUSER;
SET ROLE "app-publisher";
CREATE PUBLICATION "app_publisher" FOR ALL TABLES;
SELECT * FROM pg_create_logical_replication_slot('app_slot', 'pgoutput');
EOF
