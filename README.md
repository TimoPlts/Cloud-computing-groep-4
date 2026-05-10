# Smart Sensor Gateway

Containerized edge gateway for collecting, validating, storing and visualizing sensor data. The system uses MQTT for sensor communication, Node-RED for processing, InfluxDB for time-series storage, Grafana for dashboards and Portainer for container management.

Most detailed documentation is stored in the [documentation](documentation) folder. This README is the starting point and table of contents.

## Teacher Info

The project is deployed on the VM:

```text
10.20.1.37
```

Important URLs:

| Component | URL |
| --- | --- |
| Node-RED | `http://10.20.1.37:1880` |
| InfluxDB | `http://10.20.1.37:8086` |
| Grafana | `http://10.20.1.37:3000` |
| Portainer | `http://10.20.1.37:9000` |

Discord server invite for the monitor bot:

```text
https://discord.gg/ADnVwJ7mJK
```

## Quick Start

Requirements:

- Docker
- Docker Compose
- Git

Start the full stack:

```bash
git clone <repo-url>
cd Cloud-computing-groep-4
docker compose up -d --build
```

Check the containers:

```bash
docker compose ps
```

Stop the stack:

```bash
docker compose down
```

## Services

| Service | Purpose | Port |
| --- | --- | --- |
| Mosquitto | MQTT broker | `1883` |
| sensor-sim | Simulated joystick/button publisher | internal |
| Node-RED | MQTT processing and validation | `1880` |
| InfluxDB | Time-series storage | `8086` |
| Grafana | Main dashboard | `3000` |
| Portainer | Container management | `9000` |
| discord-monitor | Service monitoring and Discord alerts | internal |

## Project Flow

```text
sensor-sim -> Mosquitto -> Node-RED -> InfluxDB -> Grafana
```

Portainer manages the containers. The Discord monitor checks the services and can send alerts when something goes down.

## Documentation

| Document | Description |
| --- | --- |
| [Installation](documentation/Installation.md) | Local setup and basic deployment |
| [Architecture](documentation/Architecture.md) | System architecture and components |
| [Dataflow](documentation/Dataflow.md) | MQTT topics and data flow |
| [MQTT broker](documentation/MQTT-broker.md) | Mosquitto configuration |
| [Sensor simulator](documentation/Sensor-sim-script.md) | Python sensor simulation script |
| [Node-RED](documentation/Node-RED.md) | Flow logic, validation and InfluxDB integration |
| [InfluxDB](documentation/InfluxDB.md) | Time-series storage layer |
| [Grafana](documentation/Grafana.md) | Dashboard and visualization |
| [Portainer](documentation/Portainer.md) | Container management |
| [Discord monitor](documentation/Discord-monitor.md) | Monitoring and Discord alerts |
| [CI/CD](documentation/CICD.md) | Deploy scripts, polling and rollback |
| [Backup script](documentation/Backup-script.md) | Docker volume backups |
| [Reflection](documentation/Reflection.md) | Team reflection and task division |

