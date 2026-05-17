#!/usr/bin/env bash

export PGPASSWORD="postgres"

# Aqui nao crio o slot automaticamente, pelo subscription. Controlo isso no publication.

psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5434 <<EOF
CREATE ROLE "app-subscriber" LOGIN SUPERUSER;
SET ROLE "app-subscriber";
CREATE SUBSCRIPTION "app_subscriber"
CONNECTION 'host=primary port=5432 user=replicator password=postgres dbname=app'
PUBLICATION "app_publisher" WITH (create_slot = false, slot_name = 'app_slot');
EOF
