# InfluxDB

## Purpose

InfluxDB is the time-series database used to store the validated sensor data. It is responsible for keeping the joystick and button measurements in a format that is efficient for time-based queries, dashboards, and averaging over different time ranges.

## Implementation

The `influxdb` service runs the official `influxdb:2.7` image. It is configured directly in `docker-compose.yml` through environment variables so the database is initialized automatically when the container starts.

Important initialization parameters:

- `DOCKER_INFLUXDB_INIT_MODE=setup`
- admin username from `INFLUXDB_ADMIN_USERNAME`
- admin password from `INFLUXDB_ADMIN_PASSWORD`
- organization from `INFLUXDB_ORG`
- bucket from `INFLUXDB_BUCKET`
- admin token from `INFLUXDB_ADMIN_TOKEN`

The database files are stored in the named Docker volume `influxdb-data`, so the measurements remain available after container restarts.

## Stored Data

Node-RED writes two measurement types to InfluxDB:

- `joystick`
- `button`

The `joystick` measurement contains:

- `x`
- `y`
- `magnitude`

The `button` measurement contains:

- `buttonA`
- `buttonB`

Only validated data is stored. Invalid measurements are filtered out in Node-RED before they ever reach the database.

## Why InfluxDB Fits This Project

InfluxDB is a good match because this project continuously generates timestamped values. A traditional relational database would work, but a time-series database is better suited for:

- storing large sequences of sensor values
- querying recent measurements
- calculating averages over time windows
- integrating with Grafana

## Integration with Grafana

Grafana connects to InfluxDB through a provisioned data source. The data source uses Flux queries to retrieve both live data and averages over `1h` and `24h` periods.

This means InfluxDB is not only used as storage, but also as the source for analytics and visualization.

## Availability

Inside the Docker network, InfluxDB is available at:

```text
http://influxdb:8086
```

From the host machine, it is exposed on:

```text
http://localhost:8086
```

unless another port is configured through `INFLUXDB_PORT`.

## Notes

This setup is meant for a controlled project environment. In a production setup, extra hardening would be needed, for example:

- secret management outside the repository
- stricter token separation
- backup and restore procedures
- TLS for external access
