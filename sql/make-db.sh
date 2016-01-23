createdb sugarnanny
pg_restore -d sugarnanny openfoodfacts.dump
psql sugarnanny < 0001-schema.sql
psql sugarnanny < 9999-data.sql
python make-readings.py
