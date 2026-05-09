# Installation and Deployment

## Purpose

This document explains how to start the complete stack locally or on a Linux VM. The project is fully containerized, so the full environment can be deployed with Docker Compose.

## Requirements

Before starting the project, the following software must be installed:

- Docker
- Docker Compose
- Git

For the automatic deployment scripts on a Linux VM, the following tools are also needed:

- `curl`
- `systemd`

## Project Files

The most important deployment files are:

- `docker-compose.yml`
- `.env`
- `scripts/deploy.sh`
- `scripts/deploy-with-rollback.sh`
- `scripts/auto-deploy-poll.sh`

## Environment Configuration

The project uses a `.env` file to configure service credentials and runtime settings.

Important variables include:

- `INFLUXDB_ADMIN_USERNAME`
- `INFLUXDB_ADMIN_PASSWORD`
- `INFLUXDB_ORG`
- `INFLUXDB_BUCKET`
- `INFLUXDB_ADMIN_TOKEN`
- `GRAFANA_ADMIN_USER`
- `GRAFANA_ADMIN_PASSWORD`
- `NODE_RED_CREDENTIAL_SECRET`
- `DISCORD_WEBHOOK_URL`

For a classroom project this setup is acceptable, but in a production environment secrets should not be stored directly in the repository.

## Local Deployment

Clone the repository:

```bash
git clone <repo-url>
cd Cloud-computing-groep-4
```

Start the complete stack:

```bash
docker compose up -d --build
```

Check whether all containers are running:

```bash
docker compose ps
```

View logs if needed:

```bash
docker compose logs -f
```

Stop the stack:

```bash
docker compose down
```

## Exposed Services

After startup, the main services are available on these ports:

- Mosquitto: `localhost:1883`
- Node-RED: `http://localhost:1880`
- InfluxDB: `http://localhost:8086`
- Grafana: `http://localhost:3000`
- Portainer: `http://localhost:9000`

The `sensor-sim` and `discord-monitor` services run internally and do not expose a web interface.

## Linux VM Deployment

The stack can also be deployed on a Linux VM. A typical setup is:

```bash
sudo mkdir -p /opt/cloud-computing-groep-4
sudo chown "$USER":"$USER" /opt/cloud-computing-groep-4
git clone <repo-url> /opt/cloud-computing-groep-4
cd /opt/cloud-computing-groep-4
docker compose up -d --build
```

From that point, the services are reachable through the VM IP address on the same ports as the local deployment.

## Manual Redeployment

To rebuild and restart the stack after changes, use:

```bash
./scripts/deploy.sh
```

This script:

1. builds the containers
2. stops the current stack
3. starts the updated stack again

## Automatic Deployment on the VM

For automatic polling and deployment, copy the systemd files and enable the timer:

```bash
sudo cp ./scripts/systemd/cloud-groep-4-auto-deploy.service /etc/systemd/system/
sudo cp ./scripts/systemd/cloud-groep-4-auto-deploy.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now cloud-groep-4-auto-deploy.timer
```

The timer checks for updates every minute. If a new commit is found on `origin/main`, the project can be redeployed automatically through `scripts/auto-deploy-poll.sh`.

## Verification

After deployment, the system can be verified in several ways:

- check `docker compose ps`
- open Node-RED and confirm that messages are being received
- open Grafana and confirm that dashboard values are updating
- open Portainer and confirm that the containers are healthy
- inspect logs if a service does not start correctly

## Conclusion

Because the whole platform is defined in Docker Compose, deployment is reproducible and easy to repeat. This is one of the main strengths of the project architecture.
