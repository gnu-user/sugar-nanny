#!/bin/bash

cp -vf ../config/common-session /etc/pam.d/
cp -vf ../config/vimrc /etc/
cp -vf ../config/limits.conf /etc/security/
cp -vf ../config/sysctl.conf /etc/

sysctl -p
