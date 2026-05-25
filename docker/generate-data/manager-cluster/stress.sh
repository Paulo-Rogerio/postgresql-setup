#!/usr/bin/env bash

cd $(dirname $0)

export PGPASSWORD="postgres"

echo "========================================="
echo "Insert Em Massa"
psql \
  -U "app" \
  -d "app" \
  -h localhost \
  -v range_start=1 -v range_end=1000 \
  -p 5433 <<EOF
BEGIN;
SET search_path='sistemas';
INSERT INTO people (
 first_name,
 last_name,
 nationality,
 birthday,
 photo_id
)
SELECT
  initcap(base26_encode(substring(random()::text,3,10)::bigint)) AS first_name
, initcap(base26_encode(substring(random()::text,3,15)::bigint)) AS last_name
, initcap(base26_encode(substring(random()::text,3,9)::bigint)) AS nationality
, 'now'::date - (interval '90 years' * random()) AS birthday
, ceil(random()*2100000000) AS photo_id
FROM generate_series(:range_start,:range_end) num;

INSERT INTO person (
 first_name,
 last_name,
 nationality,
 birthday,
 photo_id
)
SELECT
  initcap(base26_encode(substring(random()::text,3,10)::bigint)) AS first_name
, initcap(base26_encode(substring(random()::text,3,15)::bigint)) AS last_name
, initcap(base26_encode(substring(random()::text,3,9)::bigint)) AS nationality
, 'now'::date - (interval '90 years' * random()) AS birthday
, ceil(random()*2100000000) AS photo_id
FROM generate_series(:range_start,:range_end) num;
COMMIT;
EOF

echo "========================================="
echo "Update Em Massa"
psql \
  -U "app" \
  -d "app" \
  -h localhost \
  -v range_start=1 -v range_end=500 \
  -p 5433 <<EOF
BEGIN;
SET search_path='sistemas';
UPDATE people
SET first_name = 'Paulo Rogerio';
UPDATE person
SET first_name = 'Paulo Rogerio';
COMMIT;
EOF

echo "========================================="
echo "Delete Em Massa"
psql \
  -U "app" \
  -d "app" \
  -h localhost \
  -v range_start=1 -v range_end=500 \
  -p 5433 <<EOF
BEGIN;
SET search_path='sistemas';
DELETE FROM person WHERE id > 1;
COMMIT;
EOF

echo "========================================="
echo "Check Lag"
bash 21-check-lag.sh
sleep 2
