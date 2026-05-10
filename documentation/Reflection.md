# Reflection

## Michiel

I mainly worked on the sensor simulator script, InfluxDB, the InfluxDB integration in Node-RED, and the CI/CD setup.

For Node-RED, my main focus was getting the data correctly written to InfluxDB. A big problem here was the InfluxDB token inside Node-RED, because the container needed to use the right token configuration before the flow could write data successfully.

I also worked on the Python sensor simulator that publishes joystick and button values to MQTT, including invalid button values to test the validation logic.

For CI/CD, I worked on the deploy scripts and the automatic deployment flow with polling and rollback.

Besides these main parts, I also helped with general integration, Docker Compose configuration, testing, small fixes, and documentation.

## Thorben

I mainly worked on Node-RED flows, the Discord monitoring integration, and backup automation.

For Node-RED I implemented and tested flows that process incoming sensor messages and forward them to InfluxDB(i helped with Michiel for that), paying attention to message formats and simple validation so the pipeline stays reliable.

For Discord I set up webhook-based notifications so the team receives alerts for important events; I verified end-to-end delivery and adjusted messages to include useful context.

For backups I prepared and tested our backup scripts (see `scripts/backup-volumes.sh`) to ensure Docker volumes and configuration can be regularly saved and restored. I ran restore checks to confirm data recovery works.

These contributions were focused on operational stability: keeping data flowing, alerting the team, and ensuring recoverability.

## Timo

I mainly worked on Grafana and Portainer in this project.

For Grafana, I helped set up the dashboard, the provisioning files, and the connection with InfluxDB. For Portainer, I worked on adding it to the Docker Compose stack and fixing the configuration so it worked correctly.

Besides that, I also helped a bit with the rest of the project, such as Docker Compose (docker files in general), configuration, small fixes, and documentation.

So my main contribution was the visualization and management part of the project, while also supporting the general integration of the full stack.
