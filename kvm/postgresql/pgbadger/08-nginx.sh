#!/usr/bin/env bash

# export TZ=America/Sao_Paulo
# export DEBIAN_FRONTEND='noninteractive'

apt -y install nginx

cat > /etc/nginx/conf.d/pgbadger.conf <<EOF
server {
    listen 80;
    server_name _;

    location /pgbadger/ {
        alias /opt/pgbadger/output/;
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
        index index.html;
    }
}
EOF

chown -R www-data. /opt/pgbadger/output
chmod -R 755 /opt/pgbadger/output

rm -f /etc/nginx/sites-enabled/default
ln -svf /etc/nginx/conf.d/pgbadger.conf /etc/nginx/sites-enabled/pgbadger.conf

nginx -t

systemctl reload nginx
