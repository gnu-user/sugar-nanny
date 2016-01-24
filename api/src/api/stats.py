from app import get_db_cursor
from flask import Blueprint
from error import InvalidUsage
from cache import cache
from utils import (success_response,
                   validate_response)

stats = Blueprint('stats', __name__)


@stats.route('/blood_sugar/<account_id>', methods=['GET'])
@cache.memoize()
@validate_response()
def stats_blood_sugar(account_id):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT json_agg(summarize_readings(readings))::jsonb AS response
                    FROM readings
                    WHERE account_id = %s
                    AND reading_timestamp >= (now() - interval '48 hour');
                    ''', (account_id,))
        res = cur.fetchone()['response']
    return success_response({'data': res})


@stats.route('/insulin/<account_id>', methods=['GET'])
@cache.memoize()
@validate_response()
def stats_insulin(account_id):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT json_agg(summarize_doses(doses))::jsonb AS response
                    FROM doses
                    WHERE account_id = %s
                    AND dose_timestamp >= (now() - interval '48 hour');
                    ''', (account_id,))
        res = cur.fetchone()['response']
    return success_response({'data': res})


@stats.route('/meals/<account_id>', methods=['GET'])
@cache.memoize()
@validate_response()
def stats_meals(account_id):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT json_agg(summarize_food_history(food_history))::jsonb AS response
                    FROM food_history
                    WHERE account_id = %s
                    AND food_timestamp >= (now() - interval '48 hour');
                    ''', (account_id,))
        res = cur.fetchone()['response']
    return success_response({'data': res})
