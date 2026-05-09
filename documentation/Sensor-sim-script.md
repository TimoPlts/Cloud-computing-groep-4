# Sensor Simulator Script

## Purpose

The `sensor-sim` service simulates a physical controller by publishing test data to the MQTT broker. This makes it possible to demonstrate the complete gateway pipeline without needing real hardware.

## Implementation

The simulator runs in its own Docker container built from [sensor-sim/Dockerfile](../sensor-sim/Dockerfile). The container is based on `python:3.12-slim`, installs `paho-mqtt`, and starts the script [sensor-sim/publish.py](../sensor-sim/publish.py).

The script reads these environment variables:

- `MQTT_HOST`
- `MQTT_PORT`

In Docker Compose, these values are set to:

- host: `mosquitto`
- port: `1883`

## Published Data

The script sends a message every second to two topics:

- `controller/joystick`
- `controller/button`

### Joystick Payload

The joystick payload contains:

```json
{"x": 512, "y": 700}
```

The values are randomly generated between `0` and `1023`.

### Button Payload

The button payload contains:

```json
{"a": 1, "b": 0}
```

The values are randomly selected from `0`, `1`, and `2`.

The value `2` is intentionally invalid for a button. This is done on purpose so Node-RED can prove that it correctly filters wrong measurements before storage.

## MQTT Client Behavior

The script:

1. connects to the MQTT broker
2. starts the MQTT loop in the background
3. publishes joystick and button data every second
4. prints an error when a publish operation fails
5. disconnects cleanly when the process stops

The implementation uses `mqtt.CallbackAPIVersion.VERSION2`, which matches the newer `paho-mqtt` API.

