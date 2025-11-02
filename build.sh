#!/bin/bash

source default.env

# Source local .env file if it exists (overrides defaults)
if [ -f .env ]; then
    source .env
fi

docker buildx build --progress=plain --load -t $IMAGE_NAME:$IMAGE_TAG .

size_mb="$(($(docker image inspect $IMAGE_NAME:$IMAGE_TAG --format='{{.Size}}')/1024/1024))"

echo -e "\nImage: $IMAGE_NAME:$IMAGE_TAG ($size_mb MB)"

# copy out build artifacts (cmake build manifests)
container_id=$(docker create ${IMAGE_NAME}:${IMAGE_TAG})
mkdir -p ./artifacts
docker cp "$container_id":/opt/manifests/gnuradio-manifest.txt ./artifacts
docker cp "$container_id":/opt/manifests/volk-manifest.txt ./artifacts
docker cp "$container_id":/opt/manifests/gr-satellites-manifest.txt ./artifacts
docker rm "$container_id"
