#!/usr/bin/env bash

echo "================================================"
echo "Install                                         "
echo "================================================"

dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
dnf -qy module disable postgresql
dnf install -y postgresql${PGVERSION}-server

mkdir -p /data/${PGVERSION}/pgdata
mkdir -p /wal/${PGVERSION}
chown postgres. /data/ -R
chown postgres. /wal/ -R

sudo -iu postgres /usr/pgsql-${PGVERSION}/bin/initdb \
  -D /data/${PGVERSION}/pgdata/ \
  -X /wal/${PGVERSION}/pg_wal/ \
  --encoding='UTF-8' \
  --locale='en_US.UTF-8'

cat > /data/${PGVERSION}/pgdata/pg_hba.conf <<EOF
local   all             postgres                             trust
local   all             all                                  trust
host    all             all             0.0.0.0/0            scram-sha-256
host    all             all             ::1/128              scram-sha-256
local   replication     all                                  trust
host    replication     all             127.0.0.1/32         scram-sha-256
host    replication     all             ::1/128              scram-sha-256
EOF

cat > /data/${PGVERSION}/pgdata/postgresql.conf <<EOF
archive_command = 'exit 0'
archive_mode = 'on'
listen_addresses = '*'
data_directory = '/data/${PGVERSION}/pgdata'
hba_file = '/data/${PGVERSION}/pgdata/pg_hba.conf'
ident_file = '/data/${PGVERSION}/pgdata/pg_ident.conf'
external_pid_file = '/var/run/postgresql/postgresql.pid'
port = 5432
max_connections = 100
unix_socket_directories = '/var/run/postgresql'
shared_buffers = 128MB
dynamic_shared_memory_type = posix
max_wal_size = 1GB
min_wal_size = 80MB
log_timezone = 'Etc/UTC'
cluster_name = '${PGVERSION}/main'
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
EOF

mkdir -p /etc/systemd/system/postgresql-${PGVERSION}.service.d
touch /etc/systemd/system/postgresql-${PGVERSION}.service.d/override.conf
cat > /etc/systemd/system/postgresql-${PGVERSION}.service.d/override.conf <<EOF
[Service]
Environment=PGDATA=/data/${PGVERSION}/pgdata
EOF

mkdir -p /var/log/postgresql
chown postgres. /var/log/postgresql


echo "====================================="
echo "Start Postgres ${PGVERSION}"
echo "====================================="
systemctl enable postgresql-${PGVERSION}
systemctl start postgresql-${PGVERSION}
killall gpg-agent
