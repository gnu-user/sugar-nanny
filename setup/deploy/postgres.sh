#!/bin/bash


sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

sudo apt-get install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get -y update
sudo apt-get install -y postgresql-contrib-9.4 postgresql-client-9.4 libpq-dev

#pip install psycopg2

# Enable postgres database by default for API instances
#update-rc.d postgresql enable
#service postgresql start

#sudo -u postgres createuser -s root
#createdb root
#sudo -u postgres createuser -s nanny
#createdb nanny

# TODO automate setting up postgres for the desired system account

#for version in /etc/postgresql/*
#do
#    \cp -f $version/main/postgresql.conf $version/main/postgresql.conf.bak
#    \cp -f ../config/postgresql.conf $version/main/
#done
