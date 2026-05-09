# Node-RED

## Purpose

Node-RED is the processing layer of the stack. It subscribes to MQTT messages, converts the JSON payloads into JavaScript objects, validates the values, and forwards only correct measurements to InfluxDB. This service contains the main data logic of the project.

## Implementation

The `nodered` service is built from the custom Dockerfile in [nodered/Dockerfile](../nodered/Dockerfile). The container is based on `nodered/node-red:latest` and installs the package `node-red-contrib-influxdb@0.7.0` so Node-RED can write directly to InfluxDB 2.x.

The build also patches the InfluxDB node so the token can be read from the `INFLUXDB_TOKEN` environment variable. This makes the flow easier to deploy with Docker Compose instead of manually configuring credentials in the UI.

The flow definition is stored in [nodered/flows.json](../nodered/flows.json).

## Data Flow

The flow subscribes to two MQTT topics:

- `controller/joystick`
- `controller/button`

For both topics, the processing steps are similar:

1. Receive the MQTT message.
2. Convert the payload from JSON text to an object.
3. Validate the data inside a function node.
4. Write valid measurements to InfluxDB.
5. Show the result in a debug node during development.

## Validation Logic

### Joystick Data

The joystick flow reads `x` and `y` values. The custom function node checks whether both values are between `0` and `1023`.

If the values are invalid, the message is dropped and a warning is logged. If they are valid, Node-RED also calculates the vector magnitude before storing the measurement.

Stored fields:

- `x`
- `y`
- `magnitude`

Measurement name:

- `joystick`

### Button Data

The button flow reads `a` and `b` values. The function node only accepts `0` or `1`.

If a different value appears, the message is dropped and a warning is logged. This is important because the simulator intentionally sometimes sends invalid button values to prove that the validation layer works.

Stored fields:

- `buttonA`
- `buttonB`

Measurement name:

- `button`

## InfluxDB Connection

Node-RED writes to InfluxDB using:

- organization: `groep4`
- bucket: `sensordata`
- precision: milliseconds

The connection target inside Docker is `http://influxdb:8086`.

## Configuration Notes

The Docker image copies `flows.json` to `/data/flows.json` and generates a `settings.js` file with a credential secret from the `NODE_RED_CREDENTIAL_SECRET` build argument. This makes the Node-RED setup more reproducible and prevents credential data from being stored with the default development secret.

## Why Node-RED Is Important in This Project

Node-RED is not only used as a visual tool. In this project it performs real application logic:

- input validation
- filtering of invalid measurements
- small data transformation
- forwarding to the database

Because of that, it is a central component between the MQTT layer and the storage layer.
