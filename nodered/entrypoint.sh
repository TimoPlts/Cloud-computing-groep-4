#!/bin/sh
set -eu

mkdir -p /data/lib

# Set NODE_RED_FORCE_SEED=true to always sync repository flows/lib into /data at container startup.
force_seed="${NODE_RED_FORCE_SEED:-false}"

if [ "$force_seed" = "true" ] || [ ! -f /data/flows.json ]; then
  cp /opt/nodered-seed/flows.json /data/flows.json
fi

if [ -d /opt/nodered-seed/lib ]; then
  if [ "$force_seed" = "true" ] || [ ! -e /data/lib/secretKey.js ]; then
    cp -R /opt/nodered-seed/lib/. /data/lib/
  fi
fi

exec /usr/src/node-red/entrypoint.sh "$@"
