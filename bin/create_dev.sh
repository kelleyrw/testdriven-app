#!/bin/bash

# get the project dir
MYPWD="command -p pwd"
bin_dir=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && $MYPWD)
project_dir=$(cd -P $bin_dir/.. && $MYPWD)

# run unit and integration tests
pushd $project_dir
docker-compose up -d --build --force-recreate
docker-compose exec users python manage.py recreate_db
docker-compose exec users python manage.py seed_db
docker-compose exec exercises python manage.py recreate_db
docker-compose exec exercises python manage.py seed_db
popd
