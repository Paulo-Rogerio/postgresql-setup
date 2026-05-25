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
\echo ''
\echo '********* Listando Publication **********'
\echo ''
SELECT * FROM pg_publication;
\echo ''
\echo '********* Listando Subscrition **********'
\echo ''
SELECT * FROM pg_subscription;
\echo ''
\echo '************ Listando Slots *************'
\echo ''
SELECT * FROM pg_replication_slots;
\echo ''
\echo '******* Current LSN do Cluster **********'
\echo ''
SELECT pg_current_wal_lsn();
EOF
