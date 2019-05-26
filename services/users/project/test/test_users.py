# services/users/project/tests/test_users.py


import json
import unittest
from flask_api import status

from project.test.base import BaseTestCase
from project.api.models import User
from project import db


def add_user(username, email):
    user = User(username=username, email=email)
    db.session.add(user)
    db.session.commit()
    return user

class TestUserService(BaseTestCase):
    """Tests for the Users Service."""

    def test_users(self):
        """Ensure the /ping route behaves correctly."""
        response = self.client.get('/users/ping')
        data = json.loads(response.data.decode())
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('pong!', data['message'])
        self.assertIn('success', data['status'])

    def test_add_user(self):
        """Ensure a new user can be added to the database."""

        with self.client:
            response = self.client.post(
                    '/users',
                    data=json.dumps({
                        'username': 'michael',
                        'email': 'michael@mherman.org'
                    }),
                    content_type='application/json',
            )
            data = json.loads(response.data.decode())
            self.assertEqual(response.status_code, status.HTTP_201_CREATED)
            self.assertIn('michael@mherman.org was added!', data['message'])
            self.assertIn('success', data['status'])

    def test_add_user_invalid_json(self):
        """Ensure error is thrown if the JSON object is empty."""
        with self.client:
            response = self.client.post(
                    '/users',
                    data=json.dumps({}),
                    content_type='application/json',
            )
            data = json.loads(response.data.decode())
            self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
            self.assertIn('Invalid payload.', data['message'])
            self.assertIn('fail', data['status'])

    def test_add_user_invalid_json_keys(self):
        """
        Ensure error is thrown if the JSON object does not have a username key.
        """
        with self.client:
            response = self.client.post(
                    '/users',
                    data=json.dumps({'email': 'michael@mherman.org'}),
                    content_type='application/json',
            )
            data = json.loads(response.data.decode())
            self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
            self.assertIn('Invalid payload.', data['message'])
            self.assertIn('fail', data['status'])

    def test_add_user_duplicate_email(self):
        """Ensure error is thrown if the email already exists."""
        with self.client:
            self.client.post(
                    '/users',
                    data=json.dumps({
                        'username': 'michael',
                        'email': 'michael@mherman.org'
                    }),
                    content_type='application/json',
            )
            response = self.client.post(
                    '/users',
                    data=json.dumps({
                        'username': 'michael',
                        'email': 'michael@mherman.org'
                    }),
                    content_type='application/json',
            )
            data = json.loads(response.data.decode())
            self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
            self.assertIn(
                    'Sorry. That email already exists.', data['message'])
            self.assertIn('fail', data['status'])

    def test_single_user(self):
        """Ensure get single user behaves correctly."""
        user = add_user(username='michael', email='michael@mherman.org')
        with self.client:
            response = self.client.get(f'/users/{user.id}')
            data = json.loads(response.data.decode())
            self.assertEqual(response.status_code, status.HTTP_200_OK)
            self.assertIn('michael', data['data']['username'])
            self.assertIn('michael@mherman.org', data['data']['email'])
            self.assertIn('success', data['status'])

    def test_all_users(self):
        """Ensure get all users behaves correctly."""
        add_user('Ryan', 'ryan@foo.com')
        add_user('Randy','randy@foo.com')
        with self.client:
            response = self.client.get('/users')
            data = json.loads(response.data.decode())
            self.assertEqual(response.status_code, 200)
            self.assertEqual(len(data['data']['users']), 2)
            self.assertIn('Ryan', data['data']['users'][0]['username'])
            self.assertIn('ryan@foo.com', data['data']['users'][0]['email'])
            self.assertIn('Randy', data['data']['users'][1]['username'])
            self.assertIn('randy@foo.com', data['data']['users'][1]['email'])
            self.assertIn('success', data['status'])


if __name__ == '__main__':
    unittest.main()
