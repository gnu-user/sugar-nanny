from app import get_db_cursor
from flask import Blueprint
from error import InvalidUsage

from utils import (success_response,
                   ensure_valid_uuid,
                   validate_request,
                   validate_response,
                   get_request_data,
                   LOGGER)

account = Blueprint('account', __name__)


@account.route('/login', methods=['POST'])
@validate_request()
@validate_response()
def account_login():
    req = get_request_data()
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT account_id
                    FROM accounts
                    WHERE email = %(email)s
                    AND password = %(password)s
                    ''', req)
        res = cur.fetchone()
        if res is None:
            raise InvalidUsage('Email not found or password invalid.',
                               'email_or_password_invalid')
        else:
            account_id = res['account_id']

        return success_response({'data': {'account_id': account_id}})


@account.route('/email-available/<email>', methods=['GET'])
@validate_response()
def account_email_available(email):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT email FROM users WHERE email = %s
                    ''', (email,))
        res = cur.fetchone()
        if res is None:
            return success_response({'data': {'available': email}})


@account.route('/signup', methods=['POST'])
@validate_request()
@validate_response()
def account_signup():
    req = get_request_data()
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT
                    account_signup(%(first_name)s, %(last_name)s,
                                   %(height)s, %(weight)s,
                                   %(sex)s, %(dob)s,
                                   %(email)s, %(password)s,
                                   %(diabetes_type)s,
                                   %(high_blood_pressure)s,
                                   %(pregnant)s,
                                   %(insulin_tdd)s,
                                   %(background_dose)s,
                                   %(pre_meal_target)s,
                                   %(post_meal_target)s)
                    AS response
                    ''', req)
        res = cur.fetchone()['response']
        if not res['success']:
            raise InvalidUsage(res['message'], res['status'])
    return success_response({'data': {'account_id': res['account_id']}})


@account.route('/verify/phone/<account_uuid>/<int:phone_code>',
               methods=['GET'])
@validate_response()
def account_phone_verify(account_uuid, phone_code):
    ensure_valid_uuid(account_uuid, 'account UUID')
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT
                    account_verify_phone(%s, %s)
                    AS response
                    ''', (account_uuid, phone_code))
        res = cur.fetchone()['response']
        if not res['success']:
            raise InvalidUsage(res['message'],
                               res['status'])
    return success_response({'data': {'phone_number': res['phone_number']}})


@account.route('/profile/<account_uuid>', methods=['GET'])
@validate_response()
def account_profile(account_uuid):
    ensure_valid_uuid(account_uuid, 'account UUID')
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT account_info_public(accounts) AS account_info
                    FROM accounts
                    WHERE account_uuid = %s
                    ''', (account_uuid,))
        account = cur.fetchone()
        if account is None:
            raise InvalidUsage('There are no accounts with '
                               'the provided UUID.',
                               'account_not_found')
        return success_response({'data': account['account_info']})
