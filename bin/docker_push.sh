#!/usr/bin/env bash

# get the project dir
MYPWD="command -p pwd"
bin_dir=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && $MYPWD)
project_dir=$(cd -P $bin_dir/.. && $MYPWD)
pushd $project_dir

# for troubleshooting
if [[ "$1" == "local" ]]; then
    export TRAVIS_BRANCH=$2
    if [ "$TRAVIS_BRANCH" != "staging" ] && [ "$TRAVIS_BRANCH" != "production" ]
    then
        echo "$TRAVIS_BRANCH must be \"staging\" or \"production\""
        exit 1
    fi

    export DOCKER_COMPOSE_VERSION=1.24.0
    export COMMIT=commit
    export MAIN_REPO=https://github.com/kelleyrw/testdriven-app.git
    export USERS=test-driven-users
    export USERS_REPO=${MAIN_REPO}#${TRAVIS_BRANCH}:services/users
    export USERS_DB=test-driven-users_db
    export USERS_DB_REPO=${MAIN_REPO}#${TRAVIS_BRANCH}:services/users/project/db
    export EXERCISES=test-driven-exercises
    export EXERCISES_REPO=${MAIN_REPO}#${TRAVIS_BRANCH}:services/exercises
    export EXERCISES_DB=test-driven-exercises_db
    export EXERCISES_DB_REPO=${MAIN_REPO}#${TRAVIS_BRANCH}:services/exercises/project/db
    export CLIENT=test-driven-client
    export CLIENT_REPO=${MAIN_REPO}#${TRAVIS_BRANCH}:services/client
    export SWAGGER=test-driven-swagger
    export SWAGGER_REPO=${MAIN_REPO}#${TRAVIS_BRANCH}:services/swagger
    export SECRET_KEY=my_precious
    export REACT_APP_API_GATEWAY_URL=${REACT_APP_API_GATEWAY_URL}
fi

echo "*****************************************************************"
echo "$running docker_push from ${PWD}"
echo "*****************************************************************"

if [ -z "$TRAVIS_PULL_REQUEST" ] || [ "$TRAVIS_PULL_REQUEST" == "false" ]
then

  if [[ "$TRAVIS_BRANCH" == "staging" ]]; then
    export DOCKER_ENV=stage
    export REACT_APP_USERS_SERVICE_URL="http://testdriven-staging-alb-912419405.us-east-1.elb.amazonaws.com"
    export REACT_APP_EXERCISES_SERVICE_URL="http://testdriven-staging-alb-912419405.us-east-1.elb.amazonaws.com"
  elif [[ "$TRAVIS_BRANCH" == "production" ]]; then
    export DOCKER_ENV=prod
    export REACT_APP_USERS_SERVICE_URL="http://testdriven-production-alb-1692081710.us-east-1.elb.amazonaws.com"
    export REACT_APP_EXERCISES_SERVICE_URL="http://testdriven-production-alb-1692081710.us-east-1.elb.amazonaws.com"
    export DATABASE_URL="$AWS_RDS_URI"
    export SECRET_KEY="$PRODUCTION_SECRET_KEY"
  fi

  if [ "$TRAVIS_BRANCH" == "staging" ] || \
     [ "$TRAVIS_BRANCH" == "production" ]
  then
    if [[ "$1" != "local" ]]; then
        curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
        unzip awscli-bundle.zip
        ./awscli-bundle/install -b ~/bin/aws
        export PATH=~/bin:$PATH
    fi

    # add AWS_ACCOUNT_ID, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY env vars via TravisCI
    eval $(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email --registry-ids $AWS_ACCOUNT_ID)
    export TAG=$TRAVIS_BRANCH
    export REPO=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/rwk
  fi

if [ "$TRAVIS_BRANCH" == "staging" ] || \
   [ "$TRAVIS_BRANCH" == "production" ]
then
    # users
    docker build $USERS_REPO -t $USERS:$COMMIT -f Dockerfile-$DOCKER_ENV
    docker tag $USERS:$COMMIT $REPO/$USERS:$TAG
    docker push $REPO/$USERS:$TAG
    # users db
    docker build $USERS_DB_REPO -t $USERS_DB:$COMMIT -f Dockerfile
    docker tag $USERS_DB:$COMMIT $REPO/$USERS_DB:$TAG
    docker push $REPO/$USERS_DB:$TAG
    # client
    docker build $CLIENT_REPO -t $CLIENT:$COMMIT -f Dockerfile-$DOCKER_ENV --build-arg REACT_APP_USERS_SERVICE_URL=$REACT_APP_USERS_SERVICE_URL --build-arg REACT_APP_EXERCISES_SERVICE_URL=$REACT_APP_EXERCISES_SERVICE_URL --build-arg REACT_APP_API_GATEWAY_URL=$REACT_APP_API_GATEWAY_URL
    docker tag $CLIENT:$COMMIT $REPO/$CLIENT:$TAG
    docker push $REPO/$CLIENT:$TAG
    # swagger
    docker build $SWAGGER_REPO -t $SWAGGER:$COMMIT -f Dockerfile-$DOCKER_ENV
    docker tag $SWAGGER:$COMMIT $REPO/$SWAGGER:$TAG
    docker push $REPO/$SWAGGER:$TAG
    # exercises
    docker build $EXERCISES_REPO -t $EXERCISES:$COMMIT -f Dockerfile-$DOCKER_ENV  # new
    docker tag $EXERCISES:$COMMIT $REPO/$EXERCISES:$TAG
    docker push $REPO/$EXERCISES:$TAG
    # exercises db
    docker build $EXERCISES_DB_REPO -t $EXERCISES_DB:$COMMIT -f Dockerfile
    docker tag $EXERCISES_DB:$COMMIT $REPO/$EXERCISES_DB:$TAG
    docker push $REPO/$EXERCISES_DB:$TAG
  fi
fi

echo "*****************************************************************"
echo "done docker_push.sh"
echo "*****************************************************************"

popd
