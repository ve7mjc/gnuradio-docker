#!/bin/bash

source default.env

# Source local .env file if it exists (overrides defaults)
if [ -f .env ]; then
    source .env
fi

# Configure build output style based on argument
BUILD_MODE="${1:-normal}"
case "$BUILD_MODE" in
    "debug"|"plain"|"verbose")
        PROGRESS_ARG="--progress=plain"
        echo "Using debug/verbose build output"
        ;;
    "normal"|"modern"|"")
        PROGRESS_ARG=""
        echo "Using modern build output"
        ;;
    *)
        echo "Unknown build mode: $BUILD_MODE"
        echo "Usage: $0 [debug|normal]"
        echo "  debug  - verbose output with --progress=plain"
        echo "  normal - modern tty output (default)"
        exit 1
        ;;
esac

# Detect apt-cacher-ng proxy
APT_PROXY=""
if curl -s --connect-timeout 2 localhost:3142 >/dev/null 2>&1; then
    APT_PROXY="--build-arg APTPROXY=http://host.docker.internal:3142"
    echo "Detected apt-cacher-ng on localhost:3142, using proxy"
else
    echo "No apt-cacher-ng detected, building without proxy"
fi

docker buildx build $PROGRESS_ARG --load $APT_PROXY -t $IMAGE_NAME:$IMAGE_TAG .

size_mb="$(($(docker image inspect $IMAGE_NAME:$IMAGE_TAG --format='{{.Size}}')/1024/1024))"

echo -e "\nImage: $IMAGE_NAME:$IMAGE_TAG ($size_mb MB)"

# copy out build artifacts (cmake build manifests)
container_id=$(docker create ${IMAGE_NAME}:${IMAGE_TAG})
mkdir -p ./artifacts
docker cp "$container_id":/opt/manifests/gnuradio-manifest.txt ./artifacts
docker cp "$container_id":/opt/manifests/volk-manifest.txt ./artifacts
docker cp "$container_id":/opt/manifests/gr-satellites-manifest.txt ./artifacts
docker rm "$container_id"