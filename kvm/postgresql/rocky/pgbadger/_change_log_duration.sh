#!/usr/bin/env bash

echo "Qual valor atual de log_min_duration_statement ?"

cat /data/17/pgdata/postgresql.conf | grep log_min_duration_statement 

echo

read -p "Qual valor desejado para log_min_duration_statement (0/100) ms: " ret

if [[ ${ret} == "0" ]]
then
  sed -i "s/^log_min_duration_statement = '100ms'/log_min_duration_statement = '0'/" /data/17/pgdata/postgresql.conf
else
  sed -i "s/^log_min_duration_statement = '0'/log_min_duration_statement = '100ms'/" /data/17/pgdata/postgresql.conf
fi

[[ -n ${ret} ]] && \
sudo -iu postgres psql -U postgres -d postgres <<EOF
SELECT pg_reload_conf();
EOF
