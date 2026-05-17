#!/usr/bin/env bash

export PGPASSWORD="postgres"

psql \
  -U "app" \
  -h localhost \
  -d "app" \
  -p 5434 <<EOF
UPDATE person
SET first_name  = 'Camilla',
    last_name   = 'Moureira',
    nationality = 'Brasil';
EOF
