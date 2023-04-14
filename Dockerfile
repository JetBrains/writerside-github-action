# Stage 1: Install Docker command-line tool
ARG DOCKER_VERSION=20.10.10
FROM docker:${DOCKER_VERSION}-dind as docker-cli

# Install Docker command-line tool
RUN apk add --no-cache curl && \
    curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz | tar -xz -C /usr/local/bin --strip-components 1

# Stage 2: Build your action using your existing image
ARG DOCKER_VERSION=2.1.1256-p3333
FROM registry.jetbrains.team/p/writerside/builder/writerside-builder:${DOCKER_VERSION}

# Copy the Docker command-line tool from the previous stage
COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]


