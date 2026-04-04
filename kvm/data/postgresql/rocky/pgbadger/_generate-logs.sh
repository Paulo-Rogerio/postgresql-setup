#!/usr/bin/env bash

read -p "Deseja Inserir Dados (y/n): " ret

[[ ${ret} == "y" ]] && for _ in {0..3}; do ./03-insert.sh; done

for _ in {0..100}; do ./05-select.sh; done

$(which pgbadger) --retention 52 -I -q /var/log/postgresql/postgresql-$(date +%a).log -O /opt/pgbadger/output

chown -R nginx. /opt/pgbadger/output
