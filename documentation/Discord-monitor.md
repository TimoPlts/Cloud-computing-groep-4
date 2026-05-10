# Discord Monitor

## Purpose

The Discord monitor is a small monitoring service that checks whether the main containers in the stack are still working. When a service changes from `up` to `down` or from `down` to `up`, the monitor sends a message to a Discord webhook. This is a bonus feature that adds simple alerting to the project.

## Implementation

The `discord-monitor` container is built from the files in [monitor](../monitor). The Docker image is based on Alpine Linux and installs:

- `curl`
- `docker-cli`
- `jq`
- `netcat-openbsd`

The main logic is implemented in [monitor/monitor.sh](../monitor/monitor.sh).

## Monitored Services

By default, the script checks:

- `influxdb`
- `grafana`
- `portainer`
- `nodered`
- `mosquitto`
- `sensor-sim`

The list can be changed with the `MONITOR_TARGETS` environment variable.

## Health Check Methods

Each service is checked in a different way, depending on what makes sense:

- InfluxDB: `http://influxdb:8086/health`
- Grafana: `http://grafana:3000/api/health`
- Portainer: `http://portainer:9000/api/status`
- Node-RED: `http://nodered:1880/`
- Mosquitto: TCP check on port `1883`
- sensor-sim: Docker container state through `docker inspect`

This shows that the monitor does not only test whether a container exists, but whether the service is actually reachable.

## State Tracking

The script stores the last known state of every monitored service in the directory defined by `STATE_DIR`. In Docker Compose, this directory is backed by the named volume `discord-monitor-state`.

This persistent storage ensures the monitor remembers previous states even after restart. It only sends a Discord message when a state changes, avoiding redundant alerts during normal operation.

## Configuration

Important environment variables:

- `DISCORD_WEBHOOK_URL`
- `MONITOR_INTERVAL`
- `MONITOR_STARTUP_DELAY`
- `MONITOR_TARGETS`
- `STATE_DIR`

The webhook URL is required—without it, the script exits immediately. Although the compose file provides an empty default, the script enforces this requirement.

## Why It Is Useful

This monitor adds operational value to the stack:

- it gives visible feedback when a service fails
- it confirms when a service recovers
- it demonstrates basic service monitoring and alerting

For a student project, this demonstrates that the system is not only built, but actively monitored.
