#!/bin/sh -l
DOCKER_IMAGE_VERSION=$1

echo "Pulling Docker image with version: $DOCKER_IMAGE_VERSION"
docker pull registry.jetbrains.team/p/writerside/builder/writerside-builder:$DOCKER_IMAGE_VERSION

# Run the Docker image with the specified version.
# Replace 'some-command' with the actual commands needed for your action.
docker run --rm -v ${PWD}:/workspace registry.jetbrains.team/p/writerside/builder/writerside-builder:$DOCKER_IMAGE_VERSION /bin/bash -s <<'EOF'
set -e
/opt/builder/bin/idea.sh helpbuilderinspect -source-dir . -product $PRODUCT --runner github -output-dir artifacts/ || true
echo "Test existing of $ARTIFACT artifact"
test -e artifacts/$ARTIFACT
EOF