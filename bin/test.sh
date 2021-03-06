#!/bin/bash

# get the project dir
MYPWD="command -p pwd"
bin_dir=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && $MYPWD)
project_dir=$(cd -P $bin_dir/.. && $MYPWD)

type=${1:-all}
host=${2:-localhost}
fails=""

pushd ${project_dir}

echo "type = $type"
echo "host = $host"

inspect() {
  if [ $1 -ne 0 ]; then
    fails="${fails} $2"
  fi
}

# run server-side tests
server() {
  docker-compose up -d --build
  docker-compose exec users python manage.py test
  inspect $? users
  docker-compose exec users flake8 project
  inspect $? users-lint
  docker-compose exec exercises python manage.py test
  inspect $? exercises
  docker-compose exec exercises flake8 project
  inspect $? exercises-lint
  docker-compose exec scores python manage.py test
  inspect $? scores
  docker-compose exec scores flake8 project
  inspect $? scores-lint
  docker-compose down
}

# run client-side tests
client() {
  docker-compose up -d --build
  docker-compose exec client npm run test:ci
  inspect $? client
  docker-compose down
}

# run e2e tests
e2e() {
  echo build
  docker-compose -f ${project_dir}/docker-compose-stage.yml up -d --build --force-recreate

#  echo user recreate_db
#  docker-compose -f ${project_dir}/docker-compose-stage.yml exec users python manage.py recreate_db

#  echo exercises recreate_db
#  docker-compose -f ${project_dir}/docker-compose-stage.yml exec exercises python manage.py recreate_db
#
#  echo exercises seed_db
#  docker-compose -f ${project_dir}/docker-compose-stage.yml exec exercises python manage.py seed_db
#
#  echo scores recreate_db
#  docker-compose -f ${project_dir}/docker-compose-stage.yml exec scores python manage.py recreate_db

#  echo scores seed_db
#  docker-compose -f ${project_dir}/docker-compose-stage.yml exec scores python manage.py seed_db

  echo e2e
  cmd="${project_dir}/node_modules/.bin/cypress run \
    --config baseUrl=http://${host} \
    --env REACT_APP_API_GATEWAY_URL=${REACT_APP_API_GATEWAY_URL},LOAD_BALANCER_DNS_NAME=${host}
  "
  echo $cmd
  eval $cmd

  inspect $? e2e
  docker-compose -f ${project_dir}/docker-compose-stage.yml down
}

# run all tests
all() {
  docker-compose up -d --build
  docker-compose exec users python manage.py test
  inspect $? users
  docker-compose exec users flake8 project
  inspect $? users-lint
  docker-compose exec exercises python manage.py test
  inspect $? exercises
  docker-compose exec exercises flake8 project
  inspect $? exercises-lint
  docker-compose exec scores python manage.py test
  inspect $? scores
  docker-compose exec scores flake8 project
  inspect $? scores-lint
  docker-compose exec client npm run test:ci
  inspect $? client
  docker-compose down
  e2e
}

# run appropriate tests
if [[ "${type}" == "server" ]]; then
  echo -e "\n"
  echo -e "Running server-side tests!\n"
  server
elif [[ "${type}" == "client" ]]; then
  echo -e "\n"
  echo -e "Running client-side tests!\n"
  client
elif [[ "${type}" == "e2e" ]]; then
  echo -e "\n"
  echo -e "Running e2e tests!\n"
  e2e
else
  echo -e "\n"
  echo -e "Running all tests!\n"
  all
fi

popd

# return proper code
if [ -n "${fails}" ]; then
  echo -e "\n"
  echo -e "Tests failed: ${fails}"
  exit 1
else
  echo -e "\n"
  echo -e "Tests passed!"
  exit 0
fi
