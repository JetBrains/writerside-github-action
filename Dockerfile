# Container image that runs your code
ARG DOCKER_VERSION=2.1.1256-p3333
FROM registry.jetbrains.team/p/writerside/builder/writerside-builder:${DOCKER_VERSION}

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
