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
        user = add_user(username="justatest", email="test@test.com")
        self.assertTrue(user.id)
        self.assertEqual(user.username, "justatest")
        self.assertEqual(user.email, "test@test.com")
        self.assertTrue(user.active)

    def test_add_user_duplicate_username(self):
        user = add_user(username="justatest", email="test@test.com")
        duplicate_user = User(username=user.username, email="test@test2.com")
        db.session.add(duplicate_user)
        self.assertRaises(IntegrityError, db.session.commit)

    def test_add_user_duplicate_email(self):
        user = add_user(username="justatest", email="test@test.com")
        duplicate_user = User(username="justanothertest", email=user.email)
        db.session.add(duplicate_user)
        self.assertRaises(IntegrityError, db.session.commit)

    def test_to_json(self):
        user = add_user(username="justatest", email="test@test.com")
        self.assertTrue(isinstance(user.to_json(), dict))


if __name__ == "__main__":
    unittest.main()
