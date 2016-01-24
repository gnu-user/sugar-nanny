dropdb sugarnanny
createdb sugarnanny
pg_restore -d sugarnanny openfoodfacts.dump
psql sugarnanny < 0001-schema.sql
psql sugarnanny < 0002-blood_sugar_functions.sql
psql sugarnanny < 9999-data.sql
python2 make-readings.py
