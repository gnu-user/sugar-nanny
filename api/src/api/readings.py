from app import get_db_cursor
from flask import Blueprint
from error import InvalidUsage

from utils import (success_response,
                   validate_request,
                   validate_response,
                   get_request_data,
                   LOGGER)

readings = Blueprint('readings', __name__)


@readings.route('/blood_sugar/<user_uuid>', methods=['POST'])
@validate_request()
@validate_response()
def readings_blood_sugar():
    req = get_request_data()
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT response
                    FROM account_login(%(login)s)
                    ''', req)
        res = cur.fetchone()
        if res is None:
            raise InvalidUsage('Email or username not found.',
                               'email_or_username_not_found')
        else:
            valid = res['response']
        if not valid:
            raise InvalidUsage('Invalid password.', 'invalid_password')

    return success_response()


@readings.route('/insulin/<user_uuid>', methods=['POST'])
@validate_request()
@validate_response()
def readings_insulin():
    req = get_request_data()
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT response
                    FROM account_login(%(login)s)
                    ''', req)
        res = cur.fetchone()
        if res is None:
            raise InvalidUsage('Email or username not found.',
                               'email_or_username_not_found')
        else:
            valid = res['response']
        if not valid:
            raise InvalidUsage('Invalid password.', 'invalid_password')

    return success_response()
