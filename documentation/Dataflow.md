# Data Flow

## Purpose

This document explains how data moves through the platform from the simulator to the final dashboard. The goal is to show clearly where messages are generated, validated, stored, and visualized.

## Step 1: Sensor Simulation

The process starts in the `sensor-sim` container. The Python script publishes two types of controller data every second:

- joystick data
- button data

The simulator sends JSON payloads to the MQTT broker.

Example joystick payload:

```json
{"x": 512, "y": 700}
```

Example button payload:

```json
{"a": 1, "b": 0}
```

## Step 2: MQTT Transport

The messages are published to the Mosquitto broker on two topics:

- `controller/joystick`
- `controller/button`

Mosquitto does not validate or modify the payload. It only routes the messages to subscribers.

## Step 3: Node-RED Processing

Node-RED subscribes to both topics and handles them in separate flows.

### Joystick Flow

The joystick flow:

1. receives the MQTT message
2. parses the JSON payload
3. validates that `x` and `y` are between `0` and `1023`
4. calculates `magnitude`
5. forwards valid data to InfluxDB

If the values are outside the allowed range, the message is dropped and a warning is logged.

### Button Flow

The button flow:

1. receives the MQTT message
2. parses the JSON payload
3. validates that `a` and `b` are either `0` or `1`
4. renames the fields to `buttonA` and `buttonB`
5. forwards valid data to InfluxDB

The simulator intentionally sometimes sends the value `2` for button fields. This is invalid by design, so Node-RED can prove that the validation logic works correctly.

## Step 4: Storage in InfluxDB

Only valid measurements are written to InfluxDB.

The database stores two measurement types:

- `joystick`
- `button`

Stored joystick fields:

- `x`
- `y`
- `magnitude`

Stored button fields:

- `buttonA`
- `buttonB`

The target bucket is:

```text
sensordata
```

The target organization is:

```text
groep4
```

## Step 5: Visualization in Grafana

Grafana reads the stored values from InfluxDB through Flux queries. The dashboard presents:

- live joystick X and Y values
- live button A and B values
- hourly averages over the last 24 hours
- daily averages over the last 30 days

This gives both real-time insight and historical trend information.

## Summary of the Full Flow

The complete flow can be summarized as:

```text
sensor-sim
  -> publishes JSON messages
Mosquitto
  -> routes messages by topic
Node-RED
  -> parses, validates, transforms
InfluxDB
  -> stores valid time-series data
Grafana
  -> visualizes live and aggregated values
```

## Why This Flow Is Important

This data flow demonstrates the main technical goals of the assignment:

- MQTT-based communication
- message processing in Node-RED
- filtering of incorrect measurements
- storage in a time-series database
- dashboard-based visualization

Because invalid messages are removed before storage, the final dashboard only shows trusted data.
