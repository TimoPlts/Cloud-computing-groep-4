# MQTT Broker

## Purpose

The MQTT broker is the entry point for all sensor messages in this project. It receives the data published by the `sensor-sim` container and makes that data available to subscribers such as Node-RED. In this stack, Mosquitto is used because it is lightweight, easy to deploy in Docker, and well suited for local edge communication.

## Implementation

The broker runs in the `mosquitto` service defined in `docker-compose.yml` and uses the official `eclipse-mosquitto:2` image. The configuration is stored in [mosquitto.conf](../mosquitto/config/mosquitto.conf).

Current configuration:

```conf
listener 1883 0.0.0.0
allow_anonymous true
```

This means:

- the broker listens on TCP port `1883`
- it is reachable from other containers on the `cloudnet` network
- anonymous access is allowed

## Topics

The simulator publishes to at least two MQTT topics, which matches the project requirements:

- `controller/joystick`
- `controller/button`

These topics represent two different kinds of controller input. Node-RED subscribes to both topics and processes them separately.

## Role in the Architecture

The broker is responsible only for message transport. It does not validate or store the sensor values. Its job is to decouple the producer from the consumer:

1. `sensor-sim` publishes JSON payloads to Mosquitto.
2. Node-RED subscribes to the relevant topics.
3. Node-RED validates and transforms the data before storing it in InfluxDB.

This design is useful because the producer and consumer do not need to know each other's internal implementation.

## Why MQTT Was Chosen

MQTT fits this project well because it is:

- lightweight
- event-driven
- common in IoT and industrial monitoring
- easy to integrate with Node-RED and Python

It is especially useful for a gateway architecture where multiple devices may publish data to a central local service.

## Limitations and Security Notes

The current broker configuration is intentionally simple for a student lab environment. It works well for local testing, but it is not secure enough for production because:

- anonymous access is enabled
- no username/password authentication is configured
- no TLS encryption is used

For a production deployment, the broker should use authentication, access control, and encrypted transport.
