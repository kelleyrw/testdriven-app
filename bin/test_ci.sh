#!/usr/bin/env bash

# get the project dir
MYPWD="command -p pwd"
bin_dir=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && $MYPWD)
project_dir=$(cd -P $bin_dir/.. && $MYPWD)
pushd ${project_dir}


env=$1
host=${2:-localhost}
fails=""

inspect() {
  if [ $1 -ne 0 ]; then
    fails="${fails} $2"
  fi
}

# run client and server-side tests
dev() {
  docker-compose up -d --build
  docker-compose exec users python manage.py test
  inspect $? users
  docker-compose exec users flake8 project
  inspect $? users-lint
  docker-compose exec exercises python manage.py test
  inspect $? exercises
  docker-compose exec exercises flake8 project
  inspect $? exercises-lint
  docker-compose exec client npm run test:ci
  inspect $? client
  docker-compose down
}

# run e2e tests
e2e() {
  docker-compose -f docker-compose-stage.yml up -d --build
  docker-compose -f docker-compose-stage.yml run users python manage.py recreate_db
  docker-compose -f docker-compose-stage.yml run exercises python manage.py recreate_db
  docker-compose -f docker-compose-stage.yml exec exercises python manage.py seed_db
  cmd="${project_dir}/node_modules/.bin/cypress run --config baseUrl=http://${host} --env REACT_APP_API_GATEWAY_URL=${REACT_APP_API_GATEWAY_URL},LOAD_BALANCER_DNS_NAME=${LOAD_BALANCER_DNS_NAME}"
  echo $cmd
  eval $cmd
  inspect $? e2e
  docker-compose -f docker-compose-stage.yml down
  docker-compose -f docker-compose-$1.yml down
}

# run appropriate tests
if [[ "${env}" == "development" ]]; then
  echo "Running client and server-side tests!"
  dev
elif [[ "${env}" == "staging" ]]; then
  echo "Running e2e tests!"
  e2e stage
elif [[ "${env}" == "production" ]]; then
  echo "Running e2e tests!"
  e2e prod
else
  echo "Running client and server-side tests!"
  dev
fi

popd

# return proper code
if [ -n "${fails}" ]; then
  echo "Tests failed: ${fails}"
  exit 1
else
  echo "Tests passed!"
  exit 0
fi