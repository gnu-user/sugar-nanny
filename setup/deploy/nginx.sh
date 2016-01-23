#!/bin/bash

# Install and config nginx
apt-get install -y nginx nginx-extras
cp -vf ../config/nginx.conf /etc/nginx/
cp -vf ../config/default /etc/nginx/sites-enabled/
# Setup SSL certs
cp -vrf ../config/.certs ~/
chmod 0600 ~/.certs/*.pem
chmod 0644 ~/.certs/*.crt
chmod 0644 ~/.certs/*.csr
# Restart nginx
service nginx restart
