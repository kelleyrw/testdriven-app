# services/users/project/api/utils.py


from functools import wraps
from flask import request, jsonify
from flask_api import status
from project.api.models import User


def authenticate(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        response_object = {
            "status": "fail",
            "message": "Provide a valid auth token.",
        }
        auth_header = request.headers.get("Authorization")
        if not auth_header:
            return jsonify(response_object), status.HTTP_403_FORBIDDEN
        auth_token = auth_header.split(" ")[1]
        resp = User.decode_auth_token(auth_token)
        if isinstance(resp, str):
            response_object["message"] = resp
            return jsonify(response_object), status.HTTP_401_UNAUTHORIZED
        user = User.query.get(resp)
        if not user or not user.active:
            return jsonify(response_object), status.HTTP_401_UNAUTHORIZED
        return f(resp, *args, **kwargs)

    return decorated_function


def authenticate_restful(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        response_object = {
            "status": "fail",
            "message": "Provide a valid auth token.",
        }
        auth_header = request.headers.get("Authorization")
        if not auth_header:
            return response_object, status.HTTP_403_FORBIDDEN
        auth_token = auth_header.split(" ")[1]
        resp = User.decode_auth_token(auth_token)
        if isinstance(resp, str):
            response_object["message"] = resp
            return response_object, status.HTTP_401_UNAUTHORIZED
        user = User.query.filter_by(id=resp).first()
        if not user or not user.active:
            return response_object, status.HTTP_401_UNAUTHORIZED
        return f(resp, *args, **kwargs)

    return decorated_function
