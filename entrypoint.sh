#!/bin/bash

# Check if the Docker socket exists and ensure the Jenkins user can access it.
# This assumes the Jenkins user is part of the 'docker' group, which is handled
# in the Dockerfile.
if [ -e /var/run/docker.sock ]; then
  # This command is more robust as it uses the group ID, not a hardcoded name.
  # chown jenkins:$(stat -c '%g' /var/run/docker.sock) /var/run/docker.sock
  chown jenkins:docker /var/run/docker.sock
fi

# Call the original Jenkins entrypoint script.
# This ensures that all standard Jenkins initialization is performed.
exec /usr/local/bin/jenkins.sh "$@"