# create volume for var
docker volume create so1-var
# create volume for apps/config
docker volume create so1-etc
# create volume for user
docker volume create so1-usr
# create volume for system/local
docker volume create so1-sysloc
# run docker compose
docker-compose up -d
