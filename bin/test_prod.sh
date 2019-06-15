#!/bin/bash

# get the project dir
MYPWD="command -p pwd"
bin_dir=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && $MYPWD)
project_dir=$(cd -P $bin_dir/.. && $MYPWD)

fails=""

inspect() {
  if [ $1 -ne 0 ]; then
    fails="${fails} $2"
  fi
}

# run unit and integration tests
pushd $project_dir
docker-compose -f docker-compose-prod.yml up -d --build
docker-compose -f docker-compose-prod.yml exec users python manage.py test
inspect $? users
docker-compose -f docker-compose-prod.yml exec users flake8 project
inspect $? end-to-end
./node_modules/.bin/cypress run --config baseUrl=http://$(docker-machine ip testdriven-dev)
inspect $? "adding data"
docker-compose -f docker-compose-prod.yml exec users python manage.py recreate_db
docker-compose -f docker-compose-prod.yml exec users python manage.py seed_db
popd

# return proper code
if [ -n "${fails}" ]; then
  echo "Tests failed: ${fails}"
  exit 1
else
  echo "Tests passed!"
  exit 0
fi
