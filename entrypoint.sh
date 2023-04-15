#!/bin/sh -l
DOCKER_VERSION=$1

echo "Pulling Docker image with version: $DOCKER_IMAGE_VERSION"
docker pull registry.jetbrains.team/p/writerside/builder/writerside-builder:$DOCKER_VERSION

echo "Running commands inside Docker container:"
{
  echo "set -e"
  echo "echo 'Running: Execute idea.sh'"
  echo "/opt/builder/bin/idea.sh helpbuilderinspect -source-dir . -product \$PRODUCT --runner github -output-dir artifacts/ || true"
  echo "echo 'Running: Test existing artifact \$ARTIFACT'"
  echo "test -e artifacts/\$ARTIFACT"
} | docker run --rm -v ${PWD}:/workspace -e PRODUCT -e ARTIFACT registry.jetbrains.team/p/writerside/builder/writerside-builder:$DOCKER_VERSION /bin/bash -s
