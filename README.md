# splunk-docker

Minimal standalone-only Splunk Enterprise compose setup for local evaluation on a workstation or LAN.

## Quick start

1. Keep the generated local `.env` file in place.
2. Start Splunk:

```sh
docker compose up -d splunk
```

3. Watch startup:

```sh
docker compose ps
docker compose logs -f splunk
```

4. Open `http://<host-ip>:8000` from your machine or another host on the same LAN and sign in as `admin` with the password from `.env`.

## What is exposed

The compose file publishes Splunk on all host interfaces so other LAN clients can reach it:

- `8000/tcp`: Splunk Web UI
- `8088/tcp`: HTTP Event Collector
- `8089/tcp`: management API
- `9997/tcp`: forwarder / receiving port

This repo no longer includes a bundled universal forwarder service. External forwarders or log shippers can still send data to the standalone instance over the published ingestion ports.

## Environment file

`.env` provides the local startup values consumed by `docker-compose.yml`:

- `SPLUNK_PASSWORD`: admin password for the standalone instance.
- `SPLUNK_GENERAL_TERMS`: required Splunk 10.x general terms acceptance flag.
- `SPLUNK_LICENSE_URI`: defaults the container to `Free`. To use an Enterprise license file instead, set this to `/run/splunk/licenses/<your-license-file>`.

`.env` is intentionally local-only and should never be committed.

## Enterprise license file (optional)

The base compose setup still defaults to `Free`, so this does not affect other users unless they opt in.

To use a local Splunk Enterprise license file:

1. Put the file in `licenses/` (for example `licenses/Splunk.License`).
2. Set `SPLUNK_LICENSE_URI=/run/splunk/licenses/Splunk.License` in your local `.env`.
3. Restart the container:

```sh
docker compose up -d --force-recreate splunk
```

The compose file mounts `./licenses` into the container at `/run/splunk/licenses` as read-only, so users without a license file can keep using the default `Free` mode.

## Helper scripts

- `./run-docker.sh` runs `docker compose up -d`.
- `./run-podman.sh` runs `podman compose up -d`.
- `./install-bots.sh` downloads and installs the BOTS v3 dataset into the running Splunk container.
- `./install-app.sh` installs a local Splunk app (`.spl` or `.tar.gz`) into the running container with persistence.
  ```bash
  ./install-app.sh /path/to/your/app.spl
  ```

## BOTS Dataset (Optional)

To easily install the BOTS v3 dataset for testing:

```sh
./install-bots.sh
```

This will download the ~320MB `botsv3_data_set.tgz`, verify its MD5, extract it to `/opt/splunk/etc/apps`, and restart Splunk.

## Fresh reset

If you need a clean standalone instance with a new password or empty data, remove the old stack state first:

```sh
docker compose down -v --remove-orphans
```

That deletes local Splunk data for this repo.
