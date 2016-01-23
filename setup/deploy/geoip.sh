#!/bin/bash

# Assumes schema and tables already exist

set -e

if [ "$#" -ne 1 ]; then
    echo "usage: ./load.sh <db-name>"
    exit 1
fi

DBNAME="$1"

BASE_URL='http://geolite.maxmind.com/download/geoip/database/'
CITY_FILE='GeoLite2-City-CSV.zip'
COUNTRY_FILE='GeoLite2-Country-CSV.zip'

SCHEMA='geoip'

rm -rf /tmp/geoip
mkdir -p /tmp/geoip
pushd /tmp/geoip
wget "${BASE_URL}${CITY_FILE}"
aunpack $CITY_FILE
rm -f $CITY_FILE
wget "${BASE_URL}${COUNTRY_FILE}"
aunpack $COUNTRY_FILE
rm -f $COUNTRY_FILE
chmod -R a+rX .

psql $DBNAME -c "COPY geoip.city_blocks FROM '$(realpath */GeoLite2-City-Blocks-IPv4.csv)' DELIMITER ',' CSV HEADER;"
psql $DBNAME -c "COPY geoip.city_blocks FROM '$(realpath */GeoLite2-City-Blocks-IPv6.csv)' DELIMITER ',' CSV HEADER;"
psql $DBNAME -c "COPY geoip.city_locations FROM '$(realpath */GeoLite2-City-Locations-en.csv)' DELIMITER ',' CSV HEADER;"
psql $DBNAME -c "COPY geoip.country_blocks FROM '$(realpath */GeoLite2-Country-Blocks-IPv4.csv)' DELIMITER ',' CSV HEADER;"
psql $DBNAME -c "COPY geoip.country_blocks FROM '$(realpath */GeoLite2-Country-Blocks-IPv6.csv)' DELIMITER ',' CSV HEADER;"
psql $DBNAME -c "COPY geoip.country_locations FROM '$(realpath */GeoLite2-Country-Locations-en.csv)' DELIMITER ',' CSV HEADER;"
