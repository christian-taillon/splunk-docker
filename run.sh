# create volume for var
docker volume create so1-var
# create volume for apps/config
docker volume create so1-etc
# run docker compose
docker-compose up
