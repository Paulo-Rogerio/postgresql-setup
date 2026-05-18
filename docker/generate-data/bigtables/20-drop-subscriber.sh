#!/usr/bin/env bash

export PGPASSWORD="postgres"

psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5434 <<EOF

ALTER SUBSCRIPTION "app_subscriber" disable;
ALTER SUBSCRIPTION "app_subscriber_bigtable" disable;

ALTER SUBSCRIPTION "app_subscriber" SET (slot_name = none);
ALTER SUBSCRIPTION "app_subscriber_bigtable" SET (slot_name = none);

DROP SUBSCRIPTION "app_subscriber";
DROP SUBSCRIPTION "app_subscriber_bigtable";

DROP ROLE "app-subscriber";
EOF
