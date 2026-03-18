#!/bin/sh
set -eu

mkdir -p /data/lib

if [ ! -f /data/flows.json ]; then
  cp /opt/nodered-seed/flows.json /data/flows.json
fi

if [ -d /opt/nodered-seed/lib ] && [ ! -e /data/lib/secretKey.js ]; then
  cp -R /opt/nodered-seed/lib/. /data/lib/
fi

exec /usr/src/node-red/entrypoint.sh "$@"
