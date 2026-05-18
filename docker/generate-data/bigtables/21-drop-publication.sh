#!/usr/bin/env bash

export PGPASSWORD="postgres"

psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF

DROP PUBLICATION "app_publisher";
DROP PUBLICATION "app_publisher_bigtable";

SELECT pg_drop_replication_slot('app_slot');
SELECT pg_drop_replication_slot('app_slot_bigtable');

DROP ROLE "app-publisher";
EOF
