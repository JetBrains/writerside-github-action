#!/bin/bash

set -e
docker build --build-arg DOCKER_VERSION=$DOCKER_VERSION -t my-image .
/opt/builder/bin/idea.sh helpbuilderinspect -source-dir . -product $PRODUCT --runner github -output-dir artifacts/ || true
echo "Test existing of $ARTIFACT artifact"
test -e artifacts/$ARTIFACT