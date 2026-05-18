#!/usr/bin/env bash

export PGPASSWORD="postgres"


# Subshell:
# - Injeta o SQL no psql, abre a tranzação e executa.
# - O cat sozinho mantém sessão aberta, esperando uma iteração

(cat <<EOF
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT pg_export_snapshot();
EOF
cat) | psql -U "postgres" -h localhost -d "app" -p 5433
