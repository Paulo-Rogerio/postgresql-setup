#!/usr/bin/env bash

echo "================================================"
echo "Configure                                       "
echo "================================================"

rm -rf /data/*
rm -rf /wal/*

mkdir -p /data/17/pgdata
mkdir -p /wal/17

chown postgres: /data/ -R
chown postgres: /wal/ -R

pg_dropcluster --stop 17 main

systemctl stop postgresql

rm -rf /var/lib/postgresql/17

pg_createcluster 17 main \
    --datadir=/data/17/pgdata \
    --locale=en_US.UTF-8 \
    --encoding=UTF-8

sudo -iu postgres mv /data/17/pgdata/pg_wal /wal/17/
sudo -iu postgres ln -svf /wal/17/pg_wal /data/17/pgdata/pg_wal

sudo -iu postgres cp /etc/postgresql/17/main/postgresql.conf{,.ori}
sudo -iu postgres cp /etc/postgresql/17/main/pg_hba.conf{,.ori}

cat > /etc/postgresql/17/main/pg_hba.conf <<EOF
local   all             postgres                                trust
local   all             all                                     trust
host    all             all             0.0.0.0/0            scram-sha-256
host    all             all             ::1/128                 scram-sha-256
local   replication     all                                     trust
host    replication     all             127.0.0.1/32            scram-sha-256
host    replication     all             ::1/128                 scram-sha-256
EOF


cat > /etc/postgresql/17/main/postgresql.conf <<EOF
archive_command = 'exit 0'
archive_mode = 'on'
listen_addresses = '*'
data_directory = '/data/17/pgdata'
hba_file = '/etc/postgresql/17/main/pg_hba.conf'
ident_file = '/etc/postgresql/17/main/pg_ident.conf'
external_pid_file = '/var/run/postgresql/17-main.pid'
port = 5432
max_connections = 100
unix_socket_directories = '/var/run/postgresql'
ssl = on
ssl_cert_file = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
ssl_key_file = '/etc/ssl/private/ssl-cert-snakeoil.key'
shared_buffers = 128MB
dynamic_shared_memory_type = posix
max_wal_size = 1GB
min_wal_size = 80MB
log_timezone = 'Etc/UTC'
cluster_name = '17/main'
datestyle = 'iso, mdy'
timezone = 'Etc/UTC'
lc_messages = 'en_US.UTF-8'
lc_monetary = 'en_US.UTF-8'
lc_numeric = 'en_US.UTF-8'
lc_time = 'en_US.UTF-8'
log_autovacuum_min_duration = '0'
log_checkpoints = 'on'
log_connections = 'on'
log_destination = 'stderr'
log_directory = '/var/log/postgresql'
log_disconnections = 'on'
log_file_mode = '0644'
log_filename = 'postgresql-%a.log'
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_lock_waits = 'on'
log_min_duration_statement = '100ms'
log_rotation_age = '1d'
log_rotation_size = '0'
log_statement = 'ddl'
log_temp_files = '0'
log_truncate_on_rotation = 'true'
logging_collector = 'true'
default_text_search_config = 'pg_catalog.english'
include_dir = 'conf.d'
EOF

echo "" > /var/log/postgresql/postgresql-$(date +%a).log
chown postgres: /var/log/postgresql/postgresql-$(date +%a).log

systemctl start postgresql
systemctl status postgresql