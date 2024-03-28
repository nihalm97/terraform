# Use a minimal base image with a recent Ubuntu version
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Define the GitHub runner version as an argument with a default value
ARG RUNNER_VERSION=2.308.0
ENV RUNNER_VERSION=${RUNNER_VERSION}

# Create a non-sudo user
RUN useradd -m docker

# Update package lists, upgrade system packages, and install necessary packages
RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        curl \
        nodejs \
        wget \
        unzip \
        vim \
        git \
        azure-cli \
        jq \
        build-essential \
        libssl-dev \
        libffi-dev \
        python3 \
        python3-venv \
        python3-dev \
        python3-pip

# Create the actions-runner directory and download GitHub Actions Runner
RUN mkdir -p /home/docker/actions-runner \
    && curl -L -o /home/docker/actions-runner/actions-runner-linux-x64.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf /home/docker/actions-runner/actions-runner-linux-x64.tar.gz -C /home/docker/actions-runner \
    && rm /home/docker/actions-runner/actions-runner-linux-x64.tar.gz \
    && chown -R docker /home/docker/actions-runner \
    && /home/docker/actions-runner/bin/installdependencies.sh

# Copy the start.sh script into the image
COPY scripts/start.sh /home/docker/actions-runner/start.sh

# Make the script executable
RUN chmod +x /home/docker/actions-runner/start.sh

# Set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# Set the entrypoint to the start.sh script
ENTRYPOINT ["/home/docker/actions-runner/start.sh"]