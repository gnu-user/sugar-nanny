#!/bin/bash

# Install and config nginx
apt-get install -y nginx nginx-extras
cp -vf ../config/nginx.conf /etc/nginx/
cp -vf ../config/default /etc/nginx/sites-enabled/
# Restart nginx
service nginx restart
