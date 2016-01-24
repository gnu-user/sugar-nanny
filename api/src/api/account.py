from app import get_db_cursor
from flask import Blueprint
from error import InvalidUsage
from cache import cache
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
@cache.memoize()
@validate_response()
def account_email_available(email):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT email FROM accounts WHERE email = lower(%s)
                    ''', (email,))
        res = cur.fetchone()
        if res is not None:
            raise InvalidUsage('Email not available.',
                               'email_not_available')
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


@account.route('/profile/<account_id>', methods=['GET'])
@cache.memoize()
@validate_response()
def account_profile(account_id):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT json_build_object(
                            'first_name', first_name,
                            'last_name', last_name,
                            'height', height,
                            'weight', weight,
                            'sex', sex,
                            'dob', dob,
                            'email', email,
                            'diabetes_type', diabetes_type,
                            'high_blood_pressure', high_blood_pressure,
                            'pregnant', pregnant,
                            'insulin_tdd', insulin_tdd,
                            'background_dose', background_dose,
                            'pre_meal_target', pre_meal_target,
                            'post_meal_target', post_meal_target,
                            'basal_corr_factor', basal_corr_factor,
                            'bolus_corr_factor', bolus_corr_factor,
                            'grams_carb_per_unit', grams_carb_per_unit)::JSONB
                    AS response
                    FROM accounts
                    WHERE account_id = %s
                    ''', (account_id,))
        account = cur.fetchone()['response']
        if account is None:
            raise InvalidUsage('There are no accounts with '
                               'the provided id.',
                               'account_not_found')
        return success_response({'data': account})
