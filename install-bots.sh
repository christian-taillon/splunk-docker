#!/bin/bash
# Simple script to download and install BOTS v3 dataset into the Splunk container
set -eu

CONTAINER_NAME=${1:-splunk}
DATASET_URL="https://botsdataset.s3.amazonaws.com/botsv3/botsv3_data_set.tgz"
EXPECTED_MD5="d7ccca99a01cff070dff3c139cdc10eb"
FILE_NAME="botsv3_data_set.tgz"

echo "====> Target container: $CONTAINER_NAME"
if ! docker ps -q -f name="^/${CONTAINER_NAME}$" > /dev/null; then
    echo "Error: Container '$CONTAINER_NAME' is not running."
    exit 1
fi

echo "====> Downloading dataset into container..."
docker exec -u 0 "$CONTAINER_NAME" bash -c "
    set -eu
    mkdir -p /tmp/bots-download
    cd /tmp/bots-download
    if [ ! -f $FILE_NAME ]; then
        echo 'Downloading $FILE_NAME...'
        curl -L $DATASET_URL -o $FILE_NAME
    else
        echo 'File already exists, skipping download.'
    fi

    echo 'Verifying integrity...'
    echo '$EXPECTED_MD5  $FILE_NAME' | md5sum -c -

    echo 'Extracting to /opt/splunk/etc/apps...'
    tar -xzf $FILE_NAME -C /opt/splunk/etc/apps
    
    echo 'Fixing permissions...'
    chown -R splunk:splunk /opt/splunk/etc/apps
    
    echo 'Cleaning up...'
    rm $FILE_NAME
"

echo "====> Restarting Splunk to pick up new apps..."
docker exec -u splunk "$CONTAINER_NAME" /opt/splunk/bin/splunk restart

echo "====> BOTS dataset installation complete!"
