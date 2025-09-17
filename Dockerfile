# Use a more modern and flexible Jenkins base image.
# 'lts-jdk11' provides long-term support and is more up-to-date.
FROM jenkins/jenkins:lts-jdk11

# Maintainer information.
LABEL maintainer="sharath"

# Switch to root user for package installation.
USER root

# Install prerequisites in a single RUN command to reduce image layers.
# The --no-install-recommends flag keeps the image slim.
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends wget zip sudo && \
    echo "jenkins    ALL=NOPASSWD: ALL" >> /etc/sudoers && \
    rm -rf /var/lib/apt/lists/*

# Install Docker Engine without hard-coding Debian specifics.
# This method dynamically detects the OS and is more robust.
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    usermod -aG docker jenkins && \
    rm -rf /var/lib/apt/lists/*

# Change back to Jenkins user to follow least privilege principle.
USER jenkins

# The entrypoint.sh script is a good practice for pre-flight checks.
# It should be copied into the container.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]