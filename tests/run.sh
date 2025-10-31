#!/bin/bash

source common.sh

name=$image_name-test

docker rm -f $name 2>/dev/null; docker run --name $name -v "$(pwd)/python-tests":/opt \
    -w /opt -it $image_name:$image_tag bash run.sh
