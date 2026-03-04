#!/usr/bin/env bash

export PGPASSWORD=@mudar123

psql \
  -U "app" \
  -h localhost \
  -d "app" <<EOF
SET search_path='sistemas';
SELECT * FROM sistemas.person;
EOF