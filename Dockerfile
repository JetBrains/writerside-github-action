# Container image that runs your code
ARG DOCKER_VERSION
FROM registry.jetbrains.team/p/writerside/builder/writerside-builder:$DOCKER_VERSION

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
