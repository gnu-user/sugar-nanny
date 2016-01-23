#!/bin/bash

apt-get install -y build-essential emacs vim screen htop httpie nmap curl links netcat \
        mtr lsof pv figlet pigz tcpflow python-pip ipython atool ncdu autoconf \
        ntp python-dev git siege ngrep dtrx dstat multitail lftp rsync elinks \
        iftop iotop sysstat nethogs atop parallel

# Install additional useful CLI tools
pip install glances