#!/usr/bin/env bash

sudo -iu postgres psql -U postgres -d postgres <<EOF
CREATE ROLE "app" LOGIN PASSWORD '@mudar123';
CREATE DATABASE "app" OWNER "app";
EOF

sudo -iu postgres psql -U postgres -d "app" <<EOF
BEGIN;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE CREATE ON DATABASE "app" FROM PUBLIC;
GRANT CREATE ON SCHEMA public TO "app";
ALTER DEFAULT PRIVILEGES GRANT SELECT,INSERT,UPDATE,DELETE ON TABLES TO "app";
ALTER DEFAULT PRIVILEGES GRANT USAGE, SELECT ON SEQUENCES TO "app";
ALTER DEFAULT PRIVILEGES GRANT EXECUTE ON FUNCTIONS TO "app";
ALTER DEFAULT PRIVILEGES GRANT USAGE ON SCHEMAS TO "app";
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "app";
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO "app";
GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO "app";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "app";
CREATE SCHEMA IF NOT EXISTS sistemas AUTHORIZATION "app";
ALTER DATABASE "app" SET search_path = sistema, public;
COMMIT;
EOF

export PGPASSWORD="@mudar123"
psql -U "app" -h localhost -d "app" <<EOF
SET search_path='sistemas';

CREATE TABLE sistemas.person (
    id SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    nationality TEXT,
    birthday DATE,
    photo_id INTEGER UNIQUE
);

CREATE OR REPLACE FUNCTION base26_encode(IN digits bigint, IN min_width int = 0)
  RETURNS varchar AS \$\$
        DECLARE
          chars char[];
          ret varchar;
          val bigint;
      BEGIN
      chars := ARRAY['A','B','C','D','E','F','G','H','I','J','K','L','M'
                    ,'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
      val := digits;
      ret := '';
      IF val < 0 THEN
          val := val * -1;
      END IF;
      WHILE val != 0 LOOP
          ret := chars[(val % 26)+1] || ret;
          val := val / 26;
      END LOOP;

      IF min_width > 0 AND char_length(ret) < min_width THEN
          ret := lpad(ret, min_width, '0');
      END IF;

      RETURN ret;

END;
\$\$ LANGUAGE 'plpgsql' IMMUTABLE;
EOF
