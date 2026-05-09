# Grafana

## Purpose

Grafana is the visualization layer of the project. It reads the stored sensor data from InfluxDB and presents it in a dashboard that shows both live values and averages over time.

## Implementation

The `grafana` service uses the `grafana/grafana-oss:latest` image and is configured in `docker-compose.yml`. The container depends on InfluxDB because the dashboard needs the database to be available.

Grafana data and configuration are mounted through:

- `grafana-data` for persistent Grafana data
- `./grafana/provisioning` for automatic provisioning files
- `./grafana/dashboards` for the dashboard JSON file

## Automatic Provisioning

This project does not rely on manually creating the dashboard after deployment. Instead, Grafana is provisioned automatically.

Provisioning files:

- [grafana/provisioning/datasources/datasource.yml](../grafana/provisioning/datasources/datasource.yml)
- [grafana/provisioning/dashboards/dashboard.yml](../grafana/provisioning/dashboards/dashboard.yml)

The data source points to:

```text
http://influxdb:8086
```

and uses Flux as query language. The organization, bucket, and token are injected through environment variables.

## Dashboard

The dashboard definition is stored in [grafana/dashboards/smart-sensor-gateway.json](../grafana/dashboards/smart-sensor-gateway.json).

The dashboard contains:

- live joystick X values
- live joystick Y values
- live button A values
- live button B values
- average joystick values per hour over the last 24 hours
- average button values per hour over the last 24 hours
- average joystick values per 24 hours over the last 30 days
- average button values per 24 hours over the last 30 days

These graphs are based on Flux queries with `range()` and `aggregateWindow()`.

## Why Grafana Was Used

Grafana is a strong choice for this project because:

- it integrates well with InfluxDB
- it supports live and historical data views
- dashboards are easy to read during a demo
- the configuration can be stored as code

That last point is important because the dashboard is version-controlled in the repository and automatically reloaded by the container.

## Availability

Grafana is exposed on:

```text
http://localhost:3000
```

Inside the VM deployment, the same port can be accessed through the VM IP address.
```text
http://10.20.1.37:3000
```
