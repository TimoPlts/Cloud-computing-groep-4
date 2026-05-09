# CI/CD

## Goal

This project demonstrates the basic CI/CD principles required for the assignment:

- automatically validating the Docker setup
- rebuilding containers after changes
- stopping the old stack
- starting the updated stack with Docker Compose
- optionally deploying automatically on a Linux VM
- rolling back when a deployment fails its health checks

The setup is intentionally lightweight. It is not an enterprise pipeline, but it shows how infrastructure and services can be updated in a repeatable way.

## Continuous Integration

The GitHub Actions workflow is stored in:

```text
.github/workflows/blank.yml
```

It runs on:

- pushes to `main`
- pull requests to `main`
- manual workflow dispatch

The workflow performs these checks:

1. checks out the repository
2. validates the Docker Compose configuration with `docker compose config`
3. builds the Node-RED image
4. builds the sensor simulator image

This verifies that the compose file is still valid and that the custom containers can still be built after a change.

## Simple Deployment

The minimal deployment script for the assignment is:

```text
scripts/deploy.sh
```

Usage:

```bash
chmod +x ./scripts/deploy.sh
./scripts/deploy.sh
```

This script:

1. builds the containers
2. stops the old stack
3. starts the new stack in detached mode

Internally, it runs:

```bash
docker compose build
docker compose down
docker compose up -d
```

This is the simplest way to redeploy the stack manually.

## Automatic Deployment Through Polling

For the automatic VM deployment, place the repository in:

```text
/opt/cloud-computing-groep-4
```

Then enable the systemd timer:

```bash
sudo mkdir -p /opt/cloud-computing-groep-4
sudo chown "$USER":"$USER" /opt/cloud-computing-groep-4
git clone <repo-url> /opt/cloud-computing-groep-4
cd /opt/cloud-computing-groep-4
chmod +x ./scripts/auto-deploy-poll.sh
chmod +x ./scripts/deploy-with-rollback.sh
sudo cp ./scripts/systemd/cloud-groep-4-auto-deploy.service /etc/systemd/system/
sudo cp ./scripts/systemd/cloud-groep-4-auto-deploy.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now cloud-groep-4-auto-deploy.timer
```

The timer starts:

```text
scripts/auto-deploy-poll.sh
```

This script checks `origin/main`. When it detects a new commit, it automatically starts:

```text
scripts/deploy-with-rollback.sh
```

This means the rollback deployment does not normally need to be started manually. It is used internally by the automatic polling flow.

## Rollback Deployment

The rollback script:

```text
scripts/deploy-with-rollback.sh
```

does the following:

1. fetches the latest changes from Git
2. checks out the target commit
3. rebuilds and starts the Docker Compose stack
4. checks whether containers are running
5. checks the main HTTP endpoints
6. rolls back to the previous commit if the deployment is unhealthy

The health checks include:

- Node-RED
- Grafana
- InfluxDB
- Portainer
- container state through Docker

For a one-time test, the rollback script can still be started manually:

```bash
./scripts/deploy-with-rollback.sh
```

## Checking The Auto Deploy

Check whether the timer is active:

```bash
systemctl status cloud-groep-4-auto-deploy.timer --no-pager
```

View the latest deployment logs:

```bash
journalctl -u cloud-groep-4-auto-deploy.service -n 50 --no-pager
```

Check the running stack:

```bash
docker compose ps
```

If only documentation changes were pushed, the VM can still update the Git repository without recreating the containers. Docker Compose only rebuilds or recreates services when the relevant build context, image, or service configuration changes.

