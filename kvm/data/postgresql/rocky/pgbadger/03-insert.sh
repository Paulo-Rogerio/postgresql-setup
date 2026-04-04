#!/usr/bin/env bash

export PGPASSWORD="@mudar123"

psql -U "app" -h localhost -d "app" -c "select count(*) from sistemas.person;"

read -p "Start Range: " range_start
read -p "Start End  : " range_end

psql \
  -U "app" \
  -d "app" \
  -h localhost \
  -v range_start=${range_start} -v range_end=${range_end} <<EOF
SET search_path='sistemas';
INSERT INTO sistemas.person (
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
EOF
