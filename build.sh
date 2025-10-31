#!/bin/bash

source common.sh

docker buildx build --progress=plain --load -t $image_name:$image_tag .

size_mb="$(($(docker image inspect $image_name:$image_tag --format='{{.Size}}')/1024/1024))"

echo -e "\nImage: $image_name:$image_tag ($size_mb MB)"

