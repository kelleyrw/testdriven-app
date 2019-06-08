# services/users/project/api/users.py

from sqlalchemy import exc
from flask import Blueprint, request, render_template
from flask_restful import Resource, Api
from flask_api import status
from project import db
from project.api.models import User, is_admin
from project.api.util import authenticate_restful


users_blueprint = Blueprint("users", __name__, template_folder="./templates")
api = Api(users_blueprint)


class UsersPing(Resource):
    @staticmethod
    def get():
        return {"status": "success", "message": "pong!"}


@users_blueprint.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        username = request.form["username"]
        email = request.form["email"]
        password = request.form["password"]
        db.session.add(User(username=username, email=email, password=password))
        db.session.commit()
    users = User.query.all()
    return render_template("index.html", users=users)


class UsersList(Resource):

    method_decorators = {"post": [authenticate_restful]}

    @staticmethod
    def post(resp):
        post_data = request.get_json()
        response_object = {"status": "fail", "message": "Invalid payload."}
        if not is_admin(resp):
            response_object[
                "message"
            ] = "You do not have permission to do that."
            return response_object, status.HTTP_401_UNAUTHORIZED
        if not post_data:
            return response_object, status.HTTP_400_BAD_REQUEST
        username = post_data.get("username")
        email = post_data.get("email")
        password = post_data.get("password")
        try:
            user = User.query.filter_by(email=email).first()
            if not user:
                db.session.add(
                    User(username=username, email=email, password=password)
                )
                db.session.commit()
                response_object["status"] = "success"
                response_object["message"] = f"{email} was added!"
                return response_object, status.HTTP_201_CREATED
            else:
                response_object["message"] = "That email already exists."
                return response_object, status.HTTP_400_BAD_REQUEST
        except (exc.IntegrityError, ValueError):
            db.session.rollback()
            return response_object, status.HTTP_400_BAD_REQUEST

        except exc.IntegrityError:
            db.session.rollback()
            return response_object, status.HTTP_400_BAD_REQUEST

    @staticmethod
    def get():
        """Get all users"""
        response_object = {
            "status": "success",
            "data": {"users": [user.to_json() for user in User.query.all()]},
        }
        return response_object, status.HTTP_200_OK


class Users(Resource):
    @staticmethod
    def get(user_id):
        """Get single user details"""
        user = User.query.get(user_id)
        response_object = {
            "status": "success",
            "data": {
                "id": user.id,
                "username": user.username,
                "email": user.email,
                "active": user.active,
            },
        }
        return response_object, status.HTTP_200_OK

    @staticmethod
    def delete(user_id):
        """Get single user details"""
        user = User.query.get(user_id)
        if user:
            db.session.delete(user)
            db.session.commit()
            response_object = {"status": f"successfully deleted user {user_id}"}
            return response_object, status.HTTP_202_ACCEPTED
        else:
            response_object = {"message": f"User {user_id} doesn" "t exist."}
            return response_object, status.HTTP_404_NOT_FOUND


api.add_resource(UsersPing, "/users/ping")
api.add_resource(UsersList, "/users")
api.add_resource(Users, "/users/<int:user_id>")
