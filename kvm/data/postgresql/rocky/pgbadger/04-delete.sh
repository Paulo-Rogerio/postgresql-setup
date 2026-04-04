#!/usr/bin/env bash

export PGPASSWORD=@mudar123

psql \
  -U "app" \
  -h localhost \
  -d "app" <<EOF
SET search_path='sistemas';
DELETE FROM sistemas.person WHERE id > 5;
EOF