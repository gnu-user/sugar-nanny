from app import get_db_cursor, app
from flask import Blueprint
from external_jobs import request_phone_confirm
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
                    SELECT user_id
                    FROM users
                    WHERE email = %(email)s
                    AND password = %(password)s
                    ''', req)
        res = cur.fetchone()
        if res is None:
            raise InvalidUsage('Email not found or password invalid.',
                               'email_or_password_invalid')
        else:
            user_id = res['user_id']

    return success_response({'data': {'user_id': user_id}})


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
                    account_signup (%(account_type)s, %(email)s, %(password)s,
                                    %(first_name)s, %(last_name)s,
                                    %(email)s, %(phone_number)s,
                                    %(bio)s, %(latitude)s, %(longitude)s,
                                    %(facebook_user_id)s)
                    AS response
                    ''', req)
        res = cur.fetchone()['response']
        if not res['success']:
            raise InvalidUsage(res['message'], res['status'])
        cur.execute('''
                    SELECT row_to_json(accounts) as account_info
                    FROM accounts
                    WHERE account_id = %(account_id)s
                    ''', res)
        account = cur.fetchone()['account_info']
        request_phone_confirm(app.config['QUEUE_PREFIX'], account)

        errors = []
    resp = success_response({'data': {'account_uuid': account['account_uuid']}})
    if len(errors) > 0:
        resp['errors'] = errors
    return resp


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
