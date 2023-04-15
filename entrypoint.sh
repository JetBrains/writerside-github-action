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

#!/bin/sh -l
DOCKER_VERSION=$1

echo "Pulling Docker image with version: $DOCKER_IMAGE_VERSION"
docker pull your-docker-image:$DOCKER_VERSION

echo "Running commands inside Docker container:"
{
  echo "set -e"
  echo "echo 'Running: Execute idea.sh'"
  echo "/opt/builder/bin/idea.sh helpbuilderinspect -source-dir . -product \$PRODUCT --runner github -output-dir artifacts/ || true"
  echo "echo 'Running: Test existing artifact \$ARTIFACT'"
  echo "test -e artifacts/\$ARTIFACT"
} | docker run --rm -v ${PWD}:/workspace -e PRODUCT -e ARTIFACT registry.jetbrains.team/p/writerside/builder/writerside-builder:$DOCKER_VERSION /bin/bash -s
