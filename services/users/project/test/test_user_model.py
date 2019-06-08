# services/users/project/tests/test_user_model.py


import unittest

from project import db
from project.api.models import User, add_user
from project.test.base import BaseTestCase

from sqlalchemy.exc import IntegrityError


class TestUserModel(BaseTestCase):
    """
    Test class for Testing User Objects
    """

    def test_add_user(self):
        user = add_user(
            username="justatest", email="test@test.com", password="foo"
        )
        self.assertTrue(user.id)
        self.assertEqual(user.username, "justatest")
        self.assertEqual(user.email, "test@test.com")
        self.assertTrue(user.password)
        self.assertTrue(user.active)
        self.assertFalse(user.admin)

    def test_add_user_duplicate_username(self):
        user = add_user(
            username="justatest", email="test@test.com", password="foo"
        )
        duplicate_user = User(
            username=user.username, email="test@test2.com", password="foo"
        )
        db.session.add(duplicate_user)
        self.assertRaises(IntegrityError, db.session.commit)

    def test_add_user_duplicate_email(self):
        user = add_user(
            username="justatest", email="test@test.com", password="foo"
        )
        duplicate_user = User(
            username="justanothertest", email=user.email, password="foo"
        )
        db.session.add(duplicate_user)
        self.assertRaises(IntegrityError, db.session.commit)

    def test_to_json(self):
        user = add_user(
            username="justatest", email="test@test.com", password="foo"
        )
        self.assertTrue(isinstance(user.to_json(), dict))

    def test_passwords_are_random(self):
        user_one = add_user("justatest", "test@test.com", "greaterthaneight")
        user_two = add_user("justatest2", "test@test2.com", "greaterthaneight")
        self.assertNotEqual(user_one.password, user_two.password)

    def test_encode_auth_token(self):
        user = add_user("justatest", "test@test.com", "test")
        auth_token = user.encode_auth_token(user.id)
        self.assertTrue(isinstance(auth_token, bytes))

    def test_decode_auth_token(self):
        user = add_user("justatest", "test@test.com", "test")
        token = user.encode_auth_token(user.id)
        self.assertEqual(user.id, User.decode_auth_token(token))


if __name__ == "__main__":
    unittest.main()
