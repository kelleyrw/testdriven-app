#!/usr/bin/env bash

# get the project dir
MYPWD="command -p pwd"
bin_dir=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && $MYPWD)
project_dir=$(cd -P $bin_dir/.. && $MYPWD)

env=${1:-'local'}

#. ${project_dir}/../virtual_environments/testdriven/bin/activate

pushd $project_dir

valid=false
if   [ "$env" = "local" ]; then
    docker-machine env -u
    eval $(docker-machine env -u)
    export FLASK_APP='project/__init__.py'
    export FLASK_ENV='local'
    export DATABASE_URL="postgresql://localhost:5432/testdriven_users_dev"
    export DATABASE_TEST_URL="postgresql//localhost:5432/testdriven_users_test"
    export APP_SETTINGS="project.config.DevelopmentConfig"
    export REACT_APP_USERS_SERVICE_URL=http://localhost
    export REACT_APP_EXERCISES_SERVICE_URL=http://localhost
    export LOAD_BALANCER_STAGE_DNS_NAME=localhost
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
    export REACT_APP_USERS_SERVICE_URL=http://$(dm ip testdriven-dev)
    export REACT_APP_EXERCISES_SERVICE_URL=http://$(dm ip testdriven-dev)
    export LOAD_BALANCER_STAGE_DNS_NAME=$(dm ip testdriven-dev)
    export SECRET_KEY='my_precious'
    valid=true
elif [ "$env" = "stage" ]; then
    full_env="Production"
    docker-machine env testdriven-stage
    eval $(docker-machine env testdriven-stage)
    export FLASK_APP='project/__init__.py'
    export FLASK_ENV='production'
    export DATABASE_URL="postgresql://localhost:5432/testdriven_users_stage"
    export DATABASE_TEST_URL="postgresql//localhost:5432/testdriven_users_test"
    export APP_SETTINGS="project.config.StagingConfig"
    export REACT_APP_USERS_SERVICE_URL=http://testdriven-staging-alb-912419405.us-east-1.elb.amazonaws.com
    export LOAD_BALANCER_STAGE_DNS_NAME=testdriven-staging-alb-912419405.us-east-1.elb.amazonaws.com
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
    export REACT_APP_USERS_SERVICE_URL=http://testdriven-production-alb-1692081710.us-east-1.elb.amazonaws.com
    export LOAD_BALANCER_STAGE_DNS_NAME=testdriven-production-alb-1692081710.us-east-1.elb.amazonaws.com
    export SECRET_KEY='33d5b28fb4f6d18e7cc6450a521f335d92e890196fa8da38'
    valid=true
else
    echo ERROR: valid values: 'test' and 'dev'
    valid=false
fi

# global
export SQLALCHEMY_DATABASE_URI=$DATABASE_URL
export API_GATEWAY_URL=rdok4ehqce.execute-api.us-east-1.amazonaws.com/v1/execute
export REACT_APP_API_GATEWAY_URL=https://${API_GATEWAY_URL}

if $valid; then

    echo "FLASK_APP                       = $FLASK_APP"
    echo "FLASK_ENV                       = $FLASK_ENV"
    echo "DATABASE_URL                    = $DATABASE_URL"
    echo "DATABASE_TEST_URL               = $DATABASE_TEST_URL"
    echo "APP_SETTINGS                    = $APP_SETTINGS"
    echo "SQLALCHEMY_DATABASE_URI         = $SQLALCHEMY_DATABASE_URI"
    echo "SECRET_KEY                      = $SECRET_KEY"
    echo "API_GATEWAY_URL                 = $API_GATEWAY_URL"
    echo "REACT_APP_API_GATEWAY_URL       = $REACT_APP_API_GATEWAY_URL"
    echo "REACT_APP_USERS_SERVICE_URL     = $REACT_APP_USERS_SERVICE_URL"
    echo "REACT_APP_EXERCISES_SERVICE_URL = $REACT_APP_EXERCISES_SERVICE_URL"
    echo "LOAD_BALANCER_STAGE_DNS_NAME    = $LOAD_BALANCER_STAGE_DNS_NAME"
fi

popd
