from flask.ext.cache import Cache
from utils import from_envvar

config = from_envvar('APP_SETTINGS')

if config['CACHE_TYPE'] == 'redis':
    cache_conf = {'CACHE_TYPE': 'redis',
                  'CACHE_DEFAULT_TIMEOUT': config['CACHE_DEFAULT_TIMEOUT'],
                  'CACHE_REDIS_URL': config['REDIS_URL']}
else:
    cache_conf = {'CACHE_TYPE': config['CACHE_TYPE'],
                  'CACHE_DEFAULT_TIMEOUT': config['CACHE_DEFAULT_TIMEOUT']}

cache = Cache(config=cache_conf)
