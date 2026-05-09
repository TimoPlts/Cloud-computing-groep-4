# Architecture

## Overview

This project implements a container-based smart sensor gateway. The system receives simulated controller input, transports it through MQTT, validates and transforms it in Node-RED, stores the valid data in InfluxDB, and visualizes the result in Grafana. Portainer is used for container management and the Discord monitor adds simple service alerting.

## Main Data Path

The core data path of the platform is:

```text
sensor-sim -> Mosquitto -> Node-RED -> InfluxDB -> Grafana
```

Each component has a specific responsibility:

- `sensor-sim` generates test sensor data
- `Mosquitto` transports MQTT messages between publisher and subscriber
- `Node-RED` validates and transforms incoming data
- `InfluxDB` stores valid measurements as time-series data
- `Grafana` visualizes live and historical values

## Management and Monitoring Components

Two additional services support the platform:

- `Portainer` provides a web interface to inspect and manage the Docker environment
- `discord-monitor` checks service health and sends alerts to a Discord webhook when a service goes down or recovers

These services are not part of the sensor data path, but they improve manageability and observability.

## Container Network

All services run in Docker containers managed by Docker Compose. They communicate through a dedicated bridge network called `cloudnet`.

This internal network allows services to reach each other by container name, for example:

- `mosquitto:1883`
- `influxdb:8086`
- `grafana:3000`
- `nodered:1880`

This keeps the internal service communication simple and predictable.

## Data Processing Flow

The simulator publishes JSON payloads to two MQTT topics:

- `controller/joystick`
- `controller/button`

Node-RED subscribes to both topics and processes them separately:

1. incoming JSON is parsed
2. values are validated in function nodes
3. invalid measurements are dropped
4. valid measurements are written to InfluxDB

For joystick data, Node-RED also calculates an extra `magnitude` field before storage.

## Storage and Visualization

Validated measurements are stored in the InfluxDB bucket `sensordata` in organization `groep4`.

Grafana is provisioned automatically and reads from the same bucket. The dashboard shows:

- live joystick values
- live button values
- 1-hour averages
- 24-hour averages

This makes the data pipeline visible from raw input to final dashboard output.

## Deployment Model

The full stack is started through one `docker-compose.yml` file. This means the infrastructure is defined as code and can be redeployed consistently on another machine, such as the course VM.

The project also includes deployment scripts and a small CI workflow, which makes the architecture easier to update and maintain.

## Conclusion

The architecture is modular and easy to understand. Each service has one clear role, and the system demonstrates the required cloud concepts:

- MQTT communication
- containerized services
- data validation and processing
- time-series storage
- dashboard visualization
- management and monitoring
