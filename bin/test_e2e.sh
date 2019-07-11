#!/usr/bin/env bash

MYPWD="command -p pwd"
bin_dir=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && $MYPWD)
project_dir=$(cd -P $bin_dir/.. && $MYPWD)

cmd="${project_dir}/node_modules/.bin/cypress run --config baseUrl=${BASE_URL} --env REACT_APP_API_GATEWAY_URL=${REACT_APP_API_GATEWAY_URL},LOAD_BALANCER_DNS_NAME=${LOAD_BALANCER_DNS_NAME}"
echo $cmd
eval $cmd



