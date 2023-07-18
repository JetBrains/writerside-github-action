ARG DOCKER_VERSION=2.1.1479-p3869
FROM registry.jetbrains.team/p/writerside/builder/writerside-builder:${DOCKER_VERSION}

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

