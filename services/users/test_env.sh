echo "Setting up Testing Environment for Users Service"

export FLASK_APP='project/__init__.py'
export FLASK_ENV='test'
export DATABASE_URL='postgresql://localhost:5432/testdriven_users_test'
export DATABASE_TEST_URL='postgresql//localhost:5432/testdriven_users_test'
export APP_SETTINGS='project.config.TestingConfig'
export SQLALCHEMY_DATABASE_URI=$DATABASE_URL
