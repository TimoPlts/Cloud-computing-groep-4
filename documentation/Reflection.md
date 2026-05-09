# Reflection

## Michiel

I mainly worked on the sensor simulator script, InfluxDB, the InfluxDB integration in Node-RED, and the CI/CD setup.

For Node-RED, my main focus was getting the data correctly written to InfluxDB. A big problem here was the InfluxDB token inside Node-RED, because the container needed to use the right token configuration before the flow could write data successfully.

I also worked on the Python sensor simulator that publishes joystick and button values to MQTT, including invalid button values to test the validation logic.

For CI/CD, I worked on the deploy scripts and the automatic deployment flow with polling and rollback.

Besides these main parts, I also helped with general integration, Docker Compose configuration, testing, small fixes, and documentation.

## Thorben

## Timo

I mainly worked on Grafana and Portainer in this project.

For Grafana, I helped set up the dashboard, the provisioning files, and the connection with InfluxDB. For Portainer, I worked on adding it to the Docker Compose stack and fixing the configuration so it worked correctly.

Besides that, I also helped a bit with the rest of the project, such as Docker Compose (docker files in general), configuration, small fixes, and documentation.

So my main contribution was the visualization and management part of the project, while also supporting the general integration of the full stack.
