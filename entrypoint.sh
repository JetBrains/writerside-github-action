#!/bin/sh -l
DOCKER_VERSION=$1

echo "Pulling Docker image with version: $DOCKER_VERSION"
docker pull registry.jetbrains.team/p/writerside/builder/writerside-builder:$DOCKER_VERSION

# Run the Docker image with the specified version.
docker run --rm -v ${PWD}:/workspace registry.jetbrains.team/p/writerside/builder/writerside-builder:$DOCKER_VERSION /bin/bash -s <<'EOF'
echo "Command 1: Set -e"
set -e
echo "Command 2: Execute idea.sh"
/opt/builder/bin/idea.sh helpbuilderinspect -source-dir . -product $PRODUCT --runner github -output-dir artifacts/ || true
echo "Command 3: Test existing artifact '$ARTIFACT'"
test -e artifacts/$ARTIFACT
EOF