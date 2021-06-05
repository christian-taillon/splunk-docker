# splunk-docker
Repository for splunk-docker deployment

### Podman
Use of docker's docker-compose for podman is only supported in podman version 3.0.0-dev and above. It is the preferred method for containerizing Splunk. Use run-podman.sh script for deployment with podman.

Passed CentOS ✔️
CentOS Stream release 8
Podman Release v3.1.0

### Docker
Docker may still be the desired method to run containers. If use of Docker natively is desired run the run-docker.sh script.

Passed CentOS ✔️
CentOS Stream release 8
Docker version 20.10.3-ce
Docker-Compose version 1.28.2

Passed Debian 9 ✔️
Docker version 18.06.0-ce
Docker-Compose 1.8.0
