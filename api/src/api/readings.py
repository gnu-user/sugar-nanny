from app import get_db_cursor
from flask import Blueprint
from error import InvalidUsage
from cache import cache
from utils import (success_response,
                   validate_response,
                   get_request_data,
                   LOGGER)

readings = Blueprint('readings', __name__)


@readings.route('/blood_sugar/<account_id>/<reading>', methods=['GET'])
@cache.memoize()
@validate_response()
def readings_blood_sugar(account_id, reading):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    INSERT INTO readings(account_id, reading)
                    VALUES (%s, %s)
                    ''', (account_id, reading))
    return success_response()


@readings.route('/insulin/<account_id>/<units>', methods=['GET'])
@cache.memoize()
@validate_response()
def readings_insulin(account_id, units):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    INSERT INTO doses(account_id, dose_units)
                    VALUES (%s, %s)
                    ''', (account_id, units))
    return success_response()
