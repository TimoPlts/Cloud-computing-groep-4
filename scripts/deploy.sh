#!/usr/bin/env sh
set -eu

echo "Building containers..."
docker compose build

echo "Stopping old containers..."
docker compose down

echo "Starting new stack..."
docker compose up -d
