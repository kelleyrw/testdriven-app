#!/bin/bash

# get the project dir
MYPWD="command -p pwd"
bin_dir=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && $MYPWD)
project_dir=$(cd -P $bin_dir/.. && $MYPWD)

# set the host URL
host=${1:-localhost}
echo "Testing on $host"

fails=""

inspect() {
  if [ $1 -ne 0 ]; then
    fails="${fails} $2"
  fi
}


# run unit and integration tests
#docker-compose up -d --build
#docker-compose exec users python manage.py test
#inspect $? users
#docker-compose exec users flake8 project
#inspect $? users-lint
#docker-compose exec client npm run test:ci
#inspect $? client
#docker-compose down

# run e2e tests
pushd $project_dir
export SECRET_KEY="my_precious"
docker-compose -f docker-compose-prod.yml up -d --build
#docker-compose -f docker-compose-prod.yml exec users python manage.py recreate_db
#./node_modules/.bin/cypress run --config baseUrl=http://$host
#inspect $? e2e
#docker-compose -f docker-compose-prod.yml down
popd

# return proper code
if [ -n "${fails}" ]; then
  echo "Tests failed: ${fails}"
  exit 1
else
  echo "Tests passed!"
  exit 0
fi
