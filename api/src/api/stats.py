from app import get_db_cursor
from flask import Blueprint, g
from auth import requires_auth
from error import InvalidUsage
from utils import (success_response,
                   ensure_valid_uuid,
                   validate_response)

stats = Blueprint('stats', __name__)


@stats.route('/blood_sugar/<user_uuid>', methods=['GET'])
@validate_response()
def stats_blood_sugar(user_uuid):
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


@stats.route('/insulin/<user_uuid>', methods=['GET'])
@validate_response()
def stats_insulin(user_uuid):
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


@stats.route('/meals/<user_uuid>', methods=['GET'])
@validate_response()
def stats_meals(user_uuid):
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
