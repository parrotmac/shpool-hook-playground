#!/usr/bin/env bash
set -euo pipefail

image_5_1=$(docker build -q --build-arg BASH_VERSION=5.1 .)
docker run -it --rm --name bats-bash-5-1 "$image_5_1"

