from app import get_db_cursor
from flask import Blueprint
from error import InvalidUsage
from utils import (success_response,
                   validate_response)

history = Blueprint('history', __name__)


@history.route('/blood_sugar/<account_id>', methods=['GET'])
@validate_response()
def history_blood_sugar(account_id):
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
                    ''', (account_id,))
        res = cur.fetchone()['response']
    return success_response({'data': {'results': res}})


@history.route('/insulin/<account_id>', methods=['GET'])
@validate_response()
def history_insulin(account_id):
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
                    ''', (account_id,))
        res = cur.fetchone()['response']
    return success_response({'data': {'results': res}})


@history.route('/meals/<account_id>', methods=['GET'])
@validate_response()
def history_meals(account_id):
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
                    ''', (account_id,))
        res = cur.fetchone()['response']
    return success_response({'data': {'results': res}})
