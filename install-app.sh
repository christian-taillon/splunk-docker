#!/bin/bash
# Helper script to install a Splunk app into a running container with persistence
set -eu

# Support for both docker and podman
DOCKER_CMD=$(command -v docker || command -v podman)
CONTAINER_NAME="splunk"

# Usage check
if [ $# -lt 1 ]; then
    echo "Usage: $0 <app_file_path> [container_name]"
    echo "Example: $0 ../../Downloads/splunk-enterprise-security_840.spl"
    exit 1
fi

# Handle @ prefix if present (common for curl-style file references)
APP_FILE_PATH="${1#@}"
CONTAINER_NAME=${2:-$CONTAINER_NAME}

# File existence check on host
if [ ! -f "$APP_FILE_PATH" ]; then
    echo "Error: App file '$APP_FILE_PATH' not found."
    exit 1
fi

# Load SPLUNK_PASSWORD from .env if it exists
if [ -f .env ]; then
    # shellcheck disable=SC2046
    export $(grep '^SPLUNK_PASSWORD=' .env | xargs)
fi

# Default password if not set in .env
SPLUNK_PASSWORD=${SPLUNK_PASSWORD:-changeme}

echo "====> Target container: $CONTAINER_NAME using $DOCKER_CMD"
if ! $DOCKER_CMD ps -q -f name="^/${CONTAINER_NAME}$" > /dev/null; then
    echo "Error: Container '$CONTAINER_NAME' is not running."
    exit 1
fi

APP_FILENAME=$(basename "$APP_FILE_PATH")

echo "====> Copying $APP_FILENAME to container..."
$DOCKER_CMD cp "$APP_FILE_PATH" "$CONTAINER_NAME:/tmp/$APP_FILENAME"

echo "====> Installing app into container..."
# Using -update 1 to overwrite if it already exists
# Using -auth admin:$SPLUNK_PASSWORD for authentication
if $DOCKER_CMD exec -u splunk "$CONTAINER_NAME" /opt/splunk/bin/splunk install app "/tmp/$APP_FILENAME" -auth "admin:$SPLUNK_PASSWORD" -update 1; then
    echo "====> App $APP_FILENAME installed successfully."
else
    echo "Error: Failed to install app $APP_FILENAME."
    $DOCKER_CMD exec -u 0 "$CONTAINER_NAME" rm "/tmp/$APP_FILENAME"
    exit 1
fi

echo "====> Cleaning up temporary file..."
# Cleanup as root since docker cp might set ownership that 'splunk' user can't remove
$DOCKER_CMD exec -u 0 "$CONTAINER_NAME" rm "/tmp/$APP_FILENAME"

echo "====> Restarting Splunk to apply changes (required for many apps)..."
$DOCKER_CMD exec -u splunk "$CONTAINER_NAME" /opt/splunk/bin/splunk restart

echo "====> App $APP_FILENAME installation and restart complete!"
