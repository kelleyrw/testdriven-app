env=${1:-'test'}

valid=false
if   [ "$env" = "test" ]; then
    full_env="Testing"
    valid=true
elif [ "$env" = "dev" ]; then
    full_env="Development"
    valid=true
else
    echo ERROR: valid values: 'test' and 'dev'
    valid=false
fi

if $valid; then

    echo "Setting up $full_env Environment for Users Service"

    export FLASK_APP='project/__init__.py'
    export FLASK_ENV='test'
    export DATABASE_URL="postgresql://localhost:5432/testdriven_users_$env"
    export DATABASE_TEST_URL="postgresql//localhost:5432/testdriven_users_test"
    export APP_SETTINGS="project.config.${full_env}Config"
    export SQLALCHEMY_DATABASE_URI=$DATABASE_URL
    export SECRET_KEY='my_precious'

    echo FLASK_APP               = $FLASK_APP
    echo FLASK_ENV               = $FLASK_ENV
    echo DATABASE_URL            = $DATABASE_URL
    echo DATABASE_TEST_URL       = $DATABASE_TEST_URL
    echo APP_SETTINGS            = $APP_SETTINGS
    echo SQLALCHEMY_DATABASE_URI = $SQLALCHEMY_DATABASE_URI
    echo SECRET_KEY              = $SECRET_KEY
fi
