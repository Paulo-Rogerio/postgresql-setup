#!/usr/bin/env bash

export PGPASSWORD="postgres"

psql \
  -U "app" \
  -h localhost \
  -d "app" \
  -p 5433 <<EOF
UPDATE people
SET first_name  = 'Paulo',
    last_name   = 'Rogerio',
    nationality = 'Brasil';

UPDATE person
SET first_name  = 'Paulo',
    last_name   = 'Rogerio',
    nationality = 'Brasil';
EOF
