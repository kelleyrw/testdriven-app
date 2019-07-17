# services/users/project/tests/test_users.py


import json
import unittest
from flask_api import status

from project.test.base import BaseTestCase
from project.api.models import User, add_admin, add_user
from project import db


def get_header(client, as_admin):
    create_user_func = add_admin if as_admin else add_user
    create_user_func("test", "test@test.com", "test")
    resp_login = client.post(
        "/auth/login",
        data=json.dumps({"email": "test@test.com", "password": "test"}),
        content_type="application/json",
    )
    token = json.loads(resp_login.data.decode())["auth_token"]
    return {"Authorization": f"Bearer {token}"}


class TestUserService(BaseTestCase):
    """Tests for the Users Service."""

    def test_users(self):
        """Ensure the /ping route behaves correctly."""
        response = self.client.get("/users/ping")
        data = json.loads(response.data.decode())
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("pong!", data["message"])
        self.assertIn("success", data["status"])

    def test_add_user(self):
        """Ensure a new user can be added to the database."""

        with self.client:
            response = self.client.post(
                "/users",
                data=json.dumps(
                    {
                        "username": "michael",
                        "email": "michael@mherman.org",
                        "password": "greaterthaneight",
                    }
                ),
                content_type="application/json",
                headers=get_header(self.client, as_admin=True),
            )
            data = json.loads(response.data.decode())
            self.assertEqual(response.status_code, status.HTTP_201_CREATED)
            self.assertIn("michael@mherman.org was added!", data["message"])
            self.assertIn("success", data["status"])

    def test_add_user_invalid_json(self):
        """Ensure error is thrown if the JSON object is empty."""
        with self.client:
            response = self.client.post(
                "/users",
                data=json.dumps({}),
                content_type="application/json",
                headers=get_header(self.client, as_admin=True),
            )
            data = json.loads(response.data.decode())
            self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
            self.assertIn("Invalid payload.", data["message"])
            self.assertIn("fail", data["status"])

    def test_add_user_invalid_json_keys(self):
        """
        Ensure error is thrown if the JSON object does not have a username key.
        """
        with self.client:
            response = self.client.post(
                "/users",
                data=json.dumps({"email": "michael@mherman.org"}),
                content_type="application/json",
                headers=get_header(self.client, as_admin=True),
            )
            data = json.loads(response.data.decode())
            self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
            self.assertIn("Invalid payload.", data["message"])
            self.assertIn("fail", data["status"])

    def test_add_user_duplicate_email(self):
        """Ensure error is thrown if the email already exists."""
        with self.client:
            headers = get_header(self.client, as_admin=True)
            self.client.post(
                "/users",
                data=json.dumps(
                    {
                        "username": "michael",
                        "email": "michael@mherman.org",
                        "password": "greaterthaneight",
                    }
                ),
                content_type="application/json",
                headers=headers,
            )
            response = self.client.post(
                "/users",
                data=json.dumps(
                    {
                        "username": "Ryan",
                        "email": "michael@mherman.org",
                        "password": "greaterthaneight",
                    }
                ),
                content_type="application/json",
                headers=headers,
            )
            data = json.loads(response.data.decode())
            self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
            self.assertIn("That email already exists.", data["message"])
            self.assertIn("fail", data["status"])

    def test_single_user(self):
        """Ensure get single user behaves correctly."""
        user = add_user(
            username="michael", email="michael@mherman.org", password="test"
        )
        with self.client:
            response = self.client.get(f"/users/{user.id}")
            data = json.loads(response.data.decode())
            self.assertEqual(response.status_code, status.HTTP_200_OK)
            self.assertIn("michael", data["data"]["username"])
            self.assertIn("michael@mherman.org", data["data"]["email"])
            self.assertIn("success", data["status"])

    def test_all_users(self):
        """Ensure get all users behaves correctly."""
        add_user("Ryan", "ryan@foo.com", "number7")
        add_user("Randy", "randy@foo.com", "number2")
        with self.client:
            response = self.client.get("/users")
            data = json.loads(response.data.decode())
            self.assertEqual(response.status_code, 200)
            self.assertEqual(len(data["data"]["users"]), 2)
            self.assertIn("Ryan", data["data"]["users"][0]["username"])
            self.assertIn("ryan@foo.com", data["data"]["users"][0]["email"])
            self.assertTrue(data["data"]["users"][0]["active"])
            self.assertFalse(data["data"]["users"][0]["admin"])
            self.assertIn("Randy", data["data"]["users"][1]["username"])
            self.assertIn("randy@foo.com", data["data"]["users"][1]["email"])
            self.assertIn("success", data["status"])
            self.assertTrue(data["data"]["users"][1]["active"])
            self.assertFalse(data["data"]["users"][1]["admin"])

    def test_delete_user(self):
        """Ensure error is thrown if the email already exists."""
        user = add_user(
            username="XXX-to-delete", email="bogus@foo.com", password="foo"
        )
        with self.client:
            response = self.client.delete(f"/users/{user.id}")
            self.assertEqual(response.status_code, 202)

            # ensure user is gone
            self.assertIsNone(User.query.get(user.id))

    def test_delete_user_doesnt_exist(self):
        """Ensure error is thrown if the email already exists."""
        with self.client:
            response = self.client.delete(f"/users/77777777")
            self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_add_user_invalid_json_keys_no_password(self):
        """
        Ensure error is thrown if the JSON object
        does not have a password key.
        """
        with self.client:
            response = self.client.post(
                "/users",
                data=json.dumps(
                    dict(username="michael", email="michael@reallynotreal.com")
                ),
                content_type="application/json",
                headers=get_header(self.client, as_admin=True),
            )
            data = json.loads(response.data.decode())
            self.assertEqual(response.status_code, 400)
            self.assertIn("Invalid payload.", data["message"])
            self.assertIn("fail", data["status"])

    def test_add_user_inactive(self):
        add_user("test", "test@test.com", "test")
        # update user
        user = User.query.filter_by(email="test@test.com").first()
        user.active = False
        db.session.commit()
        with self.client:
            resp_login = self.client.post(
                "/auth/login",
                data=json.dumps({"email": "test@test.com", "password": "test"}),
                content_type="application/json",
            )
            token = json.loads(resp_login.data.decode())["auth_token"]
            response = self.client.post(
                "/users",
                data=json.dumps(
                    {
                        "username": "michael",
                        "email": "michael@sonotreal.com",
                        "password": "test",
                    }
                ),
                content_type="application/json",
                headers={"Authorization": f"Bearer {token}"},
            )
            data = json.loads(response.data.decode())
            self.assertTrue(data["status"] == "fail")
            self.assertTrue(data["message"] == "Provide a valid auth token.")
            self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    # ----------------------------------------------------------------------- #
    # test main `/` route
    # ----------------------------------------------------------------------- #

    def test_main_no_users(self):
        """Ensure the main route behaves correctly when no users have been
        added to the database."""
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        self.assertIn(b"All Users", response.data)
        self.assertIn(b"<p>No users!</p>", response.data)

    def test_main_with_users(self):
        """Ensure the main route behaves correctly when users have been
        added to the database."""
        add_user("ryan", "ryan@foo.org", "foo")
        add_user("randy", "randy@foo.org", "foo")
        with self.client:
            response = self.client.get("/")
            self.assertEqual(response.status_code, status.HTTP_200_OK)
            self.assertIn(b"All Users", response.data)
            self.assertNotIn(b"<p>No users!</p>", response.data)
            self.assertIn(b"ryan", response.data)
            self.assertIn(b"randy", response.data)

    def test_main_add_user(self):
        """
        Ensure a new user can be added to the database via a POST request.
        """
        with self.client:
            response = self.client.post(
                "/",
                data=dict(
                    username="ryan", email="ryan@foo.com", password="foo"
                ),
                follow_redirects=True,
            )
            self.assertEqual(response.status_code, status.HTTP_200_OK)
            self.assertIn(b"All Users", response.data)
            self.assertNotIn(b"<p>No users!</p>", response.data)
            self.assertIn(b"ryan", response.data)

    def test_add_user_not_admin(self):
        with self.client:
            response = self.client.post(
                "/users",
                data=json.dumps(
                    {
                        "username": "michael",
                        "email": "michael@sonotreal.com",
                        "password": "test",
                    }
                ),
                content_type="application/json",
                headers=get_header(self.client, as_admin=False),
            )
            data = json.loads(response.data.decode())
            self.assertTrue(data["status"] == "fail")
            self.assertTrue(
                data["message"] == "You do not have permission to do that."
            )
            self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


if __name__ == "__main__":
    unittest.main()
