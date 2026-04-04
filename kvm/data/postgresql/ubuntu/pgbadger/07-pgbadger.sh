#!/usr/bin/env bash

apt -y install pgbadger tree

mkdir -p /opt/pgbadger/output

$(which pgbadger) --retention 52 -I -q /var/log/postgresql/postgresql-$(date +%a).log -O /opt/pgbadger/output

chown -R www-data. /opt/pgbadger/output

