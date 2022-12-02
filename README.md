---
layout: page
title: "Splunk Docker"
permalink: /splunkdocker
---

# splunk-docker


## [Project Wiki](../../wiki)
For instructions on how to deploy in Podman, Docker, or Protainer

-------------------

## Tests
### Podman
Use of docker's docker-compose for podman is only supported in podman version 3.0.0-dev and above. It is the preferred method for containerizing Splunk. Use run-podman.sh script for deployment with podman.

**Passed CentOS** ✔️ </br>
CentOS Stream release 8</br>
Podman Release v3.1.0</br>

### Docker
Docker may still be the desired method to run containers. If use of Docker natively is desired run the run-docker.sh script.

**Passed CentOS** ✔️</br>
CentOS Stream release 8</br>
Docker version 20.10.3-ce</br>
Docker-Compose version 1.28.2</br>

**Passed Debian 9** ✔️</br>
Docker version 18.06.0-ce</br>
Docker-Compose 1.8.0</br>
