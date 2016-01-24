from app import get_db_cursor
from flask import Blueprint
from error import InvalidUsage
from cache import cache
from utils import (success_response,
                   ensure_valid_uuid,
                   validate_request,
                   validate_response)

food = Blueprint('food', __name__)


@food.route('/search/<query>', methods=['GET'])
@food.route('/search/<query>/<results>', methods=['GET'])
@cache.memoize()
@validate_response()
def food_search(query, results=10):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT food_search(%s, %s) AS response
                    ''', (query, results))
        res = cur.fetchone()['response']
    return success_response({'data': res})


@food.route('/retrieve/<food_id>', methods=['GET'])
@cache.memoize()
@validate_response()
def food_retrieve(food_id):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT get_food_item(%s) AS response
                    ''', (food_id,))
        res = cur.fetchone()['response']
    return success_response({'data': res})


@food.route('/calculate/<account_id>/<food_id>/<servings>', methods=['GET'])
@cache.memoize()
@validate_response()
def food_calculate(account_id, food_id, servings):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT round(food_insulin_units_required(%s, %s, %s), 1)
                    AS response
                    ''', (account_id, food_id, servings))
        res = cur.fetchone()['response']
    return success_response({'data': {'units': res}})


@food.route('/record/<account_id>/<food_id>/<servings>', methods=['GET'])
@cache.memoize()
@validate_response()
def food_record(account_id, food_id, servings):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    INSERT INTO food_history(account_id, food_id, food_servings)
                    VALUES (%s, %s, %s)
                    ''', (account_id, food_id, servings))
    return success_response()
