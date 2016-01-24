from app import get_db_cursor
from flask import Blueprint
from error import InvalidUsage
from utils import (success_response,
                   ensure_valid_uuid,
                   validate_request,
                   validate_response,
                   get_request_data)

food = Blueprint('food', __name__)


@food.route('/search/<query>', methods=['GET'])
@validate_response()
def food_search(query):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT search_food(%s) AS response
                    ''', (query,))
        res = cur.fetchone()['response']
    return success_response({'data': {'results': res}})


@food.route('/retrieve/<food_id>', methods=['GET'])
@validate_response()
def food_retrieve(food_id):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT get_food_item(%s) AS response
                    ''', (food_id,))
        res = cur.fetchone()['response']
    return success_response({'data': {'results': res}})

@food.route('/record/<user_id>/<food_id>', methods=['POST'])
@validate_request()
@validate_response()
def food_record(user_id, food_id):
    req = get_request_data()

    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                       SELECT insulin_from_carbs(%s, %s, %s) AS response
                    ''', (user_id, food_id, req['servings'],))
        res = cur.fetchone()['response']
    return success_response({'data': {'results': int(res)}});
