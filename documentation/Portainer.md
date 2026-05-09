# Portainer

## Purpose

Portainer is the management interface for the Docker environment used in this project. It provides a web-based overview of the running containers, images, volumes, and networks, which makes it easier to inspect the state of the stack during development and demonstration.

In this project, Portainer mainly supports the operational side of the platform. It helps show that the containerized services are not only deployed, but also manageable through a central interface.

## Implementation

The `portainer` service is defined in `docker-compose.yml` and uses the image `portainer/portainer-ce:latest`.

The container is configured with:

- port mapping `9000:9000`
- a bind mount to `/var/run/docker.sock`
- a persistent named volume `portainer_data`

The Docker socket mount allows Portainer to communicate with the local Docker engine. Because of that, Portainer can read and manage the containers that belong to this project.

The persistent volume stores Portainer configuration data so the setup remains available after container restarts.

## Access

Portainer is available on:

```text
http://localhost:9000
```

When the stack is deployed on the VM, the same interface can be reached through the VM IP address on port `9000`.
```text
http://10.20.1.37:9000
```

## Role in the Architecture

Portainer is not part of the sensor data path, so it does not process MQTT messages or store measurements. Its role is management and visibility.

It is useful for:

- checking whether all services are running
- viewing container logs
- inspecting Docker networks and volumes
- restarting or troubleshooting containers when needed

This makes it a complementary tool beside Grafana. Grafana shows the sensor data, while Portainer shows the health and structure of the container platform.

## Conclusion

Portainer improves the manageability of the project and makes the Docker-based architecture easier to monitor and demonstrate. It does not replace Docker Compose, but it complements it with a user-friendly operational dashboard.
