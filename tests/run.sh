#!/bin/bash

source default.env

# Source local .env file if it exists (overrides defaults)
if [ -f .env ]; then
    source .env
fi

container_name="${IMAGE_NAME}-test"

# docker run --user $(id -u):$(id -g) -v $(pwd):/workspace gnuradio-headless

docker rm -f $container_name 2>/dev/null
docker run --user $(id -u):$(id -g) --name $container_name \
    -v "$(pwd)/tests/python":/opt \
    -w /opt -it $IMAGE_NAME:$IMAGE_TAG bash run.sh
