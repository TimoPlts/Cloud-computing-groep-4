# Installation and Deployment

## Purpose

This document explains how to start the complete stack locally or on a Linux VM. The project is fully containerized, so the full environment can be deployed with Docker Compose.

## Requirements

Before starting the project, the following software must be installed:

- Docker
- Docker Compose
- Git

## Project Files

The most important deployment files are:

- `docker-compose.yml`
- `.env`
- `scripts/deploy.sh`

The automatic VM deployment, polling setup, and rollback flow are documented separately in [CICD.md](./CICD.md).

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

The stack can also be deployed on a Linux VM with the same Docker Compose command:

```bash
docker compose up -d --build
```

**For the full VM setup with automatic polling, systemd and rollback, see [CICD.md](./CICD.md).**

## Manual Redeployment

To rebuild and restart the stack after changes, use:

```bash
./scripts/deploy.sh
```

This script:

1. builds the containers
2. stops the current stack
3. starts the updated stack again

## Verification

After deployment, the system can be verified in several ways:

- check `docker compose ps`
- open Node-RED and confirm that messages are being received
- open Grafana and confirm that dashboard values are updating
- open Portainer and confirm that the containers are healthy
- inspect logs if a service does not start correctly


