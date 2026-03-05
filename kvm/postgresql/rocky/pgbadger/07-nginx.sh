#!/usr/bin/env bash

dnf -y install nginx

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

chown -R nginx. /opt/pgbadger/output
chmod -R 755 /opt/pgbadger/output

nginx -t

systemctl enable nginx
systemctl start nginx
systemctl status nginx
