USER=$1
PASS=$2
HOST=$3

if [[ -n "${USER}" && -n "${PASS}" && -n "${HOST}" ]]
then
    PGPASSWORD=${PASS} dropdb -U${USER} -h ${HOST} sugarnanny
    PGPASSWORD=${PASS} createdb -U${USER} -h ${HOST} sugarnanny
    PGPASSWORD=${PASS} pg_restore -U${USER} -h ${HOST} -d sugarnanny openfoodfacts.dump
    PGPASSWORD=${PASS} psql -U${USER} -h ${HOST} sugarnanny < 0001-schema.sql
    PGPASSWORD=${PASS} psql -U${USER} -h ${HOST} sugarnanny < 0002-blood_sugar_functions.sql
    PGPASSWORD=${PASS} psql -U${USER} -h ${HOST} sugarnanny < 0003-account-functions.sql
    PGPASSWORD=${PASS} psql -U${USER} -h ${HOST} sugarnanny < 0004-food_functions.sql
    PGPASSWORD=${PASS} psql -U${USER} -h ${HOST} sugarnanny < 0005-stats-functions.sql
    PGPASSWORD=${PASS} psql -U${USER} -h ${HOST} sugarnanny < 9999-data.sql
    python2 generate-data.py ${USER} ${PASS} ${HOST}
else
    dropdb sugarnanny
    createdb sugarnanny
    pg_restore -d sugarnanny openfoodfacts.dump
    psql sugarnanny < 0001-schema.sql
    psql sugarnanny < 0002-blood_sugar_functions.sql
    psql sugarnanny < 0003-account-functions.sql
    psql sugarnanny < 0004-food_functions.sql
    psql sugarnanny < 0005-stats-functions.sql
    psql sugarnanny < 9999-data.sql
    python2 generate-data.py
fi
