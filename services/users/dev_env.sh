echo "Setting up Development Environment for Users Service"

export FLASK_APP='project/__init__.py'
export FLASK_ENV='development'
export DATABASE_URL='postgresql://localhost:5432/testdriven_users_dev'
export DATABASE_TEST_URL='postgresql//localhost:5432/testdriven_users_test'
export APP_SETTINGS='project.config.DevelopmentConfig'
export SQLALCHEMY_DATABASE_URI=$DATABASE_URL
