#!/usr/bin/env bash

export PGPASSWORD="postgres"

echo "========================================="
echo "Export / Import Roles Only"
pg_dumpall \
  --roles-only \
  -U postgres \
  -h localhost \
  -p 5433 | \
sed '/CREATE ROLE postgres/d;
     /ALTER ROLE postgres/d;
     /GRANT .* TO postgres/d;
     /REVOKE .* FROM postgres/d;
     /COMMENT ON ROLE postgres/d' | \
psql \
  -U postgres \
  -h localhost \
  -p 5434 \
  -d postgres

echo "========================================="
echo "Create Database New Cluster"
psql -h localhost -U postgres -d postgres -p 5434 <<EOF
CREATE DATABASE "app" OWNER "app";
EOF

psql -h localhost -U postgres -d app -p 5434 <<EOF
BEGIN;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE CREATE ON DATABASE "app" FROM PUBLIC;
ALTER DEFAULT PRIVILEGES GRANT SELECT,INSERT,UPDATE,DELETE ON TABLES TO "app";
ALTER DEFAULT PRIVILEGES GRANT USAGE, SELECT ON SEQUENCES TO "app";
ALTER DEFAULT PRIVILEGES GRANT EXECUTE ON FUNCTIONS TO "app";
ALTER DEFAULT PRIVILEGES GRANT USAGE ON SCHEMAS TO "app";
GRANT CREATE ON SCHEMA public TO "app";
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "app";
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO "app";
GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO "app";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "app";
ALTER DATABASE "app" SET search_path = sistemas, public;
COMMIT;
EOF

echo "========================================="
echo "Export / Import Schema Only"
pg_dump \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 \
  --schema-only | \
psql \
  -U postgres \
  -h localhost \
  -p 5434 \
  -d app

