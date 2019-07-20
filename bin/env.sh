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
    export BASE_URL=http://localhost
    export LOAD_BALANCER_DNS_NAME=localhost
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
    export BASE_URL=http://localhost
    export LOAD_BALANCER_DNS_NAME=$(dm ip testdriven-dev)
    export SECRET_KEY='my_precious'
    valid=true
elif [ "$env" = "stage" ]; then
    full_env="Production"
    export FLASK_APP='project/__init__.py'
    export FLASK_ENV='production'
    export DATABASE_URL="postgresql://localhost:5432/testdriven_users_stage"
    export DATABASE_TEST_URL="postgresql//localhost:5432/testdriven_users_test"
    export APP_SETTINGS="project.config.StagingConfig"
    export LOAD_BALANCER_DNS_NAME=testdriven-staging-alb-2001728833.us-east-1.elb.amazonaws.com
    export SECRET_KEY='my_precious'
    valid=true
elif [ "$env" = "prod" ]; then
    full_env="Production"
    export FLASK_APP='project/__init__.py'
    export FLASK_ENV='production'
    export DATABASE_URL="postgresql://localhost:5432/testdriven_users_prod"
    export DATABASE_TEST_URL="postgresql//localhost:5432/testdriven_users_test"
    export APP_SETTINGS="project.config.ProductionConfig"
    export LOAD_BALANCER_DNS_NAME=testdriven-production-alb-1692081710.us-east-1.elb.amazonaws.com
    export AWS_RDS_URI=postgres://webapp:Scarlett2014@testdriven-production.clb31hfmwuad.us-east-1.rds.amazonaws.com/users_prod
    export AWS_RDS_EXERCISES_URI=postgres://webapp:Scarlett2014@testdriven-exercises-production.clb31hfmwuad.us-east-1.rds.amazonaws.com/exercises_prod
    export AWS_RDS_SCORES_URI=postgres://webapp:Scarlett2014@testdriven-scores-production.clb31hfmwuad.us-east-1.rds.amazonaws.com/scores_prod
    valid=true
else
    echo ERROR: valid values: 'test' and 'dev'
    valid=false
fi

# global
export SQLALCHEMY_DATABASE_URI=$DATABASE_URL
export API_GATEWAY_URL=rdok4ehqce.execute-api.us-east-1.amazonaws.com/v2/execute
export REACT_APP_API_GATEWAY_URL=https://${API_GATEWAY_URL}
export BASE_URL=http://${LOAD_BALANCER_DNS_NAME}
export REACT_APP_USERS_SERVICE_URL=$BASE_URL
export REACT_APP_EXERCISES_SERVICE_URL=$BASE_URL
export REACT_APP_SCORES_SERVICE_URL=$BASE_URL

function ping_lambda {

    local json='{"answer": "def sum(x,y):\n    return x+y", "test": "sum(20, 30)", "solution": "50"}'
    local cmd="curl -H \"Content-Type: application/json\" -X POST https://$API_GATEWAY_URL -d '$json'"
    echo $cmd
    eval $cmd
    echo ""
}

if $valid; then

    echo "FLASK_APP                       = $FLASK_APP"
    echo "FLASK_ENV                       = $FLASK_ENV"
    echo "DATABASE_URL                    = $DATABASE_URL"
    echo "DATABASE_TEST_URL               = $DATABASE_TEST_URL"
    echo "APP_SETTINGS                    = $APP_SETTINGS"
    echo "SQLALCHEMY_DATABASE_URI         = $SQLALCHEMY_DATABASE_URI"
    echo "API_GATEWAY_URL                 = $API_GATEWAY_URL"
    echo "REACT_APP_API_GATEWAY_URL       = $REACT_APP_API_GATEWAY_URL"
    echo "REACT_APP_USERS_SERVICE_URL     = $REACT_APP_USERS_SERVICE_URL"
    echo "REACT_APP_EXERCISES_SERVICE_URL = $REACT_APP_EXERCISES_SERVICE_URL"
    echo "REACT_APP_SCORES_SERVICE_URL    = $REACT_APP_SCORES_SERVICE_URL"
    echo "LOAD_BALANCER_DNS_NAME          = $LOAD_BALANCER_DNS_NAME"
    echo "AWS_RDS_URI                     = $AWS_RDS_URI"
    echo "AWS_RDS_EXERCISES_URI           = $AWS_RDS_EXERCISES_URI"
    echo "AWS_RDS_SCORES_URI              = $AWS_RDS_SCORES_URI"
    echo "SECRET_KEY                      = <not set>"
fi

popd
