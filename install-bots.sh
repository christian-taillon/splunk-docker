#!/bin/bash
# Install the Splunk BOTS v3 dataset into a running container.
set -eu

DOCKER_CMD=$(command -v docker || command -v podman)
CONTAINER_NAME=${1:-splunk}
BOTS_REPO_URL="https://github.com/splunk/botsv3"
DATASET_URL="https://botsdataset.s3.amazonaws.com/botsv3/botsv3_data_set.tgz"
EXPECTED_MD5="d7ccca99a01cff070dff3c139cdc10eb"
FILE_NAME="botsv3_data_set.tgz"

echo "====> Target container: $CONTAINER_NAME using $DOCKER_CMD"
if [ -z "$($DOCKER_CMD ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "Error: Container '$CONTAINER_NAME' is not running."
    exit 1
fi

echo "====> Dataset source: $BOTS_REPO_URL"
echo "====> Downloading dataset into container..."
$DOCKER_CMD exec -u 0 "$CONTAINER_NAME" bash -c "
    set -eu
    mkdir -p /tmp/bots-download
    cd /tmp/bots-download
    if [ ! -f \"$FILE_NAME\" ]; then
        echo 'Downloading $FILE_NAME...'
        curl -L \"$DATASET_URL\" -o \"$FILE_NAME\"
    else
        echo 'File already exists, skipping download.'
    fi

    echo 'Verifying integrity...'
    echo '$EXPECTED_MD5  $FILE_NAME' | md5sum -c -

    echo 'Extracting to /opt/splunk/etc/apps...'
    tar -xzf \"$FILE_NAME\" -C /opt/splunk/etc/apps

    echo 'Fixing permissions...'
    chown -R splunk:splunk /opt/splunk/etc/apps

    echo 'Cleaning up...'
    rm -f \"$FILE_NAME\"
"

echo "====> Restarting Splunk to pick up new apps..."
$DOCKER_CMD exec -u splunk "$CONTAINER_NAME" /opt/splunk/bin/splunk restart

echo "====> BOTS dataset installation complete!"
