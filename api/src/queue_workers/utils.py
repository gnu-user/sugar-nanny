import os
import sys
import json
import errno
import types
import logging
from werkzeug.utils import import_string

LOG = logging.getLogger(__name__)


def ensure_env(var, logger=LOG, exit_code=1):
    try:
        os.environ[var]
    except:
        logger.error(json.dumps({'success': False,
                                 'message': 'Unable to retreive environment variable `{}`.'
                                 .format(var)}))
        sys.exit(exit_code)


def from_envvar(variable_name, silent=False):
    """Loads a configuration from an environment variable pointing to
    a configuration file.
    """
    rv = os.environ.get(variable_name)
    if not rv:
        if silent:
            return False
        raise RuntimeError('The environment variable %r is not set '
                           'and as such configuration could not be '
                           'loaded.  Set this variable and make it '
                           'point to a configuration file' %
                           variable_name)
    return from_pyfile(rv, silent=silent)


def from_pyfile(filename, silent=False):
    """Updates the values in the config from a Python file.  This function
    behaves as if the file was imported as a module.
    """
    filename = os.path.join(os.path.dirname(os.path.realpath(__file__)), filename)
    d = types.ModuleType('config')
    d.__file__ = filename
    try:
        with open(filename) as config_file:
            exec(compile(config_file.read(), filename, 'exec'), d.__dict__)
    except IOError as e:
        if silent and e.errno in (errno.ENOENT, errno.EISDIR):
            return False
        e.strerror = 'Unable to load configuration file (%s)' % e.strerror
        raise
    return from_object(d)


def from_object(obj):
    """Updates the values from the given object.  An object can be of one
    of the following two types:
    -   a string: in this case the object with that name will be imported
    -   an actual object reference: that object is used directly
    """
    config = dict()
    if isinstance(obj, (str, unicode)):
        obj = import_string(obj)
    for key in dir(obj):
        if key.isupper():
            config[key] = getattr(obj, key)
    return config
