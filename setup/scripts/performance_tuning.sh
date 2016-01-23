#!/bin/sh

# 5. Optimizing filesystem

echo ""
echo "${bldgrn}5) Optimizing Filesystem${txtrst}"
echo ""

# Set max file handles

ulimit -n 200000

cat >> /etc/security/limits.conf<<'EOL'
* hard nofile 200000
* soft nofile 200000
* hard noproc 64000
* soft noproc 64000
EOL

#set noatime on /
awk '!/^#/ && ($2 == "/") { if(!match($4, /noatime/)) $4=$4",noatime"; } 1' OFS='\t' /etc/fstab > /tmp/$$
cat /tmp/$$ > /etc/fstab
rm -f /tmp/$$
#cant set dirnoatime as it crashes boot
#awk '!/^#/ && ($2 == "/") { if(!match($4, /dirnoatime/)) $4=$4",dirnoatime"; } 1' OFS='\t' /etc/fstab > /tmp/$$
#cat /tmp/$$ > /etc/fstab
#rm -f /tmp/$$

#5. install nginx

echo ""
echo "${bldgrn}6) Installing nginx${txtrst}"
echo ""

yum -y install nginx

#config files
echo ""
echo "${txtgrn}* Creating nginx config files${txtrst}"
if [ -f "/etc/nginx/nginx.conf" ]; then
	mv /etc/nginx/nginx.conf /etc/nginx/nginx.aws.default.conf
fi

cat > /etc/nginx/nginx.conf<<'EOL'
# main module

user nginx nginx;

#  This number should be, at maximum, the number of CPU cores on your system.
#  (since nginx doesn't benefit from more than one worker per CPU.)
worker_processes  1;

#  Number of file descriptors used for Nginx. This is set in the OS with 'ulimit -n 200000'
#  or using /etc/security/limits.conf
worker_rlimit_nofile 200000;

error_log  /var/log/nginx/error.log crit;
pid        /var/run/nginx.pid;


# events module

events {
#  Determines how many clients will be served by each worker process.
#  (Max clients = worker_connections * worker_processes)
#  "Max clients" is also limited by the number of socket connections available on the system (~64k)
worker_connections  4000;

#  the effective method, used on Solaris 7 11/99+, HP/UX 11.22+ (eventport), IRIX 6.5.15+ and Tru64 UNIX 5.1A+
use epoll;

#  Accept as many connections as possible, after nginx gets notification about a new connection.
#  May flood worker_connections, if that option is set too low.
multi_accept on;
}

# http core module

http {
#prevent iframing of pages - use DENY to not allow anything
add_header X-Frame-Options SAMEORIGIN;
charset utf-8;

open_file_cache max=200000 inactive=20s;
open_file_cache_valid 30s;
open_file_cache_min_uses 2;
open_file_cache_errors on;

server_tokens off;
include       /etc/nginx/mime.types;
default_type  application/octet-stream;

log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" '
                  '"$http_user_agent" "$http_x_forwarded_for" nocache:$no_cache/$sent_http_x_microcachable/$upstream_cache_status';

#  Buffer log writes to speed up IO, or disable them altogether
# access_log /var/log/nginx/access.log main buffer=16k;
access_log off;

#  Sendfile copies data between one FD and other from within the kernel.
#  More efficient than read() + write(), since the requires transferring data to and from the user space.
sendfile on;

#  Tcp_nopush causes nginx to attempt to send its HTTP response head in one packet,
#  instead of using partial frames. This is useful for prepending headers before calling sendfile,
#  or for throughput optimization.
tcp_nopush on;

#  don't buffer data-sends (disable Nagle algorithm). Good for sending frequent small bursts of data in real time.
tcp_nodelay on;

#  Timeout for keep-alive connections. Server will close connections after this time.
keepalive_timeout 30;

#  Number of requests a client can make over the keep-alive connection. This is set high for testing.
keepalive_requests 100000;

#  allow the server to close the connection after a client stops responding. Frees up socket-associated memory.
reset_timedout_connection on;

#  send the client a "request timed out" if the body is not loaded by this time. Default 60.
client_body_timeout 10;

#  If the client stops reading data, free up the stale client connection after this much time. Default 60.
send_timeout 2;

# unsure what this does - recommended here:
# http://www.howtoforge.com/configuring-your-lemp-system-linux-nginx-mysql-php-fpm-for-maximum-performance
types_hash_max_size 2048;

#  Compression. Reduces the amount of data that needs to be transferred over the network
gzip on;
gzip_static on;
gzip_vary on;
gzip_min_length 10240;
gzip_comp_level   6;
gzip_proxied expired no-cache no-store private auth;
gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml;
gzip_disable "MSIE [1-6]\.";
gzip_buffers 16 8k;

#caching settings
fastcgi_cache_path /var/cache/nginx2 levels=1:2 keys_zone=microcache:5m max_size=1000m inactive=30d;
#proxy_cache_path  /var/cache/nginx levels=1:2 keys_zone=czone:4m max_size=50m inactive=30d;
#proxy_temp_path   /var/tmp/nginx;
#proxy_cache_key   "$scheme://$host$request_uri";
#proxy_set_header  Host $host;
#proxy_set_header  X-Real-IP          $remote_addr;
#proxy_set_header  X-Forwarded-Host   $host;
#proxy_set_header  X-Forwarded-Server $host;
#proxy_set_header  X-Forwarded-For    $proxy_add_x_forwarded_for;

#  load config
include /etc/nginx/conf.d/*;
}
EOL

cat > /etc/nginx/exploit.conf<<'EOL'
# #  Anti exploit config for nginx
# #  included in server { } section for domains
# #  source: http://www.howtoforge.com/nginx-how-to-block-exploits-sql-injections-file-injections-spam-user-agents-etc

# #  Block SQL injections
set $block_sql_injections 0;
if ($query_string ~ "union.*select.*\(") {
set $block_sql_injections 1;
}
if ($query_string ~ "union.*all.*select.*") {
set $block_sql_injections 1;
}
if ($query_string ~ "concat.*\(") {
set $block_sql_injections 1;
}
if ($block_sql_injections = 1) {
return 403;
}

# #  Block file injections
set $block_file_injections 0;
if ($query_string ~ "[a-zA-Z0-9_]=http://") {
set $block_file_injections 1;
}
if ($query_string ~ "[a-zA-Z0-9_]=(\.\.//?)+") {
set $block_file_injections 1;
}
if ($query_string ~ "[a-zA-Z0-9_]=/([a-z0-9_.]//?)+") {
set $block_file_injections 1;
}
if ($block_file_injections = 1) {
return 403;
}

# #  Block common exploits
set $block_common_exploits 0;
if ($query_string ~ "(<|%3C).*script.*(>|%3E)") {
set $block_common_exploits 1;
}
if ($query_string ~ "GLOBALS(=|\[|\%[0-9A-Z]{0,2})") {
set $block_common_exploits 1;
}
if ($query_string ~ "_REQUEST(=|\[|\%[0-9A-Z]{0,2})") {
set $block_common_exploits 1;
}
if ($query_string ~ "proc/self/environ") {
set $block_common_exploits 1;
}
if ($query_string ~ "mosConfig_[a-zA-Z_]{1,21}(=|\%3D)") {
set $block_common_exploits 1;
}
if ($query_string ~ "base64_(en|de)code\(.*\)") {
set $block_common_exploits 1;
}
if ($block_common_exploits = 1) {
return 403;
}

# #  Block spam
set $block_spam 0;
if ($query_string ~ "\b(ultram|unicauca|valium|viagra|vicodin|xanax|ypxaieo)\b") {
set $block_spam 1;
}
if ($query_string ~ "\b(erections|hoodia|huronriveracres|impotence|levitra|libido)\b") {
set $block_spam 1;
}
if ($query_string ~ "\b(ambien|blue\spill|cialis|cocaine|ejaculation|erectile)\b") {
set $block_spam 1;
}
if ($query_string ~ "\b(lipitor|phentermin|pro[sz]ac|sandyauer|tramadol|troyhamby)\b") {
set $block_spam 1;
}
if ($block_spam = 1) {
return 403;
}

# #  Block user agents
set $block_user_agents 0;

#  Don't disable wget if you need it to run cron jobs!
# if ($http_user_agent ~ "Wget") {
#     set $block_user_agents 1;
# }

#  Disable Akeeba Remote Control 2.5 and earlier
if ($http_user_agent ~ "Indy Library") {
set $block_user_agents 1;
}

#  Common bandwidth hoggers and hacking tools.
if ($http_user_agent ~ "libwww-perl") {
set $block_user_agents 1;
}
if ($http_user_agent ~ "GetRight") {
set $block_user_agents 1;
}
if ($http_user_agent ~ "GetWeb!") {
set $block_user_agents 1;
}
if ($http_user_agent ~ "Go!Zilla") {
set $block_user_agents 1;
}
if ($http_user_agent ~ "Download Demon") {
set $block_user_agents 1;
}
if ($http_user_agent ~ "Go-Ahead-Got-It") {
set $block_user_agents 1;
}
if ($http_user_agent ~ "TurnitinBot") {
set $block_user_agents 1;
}
if ($http_user_agent ~ "GrabNet") {
set $block_user_agents 1;
}

if ($block_user_agents = 1) {
return 403;
}

# protect .files
location ~ /\. {
access_log        off;
log_not_found     off;
deny  all;
}
EOL

cat > /etc/nginx/cache.conf<<'EOL'
# Setup var defaults
set $no_cache "1";
if ($args ~ "[^|\&]?_mc") {
set $no_cache "0";
}

# If non GET/HEAD, don't cache & mark user as uncacheable for 1 second via cookie
if ($request_method !~ ^(GET|HEAD)$) {
set $no_cache "1";
}

# Drop no cache cookie if need be
# (for some reason, add_header fails if included in prior if-block)
if ($no_cache = "1") {
add_header Set-Cookie "_mcnc=1; Max-Age=2; Path=/";
}

# Bypass cache if no-cache cookie is set
if ($http_cookie ~* "_mcnc") {
set $no_cache "1";
}

#set cache hearder info
add_header X-Microcachable $no_cache;

# Bypass cache if flag is set
fastcgi_no_cache $no_cache;
fastcgi_cache_bypass $no_cache;
fastcgi_cache microcache;
fastcgi_cache_key $server_name|$request_uri;
fastcgi_cache_valid 404 30m;
fastcgi_cache_valid 200 10s;
fastcgi_cache_use_stale updating error timeout invalid_header http_500;
fastcgi_pass_header Set-Cookie;
fastcgi_pass_header Cookie;
fastcgi_ignore_headers Cache-Control Expires Set-Cookie;
EOL

cat > /etc/nginx/conf.d/virtual.conf<<'EOL'
server
{
listen 80;
server_name _;
root /var/www/public/;

# uncomment for debugging
# access_log  /var/log/nginx/access.log  main;

# uncomment to enable buffered access log
# access_log  /var/log/nginx/access.log  main buffer=16k;

client_max_body_size 10M;

#uncomment if you want to rely on custom error pages
#error_page 404 /404.html;
#error_page   500 502 503 504  /50x.html;

include /etc/nginx/exploit.conf;

#enable pass through of php-fpm testing from localhost & nginx status

# force long browser cancing and stop logging
location ~* \.(jpg|jpeg|gif|png|css|js|ico|xml)$ {
access_log        off;
log_not_found     off;
expires           360d;
}

location / {
index index.html index.htm;
}
}
EOL

#starting
echo ""
echo "${txtgrn}* Starting nginx${txtrst}"
service nginx start

# Further tweaks

echo ""
echo "${bldgrn}8) More tweaks${txtrst}"
echo ""

echo "${txtgrn}* Enable more sockets${txtrst}"

cat >> /etc/sysctl.conf<<'EOL'
# Increase system IP port limits to allow for more connections
net.ipv4.ip_local_port_range = 4000 65000
net.ipv4.tcp_window_scaling = 1

# number of packets to keep in backlog before the kernel starts dropping them
net.ipv4.tcp_max_syn_backlog = 3240000

# increase socket listen backlog
net.core.somaxconn = 3240000
net.ipv4.tcp_max_tw_buckets = 1440000

# Increase TCP buffer sizes
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = cubic
EOL
sysctl -p


# Increase the maximum number of file descriptors
fs.file-max = 500000


# Digital Ocean Recommended Settings:
net.core.wmem_max=12582912
net.core.rmem_max=12582912
net.ipv4.tcp_rmem= 10240 87380 12582912
net.ipv4.tcp_wmem= 10240 87380 12582912
