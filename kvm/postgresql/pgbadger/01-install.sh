#!/usr/bin/env bash

echo "================================================"
echo "Install                                         "
echo "================================================"

ln -svf /bin/bash /bin/sh

apt install -y postgresql-common
bash -c "echo | /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh"

apt install curl ca-certificates -y
install -d /usr/share/postgresql-common/pgdg
curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
. /etc/os-release

sh -c "echo 'deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $VERSION_CODENAME-pgdg main' > /etc/apt/sources.list.d/pgdg.list"

apt update
apt -y install postgresql-17 postgresql-client-17 postgresql-17 libpq-dev

