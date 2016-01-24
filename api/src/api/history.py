from app import get_db_cursor
from flask import Blueprint
from error import InvalidUsage
from utils import (success_response,
                   validate_response)

history = Blueprint('history', __name__)


@history.route('/blood_sugar/<user_uuid>', methods=['GET'])
@validate_response()
def history_blood_sugar(user_uuid):
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
                    ''', (user_uuid,))
        res = cur.fetchone()['response']
    return success_response({'data': {'results': res}})


@history.route('/insulin/<user_uuid>', methods=['GET'])
@validate_response()
def history_insulin(user_uuid):
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
                    ''', (user_uuid,))
        res = cur.fetchone()['response']
    return success_response({'data': {'results': res}})


@history.route('/meals/<user_uuid>', methods=['GET'])
@validate_response()
def history_meals(user_uuid):
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
                    ''', (user_uuid,))
        res = cur.fetchone()['response']
    return success_response({'data': {'results': res}})
