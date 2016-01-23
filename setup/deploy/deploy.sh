#!/bin/bash

set -e

# run this from the setup directory
DIR="$( cd "$( dirname "$0" )" && pwd )"
cd $DIR

shopt -s dotglob
export DOWNLOAD='wget -nc --progress=bar -U "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 (.NET CLR 3.5.30729)"'

./system_update.sh
./packages.sh
./ssh.sh
./motd.sh
./cron.sh
./bash.sh
./adduser.sh nanny
#./node.sh
#./redis.sh
./nginx.sh
./postgres.sh
./flask.sh
#./rabbitmq.sh

# at the end
service ssh restart
