# services/users/project/api/models.py


from sqlalchemy.sql import func
from project import db, bcrypt
from flask import current_app
import datetime
import jwt


class User(db.Model):

    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(128), unique=True, nullable=False)
    email = db.Column(db.String(128), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    active = db.Column(db.Boolean(), default=True, nullable=False)
    admin = db.Column(db.Boolean(), default=False, nullable=False)
    created_date = db.Column(db.DateTime, default=func.now(), nullable=False)

    def __init__(self, username, email, password, admin=False):
        self.username = username
        self.email = email
        self.password = bcrypt.generate_password_hash(
            password, current_app.config.get("BCRYPT_LOG_ROUNDS")
        ).decode()
        self.admin = admin

    def to_dict(self):
        return {
            "id": self.id,
            "username": self.username,
            "email": self.email,
            "active": self.active,
            "admin": self.admin,
        }

    def to_json(self):
        return self.to_dict()

    def encode_auth_token(self, user_id):
        """Generates the auth token"""
        try:
            # new
            payload = {
                "exp": datetime.datetime.utcnow()
                + datetime.timedelta(
                    days=current_app.config.get("TOKEN_EXPIRATION_DAYS"),
                    seconds=current_app.config.get("TOKEN_EXPIRATION_SECONDS"),
                ),
                "iat": datetime.datetime.utcnow(),
                "sub": user_id,
            }
            secret_key = current_app.config.get("SECRET_KEY")
            return jwt.encode(payload, secret_key, algorithm="HS256")
        except Exception as e:
            return e

    @staticmethod
    def decode_auth_token(token):
        try:
            secret_key = current_app.config.get("SECRET_KEY")
            payload = jwt.decode(token, secret_key, algorithms=["HS256"])
            return payload["sub"]
        except jwt.ExpiredSignatureError:
            return "Signature expired. Please log in again."
        except jwt.InvalidTokenError:
            return "Invalid token. Please log in again."


def add_user(username, email, password):
    user = User(username, email=email, password=password)
    db.session.add(user)
    db.session.commit()
    return user


def add_admin(username, email, password):
    user = User(username=username, email=email, password=password, admin=True)
    db.session.add(user)
    db.session.commit()
    return user


def is_admin(user_id):
    user = User.query.get(user_id)
    return user is not None and user.admin
