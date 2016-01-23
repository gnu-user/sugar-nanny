#!/bin/bash

pip install redis

pushd ~/build
apt-get install build-essential tcl8.5
unset CFLAGS
$DOWNLOAD http://download.redis.io/releases/redis-2.8.24.tar.gz
tar -xvzf redis-2.8.24.tar.gz

pushd redis-2.8.24/
make && make install
pushd utils
echo -e '12345\n' | ./install_server.sh
echo -e '12347\n' | ./install_server.sh
popd # utils
popd # redis-2.8.24/
popd # ~/build

cp -vf ../config/12345.conf /etc/redis/
service redis_12345 restart

# Separate instance of redis for caching, etc.
cp .-vf ./config/12345.conf /etc/redis/12347.conf
sed 's/12345/12347/g' /etc/redis/12347.conf
service redis_12347 restart

#npm install -g redis-commander

#mkdir -p /root/backups/redis/
