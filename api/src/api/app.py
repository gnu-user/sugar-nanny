#!/usr/bin/env python2
from contextlib import contextmanager
from urlparse import urlparse
import logging
from flask import (Flask, jsonify)
import psycopg2
import psycopg2.extras
import traceback
from psycopg2.pool import ThreadedConnectionPool
import pika
import pika_pool
from exceptions import Exception
from error import AuthError, InvalidUsage
from utils import error_response, LOGGER

app = Flask(__name__)
app.config.from_envvar('APP_SETTINGS')

# Initialize connection pools
url = urlparse(app.config['DATABASE_URL'])
pool = ThreadedConnectionPool(1, 20,
                              database=url.path[1:],
                              user=url.username,
                              password=url.password,
                              host=url.hostname,
                              port=url.port)

pika_pool = pika_pool.QueuedPool(
    create=lambda: pika.BlockingConnection(
        parameters=pika.URLParameters('amqp://localhost')),
    max_size=10,
    max_overflow=10,
    timeout=10,
    recycle=3600,
    stale=45,
)


@app.errorhandler(Exception)
def handle_error(e):
    """
    A catch-all error handler that catches any unhandled exception and returns
    an error message to the end user.
    """
    if isinstance(e, AuthError) or isinstance(e, InvalidUsage):
        response = jsonify(e.to_dict())
        response.status_code = e.code
    else:
        LOGGER.error('Internal Error: {}'.format(traceback.format_exc()))
        response = jsonify(error_response('Internal Error',
                                          'internal_error', 500))
        response.status_code = 500
    return response


@contextmanager
def get_db_connection():
    """
    psycopg2 connection context manager.
    Fetch a connection from the connection pool and release it.
    """
    try:
        connection = pool.getconn()
        yield connection
    finally:
        pool.putconn(connection)


@contextmanager
def get_db_cursor(commit=False):
    """
    psycopg2 connection.cursor context manager.
    Creates a new cursor and closes it, commiting changes if specified.
    """
    with get_db_connection() as connection:
        cursor = connection.cursor(
            cursor_factory=psycopg2.extras.RealDictCursor)
        try:
            yield cursor
            if commit:
                connection.commit()
        finally:
            cursor.close()


import account
import food
import stats
import history
import readings

if __name__ == '__main__':
    port = app.config['PORT']
    handler = logging.StreamHandler()
    handler.setLevel(logging.WARNING)
    if not app.debug:
        app.logger.addHandler(handler)
    app.register_blueprint(account.account, url_prefix='/account')
    app.register_blueprint(food.food, url_prefix='/food')
    app.register_blueprint(stats.stats, url_prefix='/stats')
    app.register_blueprint(history.hitory, url_prefix='/history')
    app.register_blueprint(readings.readings, url_prefix='/readings')
    app.run(host='127.0.0.1', port=port)
