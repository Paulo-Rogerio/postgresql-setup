#!/usr/bin/env bash

export PGPASSWORD="postgres"

psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5434 <<EOF
SET ROLE "app-subscriber";
CREATE SUBSCRIPTION "app_subscriber"
CONNECTION 'host=primary port=5432 user=replicator password=postgres dbname=app'
PUBLICATION "app_publisher" WITH (create_slot = false, slot_name = 'app_slot');
EOF
