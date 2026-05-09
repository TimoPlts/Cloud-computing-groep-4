# CI/CD

## Goal

This project includes both a simple CI workflow and a practical CD procedure. The goal is to make deployment more repeatable and to reduce manual work when the stack changes.

## Continuous Integration

The GitHub Actions workflow is stored in [.github/workflows/blank.yml](../.github/workflows/blank.yml).

It runs on:

- pushes to `main`
- pull requests to `main`
- manual workflow dispatch

The CI job currently performs these checks:

1. checkout of the repository
2. validation of the Docker Compose configuration with `docker compose config`
3. build of the Node-RED image
4. build of the sensor simulator image

This is a basic but useful CI setup. It verifies that the compose file is valid and that the custom images can still be built after code changes.

## Continuous Deployment Scripts

Deployment automation is implemented with shell scripts in the [scripts](../scripts) directory.

### `deploy.sh`

[scripts/deploy.sh](../scripts/deploy.sh) is the simplest deployment script. It:

1. builds the containers
2. stops the old stack
3. starts the new stack in detached mode

This script is enough to demonstrate the minimum CI/CD requirement from the assignment.

### `deploy-with-rollback.sh`

[scripts/deploy-with-rollback.sh](../scripts/deploy-with-rollback.sh) extends the deployment procedure with extra safety:

- fetches the latest commit from `origin/main`
- checks out the target commit in detached mode
- rebuilds and starts the stack
- runs health checks against the running services
- rolls back to the previous commit if the deployment fails

The health checks test both container state and HTTP availability of:

- Node-RED
- Grafana
- InfluxDB
- Portainer

This script shows a more realistic deployment process than a simple restart.

### `auto-deploy-poll.sh`

[scripts/auto-deploy-poll.sh](../scripts/auto-deploy-poll.sh) checks whether `origin/main` contains a new commit. If a new commit is found, it launches `deploy-with-rollback.sh`.

This creates a lightweight pull-based deployment flow for a Linux VM.

## Systemd Automation

For automatic deployment on the VM, the repository contains:

- [scripts/systemd/cloud-groep-4-auto-deploy.service](../scripts/systemd/cloud-groep-4-auto-deploy.service)
- [scripts/systemd/cloud-groep-4-auto-deploy.timer](../scripts/systemd/cloud-groep-4-auto-deploy.timer)

The timer starts the service every minute. The service then runs the polling script from `/opt/cloud-computing-groep-4`.

This means the VM can periodically check the Git repository and deploy a newer version without manual intervention.

## Evaluation

This is not a full enterprise CI/CD pipeline, but it clearly demonstrates the requested principles:

- infrastructure as code with Docker Compose
- automated validation in CI
- repeatable deployments
- optional rollback on failure
- automatic update checks on the VM

For a student project, this is a solid balance between simplicity and technical value.
