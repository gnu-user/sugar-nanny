#!/bin/bash

pushd ~/build
$DOWNLOAD http://nodejs.org/dist/v0.10.33/node-v0.10.33.tar.gz
tar -xvzf node-v0.10.33.tar.gz
pushd node-v0.10.33/
apt-get install -y python g++ make checkinstall
export CFLAGS="-O3 -march=native -Wall"
./configure && make && make install
popd # node-v0.10.33/
popd # ~/build
