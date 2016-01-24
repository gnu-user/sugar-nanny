from app import get_db_cursor
from flask import Blueprint
from error import InvalidUsage
from utils import (success_response,
                   ensure_valid_uuid,
                   validate_request,
                   validate_response)

food = Blueprint('food', __name__)


@food.route('/search/<query>', methods=['GET'])
@validate_response()
def food_search(query):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT json_agg(summarize_listing(listings))::jsonb AS response
                    FROM listings
                    JOIN favorite_listings
                    USING (listing_id)
                    WHERE favorite_listings.account_id =
                      (SELECT account_id
                       FROM accounts
                       WHERE account_uuid = %s)
                    ''', (query,))
        res = cur.fetchone()['response']
    return success_response({'data': {'results': res}})


@food.route('/retrieve/<food_id>', methods=['GET'])
@validate_response()
def food_retrieve(food_id):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT json_agg(summarize_listing(listings))::jsonb AS response
                    FROM listings
                    JOIN favorite_listings
                    USING (listing_id)
                    WHERE favorite_listings.account_id =
                      (SELECT account_id
                       FROM accounts
                       WHERE account_uuid = %s)
                    ''', (food_id,))
        res = cur.fetchone()['response']
    return success_response({'data': {'results': res}})


@food.route('/record/<user_id>/<food_id>', methods=['POST'])
@validate_request()
@validate_response()
def food_record(user_id, food_id):
    with get_db_cursor(commit=True) as cur:
        cur.execute('''
                    SELECT json_agg(summarize_listing(listings))::jsonb AS response
                    FROM listings
                    JOIN favorite_listings
                    USING (listing_id)
                    WHERE favorite_listings.account_id =
                      (SELECT account_id
                       FROM accounts
                       WHERE account_uuid = %s)
                    ''', (user_id,))
        res = cur.fetchone()['response']
    return success_response()
