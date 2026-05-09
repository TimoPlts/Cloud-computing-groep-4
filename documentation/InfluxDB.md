# InfluxDB

## Purpose

InfluxDB is the time-series database used to store the validated sensor data. It is responsible for keeping the joystick and button measurements in a format that is efficient for time-based queries, dashboards, and averaging over different time ranges.

InfluxDB is not the main dashboard of this project. It is the storage and query layer between Node-RED and Grafana. The final visual dashboard for users is built in Grafana.

InfluxDB is a good match because this project continuously generates timestamped values.

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



## Integration with Grafana

Grafana connects to InfluxDB through a provisioned data source. 

This means InfluxDB acts as the data source for analytics, while Grafana is responsible for the actual visualization. The intended flow is:

```text
Node-RED -> InfluxDB -> Grafana
```

In practice, InfluxDB is used as an intermediate step: it stores clean time-series measurements and makes them queryable, so Grafana can show live values and calculated averages in a clearer dashboard.

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
