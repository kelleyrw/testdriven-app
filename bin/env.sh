# get the project dir
MYPWD="command -p pwd"
bin_dir=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && $MYPWD)
project_dir=$(cd -P $bin_dir/.. && $MYPWD)

env=${1:-'local'}

. ${project_dir}/../virtual_environments/testdriven/bin/activate

valid=false
if   [ "$env" = "local" ]; then
    export FLASK_APP='project/__init__.py'
    export FLASK_ENV='local'
    export DATABASE_URL="postgresql://localhost:5432/testdriven_users_dev"
    export DATABASE_TEST_URL="postgresql//localhost:5432/testdriven_users_test"
    export APP_SETTINGS="project.config.DevelopmentConfig"
    export SQLALCHEMY_DATABASE_URI=$DATABASE_URL
    export REACT_APP_USERS_SERVICE_URL=http://localhost:5000
    export SECRET_KEY='my_precious'
    valid=true
elif [ "$env" = "dev" ]; then
    full_env="Development"
    docker-machine env testdriven-dev
    eval $(docker-machine env testdriven-dev)
    export FLASK_APP='project/__init__.py'
    export FLASK_ENV='development'
    export DATABASE_URL="postgresql://localhost:5432/testdriven_users_dev"
    export DATABASE_TEST_URL="postgresql//localhost:5432/testdriven_users_test"
    export APP_SETTINGS="project.config.DevelopmentConfig"
    export SQLALCHEMY_DATABASE_URI=$DATABASE_URL
    export REACT_APP_USERS_SERVICE_URL=http://$(dm ip testdriven-dev)
    export SECRET_KEY='my_precious'
    valid=true
elif [ "$env" = "prod" ]; then
    full_env="Production"
    docker-machine env testdriven-prod
    eval $(docker-machine env testdriven-prod)
    export FLASK_APP='project/__init__.py'
    export FLASK_ENV='production'
    export DATABASE_URL="postgresql://localhost:5432/testdriven_users_prod"
    export DATABASE_TEST_URL="postgresql//localhost:5432/testdriven_users_test"
    export APP_SETTINGS="project.config.ProductionConfig"
    export SQLALCHEMY_DATABASE_URI=$DATABASE_URL
    export REACT_APP_USERS_SERVICE_URL=http://$(dm ip testdriven-prod)
    export SECRET_KEY='33d5b28fb4f6d18e7cc6450a521f335d92e890196fa8da38'
    valid=true
else
    echo ERROR: valid values: 'test' and 'dev'
    valid=false
fi

if $valid; then

    echo FLASK_APP               = $FLASK_APP
    echo FLASK_ENV               = $FLASK_ENV
    echo DATABASE_URL            = $DATABASE_URL
    echo DATABASE_TEST_URL       = $DATABASE_TEST_URL
    echo APP_SETTINGS            = $APP_SETTINGS
    echo SQLALCHEMY_DATABASE_URI = $SQLALCHEMY_DATABASE_URI
    echo SECRET_KEY              = $SECRET_KEY
fi
