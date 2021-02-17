# start podman systemd socket-activated service
sudo systemctl enable --now start podman.socket
# validate the service is running
sudo curl -H "Content-Type: application/json" --unix-socket
