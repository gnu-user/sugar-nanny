from exceptions import Exception


class AuthError(Exception):
    def __init__(self, error, status, code=400, headers=None):
        Exception.__init__(self)
        if not isinstance(error, list):
            self.errors = [str(error)]
        else:
            self.errors = error
        self.code = code
        self.status = status
        self.headers = headers

    def to_dict(self):
        resp = {'success': False,
                'code': self.code,
                'errors': self.errors,
                'status': self.status}
        return resp


class InvalidUsage(Exception):
    def __init__(self, error, status, code=400, headers=None, data=dict()):
        Exception.__init__(self)
        if not isinstance(error, list):
            self.errors = [str(error)]
        else:
            self.errors = error
        self.code = code
        self.status = status
        self.headers = headers
        self.data = data

    def to_dict(self):
        resp = {'success': False,
                'code': self.code,
                'errors': self.errors,
                'status': self.status}
        resp.update(self.data)
        return resp
