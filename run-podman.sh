# create volume for var
podman volume create so1-var -l service=splunk
# create volume for apps/config
podman volume create so1-etc -l service=splunk
# run docker compose
docker-compose up
