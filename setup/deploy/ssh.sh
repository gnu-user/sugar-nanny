#!/bin/bash

cp -vf ../config/sshd_config /etc/ssh/
cp -vf ../config/authorized_keys ~/.ssh/
chmod 0644 ~/.ssh/authorized_keys

#echo -e 'y\n' | ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa -b 4096
#echo -e 'y\n' | ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa -b 521
