#!/usr/bin/env bash

export PGPASSWORD="postgres"

sql="DO
\$\$
DECLARE
    seq RECORD;
    tbl TEXT;
    col TEXT;
    max_val BIGINT;
    sql TEXT;
BEGIN
    FOR seq IN
        SELECT
            s.relname AS sequence_name,
            t.relname AS table_name,
            a.attname AS column_name
        FROM
            pg_class s
            JOIN pg_depend d ON d.objid = s.oid
            JOIN pg_class t ON d.refobjid = t.oid
            JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = d.refobjsubid
        WHERE
            s.relkind = 'S'
    LOOP
        tbl := seq.table_name;
        col := seq.column_name;

         -- Monta SQL para pegar o maior valor da coluna
        sql := format('SELECT MAX(%I) FROM %I', col, tbl);
        RAISE NOTICE 'SQL MAX Value %s: %s', tbl, sql;

   	-- Executa SQL dinâmico para pegar o maior valor da coluna
        EXECUTE format('SELECT MAX(%I) FROM %I', col, tbl) INTO max_val;

        IF max_val IS NOT NULL THEN

	    sql := format('SELECT setval(%L, %s)', seq.sequence_name, max_val + 1);
            RAISE NOTICE 'SQL para ajustar sequence: %', sql;

            -- Ajusta a sequence para um valor maior que o máximo encontrado
            EXECUTE format('SELECT setval(%L, %s)', seq.sequence_name, max_val + 1);
            RAISE NOTICE '===========================================================';
        END IF;
    END LOOP;
END
\$\$;"

psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5434 \
  -c "${sql}"



