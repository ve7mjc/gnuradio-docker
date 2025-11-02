#!/bin/bash

source default.env

# Source local .env file if it exists (overrides defaults)
if [ -f .env ]; then
    source .env
fi

container_name="${IMAGE_NAME}-test"

docker rm -f $container_name 2>/dev/null
docker run --name $container_name \
    -v "$(pwd)/tests/python":/opt \
    -w /opt -it $IMAGE_NAME:$IMAGE_TAG bash run.sh
