USER=$1
PASS=$2
HOST=$3

if [[ -n "${USER}" && -n "${PASS}" && -n "${HOST}" ]]
then
    export PGPASSWORD=sugarrush987
    dropdb -U${USER} --password ${PASS} -h ${HOST} sugarnanny
    createdb -U${USER} --password ${PASS} -h ${HOST} sugarnanny
    pg_restore -U${USER} --password ${PASS} -h ${HOST} -d sugarnanny openfoodfacts.dump
    psql -U${USER} --password ${PASS} -h ${HOST} sugarnanny < 0001-schema.sql
    psql -U${USER} --password ${PASS} -h ${HOST} sugarnanny < 0002-blood_sugar_functions.sql
    psql -U${USER} --password ${PASS} -h ${HOST} sugarnanny < 0003-account-functions.sql
    psql -U${USER} --password ${PASS} -h ${HOST} sugarnanny < 9999-data.sql
    python2 make-readings.py ${USER} ${PASS} ${HOST}
else
    dropdb -U${USER} --password ${PASS} -h ${HOST} sugarnanny
    createdb sugarnanny
    pg_restore -d sugarnanny openfoodfacts.dump
    psql sugarnanny < 0001-schema.sql
    psql sugarnanny < 0002-blood_sugar_functions.sql
    psql sugarnanny < 0003-account-functions.sql
    psql sugarnanny < 9999-data.sql
    python2 make-readings.py
fi