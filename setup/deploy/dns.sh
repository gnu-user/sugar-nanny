#!/bin/bash

sudo apt-get install -y dnsmasq
echo "nameserver 127.0.0.1" >> /etc/resolvconf/resolv.conf.d/head
cp -vf ../config/dnsmasq.conf /etc/
cp -vf ../config/dhclient.conf /etc/dhcp/
# make changes take affect now
sudo /etc/init.d/dnsmasq restart
(tmpfile=`mktemp` && { echo "nameserver 127.0.0.1" | cat - /etc/resolv.conf > $tmpfile && mv $tmpfile /etc/resolv.conf; } )
