#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/..

DOCKER_IMAGE=${DOCKER_IMAGE:-ballpay/balld-develop}
DOCKER_TAG=${DOCKER_TAG:-latest}

BUILD_DIR=${BUILD_DIR:-.}

rm docker/bin/*
mkdir docker/bin
cp $BUILD_DIR/src/balld docker/bin/
cp $BUILD_DIR/src/ball-cli docker/bin/
cp $BUILD_DIR/src/ball-tx docker/bin/
strip docker/bin/balld
strip docker/bin/ball-cli
strip docker/bin/ball-tx

docker build --pull -t $DOCKER_IMAGE:$DOCKER_TAG -f docker/Dockerfile docker
