#!/usr/bin/env bash

env=${1:-dev}
if [ $env == "dev" ]
then
    compose_file='docker-compose.yml'
elif [ $env == "stage" ]
then
    compose_file='docker-compose-stage.yml'
elif [ $env == "prod" ]
then
    compose_file='docker-compose-prod.yml'
fi

function run {
    local cmd=$1
    echo $cmd
    eval $cmd
}

# create
run "docker-compose -f ${compose_file} exec exercises python manage.py recreate_db"
run "docker-compose -f ${compose_file} exec users python manage.py recreate_db"
run "docker-compose -f ${compose_file} exec scores python manage.py recreate_db"

# seed
run "docker-compose -f ${compose_file} exec exercises python manage.py seed_db"
run "docker-compose -f ${compose_file} exec users python manage.py seed_db"
run "docker-compose -f ${compose_file} exec scores python manage.py seed_db"
