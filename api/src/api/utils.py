from jsonschema import Draft4Validator, RefResolver
from werkzeug.utils import secure_filename
from werkzeug.local import LocalProxy
from functools import wraps
from flask import jsonify, request, current_app
from uuid import uuid4
import inspect
import boto3
import json
import copy
import os
import re
from error import InvalidUsage

LOGGER = LocalProxy(lambda: current_app.logger)
UUID_V4_REGEX = ("^[a-fA-F0-9]{8}"
                 "-[a-fA-F0-9]{4}"
                 "-[a-fA-F0-9]{4}"
                 "-[a-fA-F0-9]{4}"
                 "-[a-fA-F0-9]{12}$")
IMAGE_EXTENSIONS = ['png', 'jpg', 'jpeg']
IMAGE_MIME_TYPES = {'png': 'image/png',
                    'jpg': 'image/jpeg',
                    'jpeg': 'image/jpeg'}


def valid_image(filename):
    return ('.' in filename and
            (os.path.splitext(filename)[1][1:]).lower() in IMAGE_EXTENSIONS)


def ensure_valid_uuid(uuid, uuid_object=None):
    if re.match(UUID_V4_REGEX, uuid) is None:
        if uuid_object is None:
            raise InvalidUsage('Invalid UUID format.',
                               'invalid_uuid_format')
        else:
            reduced = (re.sub('[^A-Za-z0-9]+', '_', uuid_object)
                       .strip('_')
                       .lower())
            raise InvalidUsage('Invalid {} format.'.format(uuid_object),
                               'invalid_{}_format'.format(reduced))


def ensure_valid_int(num, int_name=None):
    try:
        num = int(num)
    except:
        if int_name is None:
            raise InvalidUsage('Invalid integer format.',
                               'invalid_integer_format')
        else:
            reduced = (re.sub('[^A-Za-z0-9]+', '_', int_name)
                       .strip('_')
                       .lower())
            raise InvalidUsage('Invalid {} format.'.format(int_name),
                               'invalid_{}_format'.format(reduced))


def calling_function():
    return inspect.stack()[2][3]


def get_draft4_validator(schema_path):
    abs_path = os.path.abspath(schema_path)
    print abs_path
    with open(abs_path) as schema_file:
        schema = json.load(schema_file)
    resolver = RefResolver("file://" + abs_path, schema)
    return Draft4Validator(schema, resolver=resolver)


def json_validate(schema, value):
    validator = Draft4Validator(schema)
    try:
        validator.validate(value)
        return (True, None)
    except:
        pass

    errors = [e.message for e in validator.iter_errors(value)]
    return (False, errors)


def ensure_valid_json(schema, value):
    valid, errors = json_validate(schema, value)
    if not valid:
        raise InvalidUsage(errors, 'request_format_error')


def validate_json(validator, value):
    try:
        validator.validate(value)
    except:
        errors = [e.message for e in validator.iter_errors(value)]
        raise InvalidUsage(errors, 'request_format_error')


def get_request_schema():
    with open('../../json/schemas/requests/{}.json'
              .format(calling_function())) as source:
        return(json.loads(source.read()))


def get_response_schema():
    with open('../../json/schemas/responses/{}.json'
              .format(calling_function())) as source:
        return(json.loads(source.read()))


def get_object_schema(name):
    with open('../../json/schemas/objects/{}.json'
              .format(name)) as source:
        return(json.loads(source.read()))


# TODO error handling, should throw a 400 error if we fail to upload image
def s3_upload(source_file, filename, acl='public-read', bucket='sesh-images'):
    source_filename = secure_filename(filename)
    source_extension = (os.path.splitext(source_filename)[1][1:]).lower()

    uuid = str(uuid4())
    destination_filename = uuid + '.' + source_extension

    # Connect to S3 and upload file.
    s3 = boto3.resource('s3')
    (s3
     .Object(bucket, destination_filename)
     .put(Body=source_file,
          ContentType=IMAGE_MIME_TYPES[source_extension],
          ACL=acl))

    return (uuid, bucket, destination_filename)


def account_image_upload_and_link(cur, data, filename, account_uuid,
                                  category, title, description):
    uuid, bucket, filename = s3_upload(data, filename)
    req = {'image_uuid': uuid,
           'account_uuid': account_uuid,
           'category': category,
           'filename': filename,
           'bucket': bucket,
           'title': title,
           'description': description}
    cur.execute('''
                SELECT account_upload_image(%(image_uuid)s,
                                            %(account_uuid)s,
                                            %(category)s,
                                            %(filename)s,
                                            %(bucket)s,
                                            %(title)s,
                                            %(description)s) AS response
                ''', req)
    res = cur.fetchone()['response']
    LOGGER.info("S3 UPLOAD: {}".format(req))
    if not res['success']:
        raise InvalidUsage(res['message'],
                           res['status'])
    resp = {'image_url': res['image_url'],
            'image_uuid': res['image_uuid']}
    return resp


def error_response(error, status, code=400):
    if not isinstance(error, list):
        error = [str(error)]
    resp = {'success': False,
            'code': code,
            'status': status,
            'errors': error}
    return resp


def success_response(data=dict(), code=200):
    resp = {'success': True,
            'code': code,
            'status': 'success'}
    resp.update(data)
    return resp


def get_request_data(required=True):
    data = request.get_json()
    if data is None:
        try:
            data = json.loads(request.form['data'])
        except:
            if required:
                raise InvalidUsage('Missing request data.',
                                   'missing_data')
    return data


def validate_request(required=True):
    def wrapper(f):
        @wraps(f)
        def wrapped(*args, **kwargs):
            validator = get_draft4_validator(
                '../../json/schemas/requests/{}.json'
                .format(f.__name__))
            # Handle requests for HTTP and Websockets
            try:
                data = get_request_data(required)
                if data is not None:
                    validate_json(validator, data)
            except InvalidUsage as e:
                if args is None or not args:
                    raise e
                else:
                    validate_json(validator, *args)
            return f(*args, **kwargs)
        return wrapped
    return wrapper


def validate_response():
    def wrapper(f):
        @wraps(f)
        def wrapped(*args, **kwargs):
            validator = get_draft4_validator(
                '../../json/schemas/responses/{}.json'
                .format(f.__name__))
            res = f(*args, **kwargs)
            if not isinstance(res, dict):
                LOGGER.info('Expected `dict` as return type from function {}.'
                            .format(f.__name__))
            try:
                validator.validate(res)
            except:
                errors = [e.message for e in validator.iter_errors(res)]
                LOGGER.error('Invalid JSON schema constructed. Errors: {}'
                             .format(json.dumps(errors)))
            resp = jsonify(res)
            if 'code' in res:
                resp.status_code = res['code']
            return resp
        return wrapped
    return wrapper


def subdict(dict, *keys):
    return {key: dict[key] for key in keys}


def dict_transplant(dict, target_key, source_keys, deep_copy=False):
    if deep_copy:
        dict = copy.deepcopy(dict)
    else:
        dict = dict.copy()
    for key in source_keys:
        dict[target_key][key] = dict[key]
        del dict[key]
    return dict
